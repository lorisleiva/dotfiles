# Paths ordered by increasing priority.

# Global bin directories
export PATH="/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Global composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# VS Code
export PATH="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$PATH"

# RabbitMQ
export PATH="/usr/local/opt/rabbitmq/sbin:$PATH"

# DotNet for Unity
export PATH="/usr/local/share/dotnet:$PATH"

# Cargo / Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Solana
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# JetBrains Toolbox
export PATH="$HOME/.local/share/JetBrains/Toolbox/bin:$PATH"

# Local bin directories
export PATH="./bin:./vendor/bin:./node_modules/.bin:$PATH"
