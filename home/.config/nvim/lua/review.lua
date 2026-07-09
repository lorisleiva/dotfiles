-- Send review comments from nvim to the AI agent running in the same herdr
-- workspace (opencode, claude, codex, ...). Agent-agnostic: we resolve whatever
-- agent herdr reports for this workspace and type the comment into its prompt
-- (append-only; you press enter yourself).
--
-- Mechanism (no ports, no opencode API):
--   herdr injects HERDR_WORKSPACE_ID into every managed pane. We list agents
--   with `herdr agent list`, keep the one(s) in our workspace, and deliver text
--   with `herdr agent send <pane_id> <text>` (verified to land in the prompt
--   unsubmitted).

local M = {}

-- Run a herdr command synchronously, returning stdout on success or nil + a
-- message on failure. Fails loudly at the call site.
local function herdr(args)
  local res = vim.system(vim.list_extend({ 'herdr' }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil, (res.stderr ~= '' and res.stderr or res.stdout or 'herdr command failed')
  end
  return res.stdout
end

-- Repo-relative path for the current buffer (falls back to the absolute path).
local function repo_relative_path(bufnr)
  local abs = vim.api.nvim_buf_get_name(bufnr)
  if abs == '' then return nil end
  local dir = vim.fs.dirname(abs)
  local res = vim.system(
    { 'git', '-C', dir, 'rev-parse', '--show-toplevel' },
    { text = true }
  ):wait()
  if res.code == 0 then
    local root = vim.trim(res.stdout)
    if root ~= '' and abs:sub(1, #root + 1) == root .. '/' then
      return abs:sub(#root + 2)
    end
  end
  return vim.fn.fnamemodify(abs, ':.') -- best effort: relative to cwd
end

-- List the agents herdr reports for the given workspace id.
-- Returns a list of { agent = <name>, pane_id = <id>, status = <status> }.
local function agents_in_workspace(workspace_id)
  local out, err = herdr({ 'agent', 'list' })
  if not out then return nil, err end
  local ok, decoded = pcall(vim.json.decode, out)
  if not ok or type(decoded) ~= 'table' then
    return nil, 'could not parse `herdr agent list` output'
  end
  local list = decoded.result and decoded.result.agents or {}
  local matches = {}
  for _, a in ipairs(list) do
    if a.workspace_id == workspace_id and a.pane_id then
      table.insert(matches, { agent = a.agent or 'agent', pane_id = a.pane_id, status = a.agent_status })
    end
  end
  return matches
end

-- Resolve the target pane id for this workspace, prompting when ambiguous.
-- Calls cb(pane_id, agent_name) on success; notifies + does nothing otherwise.
local function resolve_target(cb)
  local workspace_id = vim.env.HERDR_WORKSPACE_ID
  if not workspace_id or workspace_id == '' then
    vim.notify('review: not inside a herdr pane (no HERDR_WORKSPACE_ID)', vim.log.levels.ERROR)
    return
  end

  local matches, err = agents_in_workspace(workspace_id)
  if not matches then
    vim.notify('review: ' .. err, vim.log.levels.ERROR)
    return
  end
  if #matches == 0 then
    vim.notify('review: no agent found in this herdr workspace', vim.log.levels.ERROR)
    return
  end
  if #matches == 1 then
    cb(matches[1].pane_id, matches[1].agent)
    return
  end

  -- Multiple agents: let the user pick.
  vim.ui.select(matches, {
    prompt = 'Send review comment to which agent?',
    format_item = function(m) return ('%s (%s) [%s]'):format(m.agent, m.pane_id, m.status or '?') end,
  }, function(choice)
    if choice then cb(choice.pane_id, choice.agent) end
  end)
end

-- Compose "- [<path>:<lines>]: <message>" and send it. A trailing newline lets
-- multiple comments stack cleanly in the agent's prompt. The first message line
-- sits inline after "]: "; continuation lines are indented 2 spaces so nested
-- lists/content read as part of this item and can't be mistaken for new
-- "- [..]" comments. Blank lines stay empty (no trailing whitespace).
local function send_comment(location, message, pane_id, agent_name)
  local lines = vim.split(message, '\n', { plain = true })
  local first = table.remove(lines, 1)
  local out_lines = { ('- [%s]: %s'):format(location, first) }
  for _, line in ipairs(lines) do
    out_lines[#out_lines + 1] = (line == '') and '' or ('  ' .. line)
  end
  local text = table.concat(out_lines, '\n') .. '\n'
  local out, err = herdr({ 'agent', 'send', pane_id, text })
  if not out then
    vim.notify('review: failed to send to ' .. agent_name .. ': ' .. err, vim.log.levels.ERROR)
    return
  end
  vim.notify(('review: sent to %s (press enter there)'):format(agent_name), vim.log.levels.INFO)
end

-- Build the "<path>:<line>" or "<path>:<start>-<end>" location string.
local function location_for(bufnr, start_line, end_line)
  local path = repo_relative_path(bufnr)
  if not path then
    vim.notify('review: current buffer has no file path', vim.log.levels.ERROR)
    return nil
  end
  if end_line and end_line ~= start_line then
    return ('%s:%d-%d'):format(path, start_line, end_line)
  end
  return ('%s:%d'):format(path, start_line)
end

-- Open a scratch floating window to compose a (possibly multi-line) message.
-- Opens in insert mode. Enter = confirm, Shift-Enter = newline, Esc = cancel.
-- Calls cb(message) with the trimmed text on confirm; does nothing on cancel.
local function compose(cb)
  local buf = vim.api.nvim_create_buf(false, true) -- scratch, unlisted
  vim.bo[buf].bufhidden = 'wipe'
  vim.b[buf].completion = false -- blink.cmp: no completion popups in this box

  local width, height = 60, 8
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Comment (Enter=send, S-Enter=newline, Esc=cancel) ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = true

  local done = false
  local function finish(confirmed)
    if done then return end
    done = true
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    vim.cmd('stopinsert') -- always return to normal mode in the original window
    if not confirmed then return end
    local message = vim.trim(table.concat(lines, '\n'))
    if message ~= '' then cb(message) end
  end

  local function map(mode, lhs, fn)
    vim.keymap.set(mode, lhs, fn, { buffer = buf, nowait = true, silent = true })
  end
  -- Enter confirms (in insert and normal); Shift-Enter inserts a real newline.
  -- The newline is fed with mode 'n' (no remap) so it does NOT re-trigger the
  -- <CR>=confirm mapping above.
  map({ 'n', 'i' }, '<CR>', function() finish(true) end)
  map('i', '<S-CR>', function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
  end)
  -- Cancel paths.
  map({ 'n', 'i' }, '<Esc>', function() finish(false) end)
  map('n', 'q', function() finish(false) end)

  vim.cmd('startinsert')
end

-- Entry point. `range` is nil (current line) or { start_line, end_line }.
function M.comment(range)
  local bufnr = vim.api.nvim_get_current_buf()
  local start_line, end_line
  if range then
    start_line, end_line = range[1], range[2]
  else
    start_line = vim.api.nvim_win_get_cursor(0)[1]
  end

  local location = location_for(bufnr, start_line, end_line)
  if not location then return end

  compose(function(message)
    resolve_target(function(pane_id, agent_name)
      send_comment(location, message, pane_id, agent_name)
    end)
  end)
end

return M
