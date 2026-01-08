---
description: Create or update a README file
argument-hint: "[path]"
---

# Create or Update README

Create a new README or update an existing one for a package, library, or project.

A deep understanding of the project is necessary to create an effective README. Analyze the codebase, key features, and typical usage patterns to inform the content. If the project relies on other libraries or frameworks, consider how those influence usage and installation.

## Arguments

- `$1` (optional): Path to the README file or its directory (e.g., 'packages/rpc' or 'packages/rpc/README.md'). Defaults to the root `README.md` if not provided.

## README Guidelines

Create developer-friendly READMEs. Developers should be excited about installing and using the provided code rather than being overwhelmed by it.

### Structure

The layout of a README will vary from project to project, but they should generally follow these guidelines.

#### 1. Intro Section

- Package/library name as the main heading.
- Badges for tests, package version, downloads, etc. (npm, GitHub, etc.).
- **Very brief summary (ELI5)** — A single sentence or short paragraph that anyone can understand at first glance.
- Only update the intro if you can meaningfully improve the summary; otherwise leave it intact.

#### 2. Installation Section

- Keep it extremely concise (1-2 lines of explanation max if necessary).
- Show the install command in a code block.
- Example:

````markdown
## Installation

```sh
  pnpm install my-library
```
````

#### 3. Usage Section (Most Critical)

- This is where readers' attention lands first after the intro.
- Show the **quickest path to success** with this library.
- **Must include a code snippet** illustrating basic usage.
- Balance between brevity and clarity to create an "aha moment."
- Optional: Brief text before/after the snippet if it adds clarity.
- The code snippet should be realistic, concise, and immediately understandable.

#### 4. Deep Dive Sections

- Structure varies case-by-case based on the project.
- Document key features, concepts, or use cases.
- Each section should include **at least one code snippet**. Similar guidelines as the Usage section, that is, realistic and concise (shortest path to "aha moment").
- Organize logically (e.g., by feature, by use case, by complexity).
- Common patterns:
  - **Features**: Individual feature documentation with examples.
  - **API Reference**: Core APIs or functions.
  - **Advanced Usage**: More complex scenarios.
  - **Configuration**: Setup and customization options.
  - **Examples**: Real-world use cases.
- No need for a "Requirements" section for peer dependencies. Just mention them in the "Installation" section if necessary to get started.

### Code Snippets

- Use TypeScript syntax for TypeScript projects.
- Show realistic but concise examples.
- Include necessary imports when relevant (e.g. when importing from multiple modules).
- Use descriptive variable names (not `foo`, `bar`).
- Keep examples focused on one concept at a time when possible.
- Format for readability (proper indentation, spacing).

### Tone

- Friendly and approachable.
- Clear and direct.
- Avoid marketing speak.
- Focus on practical value.
- Use active voice.
- Assume the reader is a developer who wants to get started quickly.

### What to Avoid

- Overly long introductions or preambles.
- Walls of text without code examples.
- Complex examples in the Usage section.
- Unexplained jargon or acronyms.
- Marketing-heavy language.
- Duplicating information unnecessarily.

## Examples of Good README Patterns

These are just examples of well-structured READMEs and not templates to follow. Each README should be tailored to the specific project following the guidelines above.

### JavaScript monorepo

````markdown
# Codama

[![npm][npm-image]][npm-url]
[![npm-downloads][npm-downloads-image]][npm-url]
[![ci][ci-image]][ci-url]

[npm-downloads-image]: https://img.shields.io/npm/dm/codama.svg?style=flat
[npm-image]: https://img.shields.io/npm/v/codama.svg?style=flat
[npm-url]: https://www.npmjs.com/package/codama
[ci-image]: https://img.shields.io/github/actions/workflow/status/codama-idl/codama/main.yml?logo=GitHub
[ci-url]: https://github.com/codama-idl/codama/actions/workflows/main.yml

Codama is a tool that describes any Solana program in a standardised format called a **Codama IDL**.

A Codama IDL can be used to:

- ✨ Generate **program clients** in various languages and frameworks.
- 📚 Generate **documentation and tooling** for your programs.
- 🗃️ **Register your IDL** for others to discover and index.
- 🔭 Provide valuable information to **explorers and wallets**.

![Codama header: A small double-sided mind-map with the Codama logo in the middle. On the left, we see the various ways to get a Codama IDL from your Solana programs such as "Codama Macros" and "Anchor Program". On the right, we see the various utility tools that are offered for the IDL such as "Generate clients" or "Register IDL".](https://github.com/user-attachments/assets/7a2ef5fa-049e-45a8-a5fc-7c11ff46a54b)

## Table of contents

- [Getting started](#getting-started). Install and use Codama in your project.
- [Coming from Anchor](#coming-from-anchor). Have an Anchor IDL instead? Let’s make that work.
- [Codama scripts](#codama-scripts). Enrich your Codama config file with more scripts.
- [Available visitors](#available-visitors). See what’s available for you to use.
- [Getting a Codama IDL](#getting-a-codama-idl). Extract Codama IDLs from any program.
- [Codama’s architecture](#codamas-architecture). A bit more on the node/visitor design.
- [Other resources](#other-resources).

## Getting started

### Installation

To get started with Codama, simply install `codama` to your project and run the `init` command like so:

```sh
pnpm install codama
codama init
```

You will be prompted for the path of your IDL and asked to select any script presets you would like to use. This will create a Codama configuration file at the root of your project.

### Usage

You may then use the `codama run` command to execute any script defined in your configuration file.

```sh
codama run --all # Run all Codama scripts.
codama run js    # Generates a JavaScript client.
codama run rust  # Generates a Rust client.
```

## Coming from Anchor

If you are using [Anchor](https://www.anchor-lang.com/docs) or [Shank macros](https://github.com/metaplex-foundation/shank), then you should already have an **Anchor IDL**. To make it work with Codama, you simply need to provide the path to your Anchor IDL in your Codama configuration file. Codama will automatically identify this as an Anchor IDL and will convert it to a Codama IDL before executing your scripts.

```json
{
  "idl": "path/to/my/anchor/idl.json"
}
```

## Codama scripts

You can use your Codama configuration file to define any script you want by using one or more visitors that will be invoked when the script is ran.

**Visitors** are objects that will visit your Codama IDL and either perform some operation — like generating a program client — or update the IDL further — like renaming accounts. You can either use visitors from external packages or from a local file, and — in both cases — you can provide any argument the visitor may require.

For instance, the example script below will invoke three visitors:

- The first will use the `default` import from the `my-external-visitor` package and pass `42` as the first argument.
- The second will use the `withDefaults` import from the `my-external-visitor` package.
- The third will use a local visitor located next to the configuration file.

```json
{
  "scripts": {
    "my-script": [
      { "from": "my-external-visitor", "args": [42] },
      "my-external-visitor#withDefaults",
      "./my-local-visitor.js"
    ]
  }
}
```

Note that if an external visitor in your script isn’t installed locally, you will be asked to install it next time you try to run that script.

```sh
❯ codama run my-script

▲ Your script requires additional dependencies.
▲ Install command: pnpm install my-external-visitor
? Install dependencies? › (Y/n)
```

You can [learn more about the Codama CLI here](/packages/cli/README.md).

## Available visitors

The tables below aim to help you discover visitors from the Codama ecosystem that you can use in your scripts.

Feel free to PR your own visitor here for others to discover. Note that they are ordered alphabetically.

### Generates documentation

| Visitor                                                                         | Description                                                                      | Maintainer |
| ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ---------- |
| `@codama/renderers-demo` ([docs](https://github.com/codama-idl/renderers-demo)) | Generates simple documentation as a template to help others create new visitors. | Codama     |

### Generates program clients

| Visitor                                                                                         | Description                                                                                           | Maintainer                                 |
| ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `@codama/renderers-js` ([docs](https://github.com/codama-idl/renderers-js))                     | Generates a JavaScript client compatible with [Solana Kit](https://www.solanakit.com/).               | [Anza](https://www.anza.xyz/)              |
| `@codama/renderers-rust` ([docs](https://github.com/codama-idl/renderers-rust))                 | Generates a Rust client compatible with [the Solana SDK](https://github.com/anza-xyz/solana-sdk).     | [Anza](https://www.anza.xyz/)              |
| `@codama/renderers-vixen-parser` ([docs](https://github.com/codama-idl/renderers-vixen-parser)) | Generates [Yellowstone](https://github.com/rpcpool/yellowstone-grpc) account and instruction parsers. | [Triton One](https://triton.one/)          |
| `@limechain/codama-dart` ([docs](https://github.com/limechain/codama-dart))                     | Generates a Dart client.                                                                              | [LimeChain](https://github.com/limechain/) |
| `codama-py` ([docs](https://github.com/Solana-ZH/codama-py))                                    | Generates a Python client.                                                                            | [Solar](https://github.com/Solana-ZH)      |

### Provides utility

| Visitor                                                                                                             | Description                                                                                                                                                                                                                                                                                                   | Maintainer |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `@codama/visitors#*` ([docs](https://github.com/codama-idl/codama/blob/main/packages/visitors/README.md))           | Provides a big library of utility visitors that can be used to manipulate Codama IDLs. For instance, `updateErrorsVisitor` can be used to update error messages in your IDL . [Check out the docs](https://github.com/codama-idl/codama/blob/main/packages/visitors/README.md) to see all available visitors. | Codama     |
| `@codama/visitors-core#*` ([docs](https://github.com/codama-idl/codama/blob/main/packages/visitors-core/README.md)) | Everything included in `visitors-core` is also included in `visitors`. The helpers offered in this package are slightly more advanced and can be used to help you [build your own visitors](https://github.com/codama-idl/codama/blob/main/packages/visitors-core/README.md#writing-your-own-visitor).        | Codama     |

## Getting a Codama IDL

We are currently working on a set of transparent macros that can be added to any program in order to extract a Codama IDL from it. There are still a lot more macros and scenarios for us to support but most programs can already benefit from these macros. You can then extract an IDL from the provided crate path using the Codama API like so:

```rust
use codama::Codama;

let codama = Codama::load(crate_path)?;
let idl_json = codama.get_json_idl()?;
```

We will add documentation on Codama macros when they are fully implemented but feel free to check this example that extract a Codama IDL from the [System program interface](https://github.com/lorisleiva/codama-demo-2025-08/tree/main/3-from-macros/program/src) using a [build script](https://github.com/lorisleiva/codama-demo-2025-08/blob/main/3-from-macros/program/build.rs).

## Codama's architecture

The Codama IDL is designed as a tree of nodes starting with the `RootNode` which contains a `ProgramNode` and additional data such as the Codama version used when the IDL was created. Codama provides over 60 different types of nodes that help describe nearly every aspect of your Solana programs. [You can read more about the Codama nodes here](./packages/nodes).

![A small example of a Codama IDL as a tree of nodes. It starts with a RootNode and goes down to ProgramNode, AccountNode, InstructionNode, etc.](https://github.com/codama-idl/codama/assets/3642397/9d53485d-a4f6-459a-b7eb-58faab716bc1)

Because everything is designed as a `Node`, we can transform the IDL, aggregate information, and output various utility tools using special objects that can traverse node trees known as visitors. [See this documentation to learn more about Codama visitors](./packages/visitors-core).

![A small example of how a visitor can transform a Codama IDL into another Codama IDL. This example illustrates the "deleteNodesVisitor" which recursively removes NumberTypeNodes from a tree of nested TypleTypeNodes.](https://github.com/codama-idl/codama/assets/3642397/f54e83d1-eade-4674-80dc-7ddc360f5f66)

## Other resources

- [Solana Stack Exchange](https://solana.stackexchange.com/questions/tagged/codama).
- Working with Anchor
  - [Anchor and Solana Kit tutorial](https://www.youtube.com/watch?v=2T3DOMv7iR4).
  - [Anchor Election app](https://github.com/quiknode-labs/anchor-election-2025).
  - [Anchor Swap/Escrow app](https://github.com/quiknode-labs/you-will-build-a-solana-program).
````

### PHP package with external documentation

````markdown
# ⚡️ Laravel Actions

[![Latest Version on Packagist](https://img.shields.io/packagist/v/lorisleiva/laravel-actions.svg)](https://packagist.org/packages/lorisleiva/laravel-actions)
[![GitHub Tests Action Status](https://img.shields.io/github/actions/workflow/status/lorisleiva/laravel-actions/run-tests.yml?branch=main)](https://github.com/lorisleiva/laravel-actions/actions?query=workflow%3ATests+branch%3Amain)
[![Total Downloads](https://img.shields.io/packagist/dt/lorisleiva/laravel-actions.svg)](https://packagist.org/packages/lorisleiva/laravel-actions)

![hero](https://user-images.githubusercontent.com/3642397/104024620-4e572400-51bb-11eb-97fc-c2692b16eaa7.png)

⚡ **Classes that take care of one specific task.**

This package introduces a new way of organising the logic of your Laravel applications by focusing on the actions your applications provide.

Instead of creating controllers, jobs, listeners and so on, it allows you to create a PHP class that handles a specific task and run that class as anything you want.

Therefore it encourages you to switch your focus from:

> "What controllers do I need?", "should I make a FormRequest for this?", "should this run asynchronously in a job instead?", etc.

to:

> "What does my application actually do?"

## Installation

```bash
composer require lorisleiva/laravel-actions
```

## Documentation

:books: Read the full documentation at [laravelactions.com](https://laravelactions.com/)

## Basic usage

Create your first action using `php artisan make:action PublishANewArticle` and define the `asX` methods when you want your action to be running as `X`. E.g. `asController`, `asJob`, `asListener` and/or `asCommand`.

```php
class PublishANewArticle
{
    use AsAction;

    public function handle(User $author, string $title, string $body): Article
    {
        return $author->articles()->create([
            'title' => $title,
            'body' => $body,
        ]);
    }

    public function asController(Request $request): ArticleResource
    {
        $article = $this->handle(
            $request->user(),
            $request->get('title'),
            $request->get('body'),
        );

        return new ArticleResource($article);
    }

    public function asListener(NewProductReleased $event): void
    {
        $this->handle(
            $event->product->manager,
            $event->product->name . ' Released!',
            $event->product->description,
        );
    }
}
```

### As an object

Now, you can run your action as an object by using the `run` method like so:

```php
PublishANewArticle::run($author, 'My title', 'My content');
```

### As a controller

Simply register your action as an invokable controller in a routes file.

```php
Route::post('articles', PublishANewArticle::class)->middleware('auth');
```

### As a listener

Simply register your action as a listener of the `NewProductReleased` event.

```php
Event::listen(NewProductReleased::class, PublishANewArticle::class);
```

Then, the `asListener` method of your action will be called whenever the `NewProductReleased` event is dispatched.

```php
event(new NewProductReleased($manager, 'Product title', 'Product description'));
```

### And more...

On top of running your actions as objects, controllers and listeners, Laravel Actions also supports jobs, commands and even mocking your actions in tests.

📚 [Check out the full documentation to learn everything that Laravel Actions has to offer](https://laravelactions.com/).
````

### JavaScript package included in a monorepo

````markdown
[![npm][npm-image]][npm-url]
[![npm-downloads][npm-downloads-image]][npm-url]
<br />
[![code-style-prettier][code-style-prettier-image]][code-style-prettier-url]

[code-style-prettier-image]: https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square
[code-style-prettier-url]: https://github.com/prettier/prettier
[npm-downloads-image]: https://img.shields.io/npm/dm/@solana/codecs-numbers?style=flat
[npm-image]: https://img.shields.io/npm/v/@solana/codecs-numbers?style=flat
[npm-url]: https://www.npmjs.com/package/@solana/codecs-numbers

# @solana/codecs-numbers

This package contains codecs for numbers of different sizes and endianness. It can be used standalone, but it is also exported as part of Kit [`@solana/kit`](https://github.com/anza-xyz/kit/tree/main/packages/kit).

This package is also part of the [`@solana/codecs` package](https://github.com/anza-xyz/kit/tree/main/packages/codecs) which acts as an entry point for all codec packages as well as for their documentation.

## Integer codecs

This package provides ten codecs of five different byte sizes for integers. Five of them store unsigned integers and the other five store signed integers.

```ts
// Unsigned integers.
getU8Codec().encode(42); // 0x2a
getU16Codec().encode(42); // 0x2a00
getU32Codec().encode(42); // 0x2a000000
getU64Codec().encode(42); // 0x2a00000000000000
getU128Codec().encode(42); // 0x2a000000000000000000000000000000

// Signed integers.
getI8Codec().encode(-42); // 0xd6
getI16Codec().encode(-42); // 0xd6ff
getI32Codec().encode(-42); // 0xd6ffffff
getI64Codec().encode(-42); // 0xd6ffffffffffffff
getI128Codec().encode(-42); // 0xd6ffffffffffffffffffffffffffffff
```

By default, integers are stored using little endianness but you may change this behaviour via the `endian` option. This option is available for every codec that uses more than a single byte.

```ts
// Big-endian unsigned integers.
getU16Codec({ endian: Endian.Big }).encode(42); // 0x002a
getU32Codec({ endian: Endian.Big }).encode(42); // 0x0000002a
getU64Codec({ endian: Endian.Big }).encode(42); // 0x000000000000002a
getU128Codec({ endian: Endian.Big }).encode(42); // 0x0000000000000000000000000000002a

// Big-endian signed integers.
getI16Codec({ endian: Endian.Big }).encode(-42); // 0xffd6
getI32Codec({ endian: Endian.Big }).encode(-42); // 0xffffffd6
getI64Codec({ endian: Endian.Big }).encode(-42); // 0xffffffffffffffd6
getI128Codec({ endian: Endian.Big }).encode(-42); // 0xffffffffffffffffffffffffffffffd6
```

All integer codecs are of type `Codec<number>` except for the `u64`, `u128`, `i64` and `i128` codecs which are of type `Codec<number | bigint, bigint>`. This means we can provide either a `number` of a `bigint` value to encode but the decoded value will always be a `bigint`. This is because JavaScript's native `number` type does not support numbers larger than `2^53 - 1` and these large integer codecs have the potential to go over that value.

```ts
const bytesFromNumber = getU64Codec().encode(42);
getU64Codec().decode(bytesFromNumber); // BigInt(42)

// OR
const bytesFromBigInt = getU64Codec().encode(BigInt(42));
getU64Codec().decode(bytesFromBigInt); // BigInt(42)
```

Finally, for each of these `get*Codec` functions, separate `get*Encoder` and `get*Decoder` functions exist to focus on only one side of the serialization and tree-shake the rest of the functions away.

```ts
const bytes = getU8Encoder().encode(42);
const value = getU8Decoder().decode(bytes);
```

## Decimal number codecs

This package also provides two codecs for floating numbers. One using 32 bits and one using 64 bits.

```ts
getF32Codec().encode(-1.5); // 0x0000c0bf
getF64Codec().encode(-1.5); // 0x000000000000f8bf
```

Similarly to the integer codecs, they are stored in little-endian by default but may be stored in big-endian using the `endian` option.

```ts
getF32Codec({ endian: Endian.Big }).encode(-1.5); // 0xbfc00000
getF64Codec({ endian: Endian.Big }).encode(-1.5); // 0xbff8000000000000
```

Note that based on the selected codec, some of the precision of the number you are encoding may be lost when decoding it. For instance, when storing `3.1415` using a `f32` codec, you will not get the exact same number back.

```ts
const bytes = getF32Codec().encode(3.1415); // 0x560e4940
const value = getF32Codec().decode(bytes); // 3.1414999961853027 !== 3.1415
```

As usual, separate encoder and decoder functions are available for these codecs.

```ts
getF32Encoder().encode(-1.5);
getF32Decoder().decode(new Uint8Array([...]));

getF64Encoder().encode(-1.5);
getF64Decoder().decode(new Uint8Array([...]));
```

## Short u16 codec

This last integer codec is less common `VariableSizeCodec` that stores an unsigned integer using between 1 to 3 bytes depending on the value of that integer.

```ts
const bytes = getShortU16Codec().encode(42); // 0x2a
const value = getShortU16Codec().decode(bytes); // 42
```

If the provided integer is equal to or lower than `0x7f`, it will be stored as-is, using a single byte. However, if the integer is above `0x7f`, then the top bit is set and the remaining value is stored in the next bytes. Each byte follows the same pattern until the third byte. The third byte, if needed, uses all 8 bits to store the last byte of the original value.

In other words, this codec provides an extendable size that adapts based on the integer. In the illustration below, you can see the `0` and `1` byte flags for each scenario as well as the available bits to store the integer marked with `X`.

```
0XXXXXXX <- From 0 to 127.
1XXXXXXX 0XXXXXXX <- From 128 to 16,383.
1XXXXXXX 1XXXXXXX XXXXXXXX <- From 16,384 to 4,194,303.
```

This codec is mainly used internally when encoding and decoding Solana transactions.

Separate encoder and decoder functions are also available via `getShortU16Encoder` and `getShortU16Decoder` respectively.

---

To read more about the available codecs and how to use them, check out the documentation of the main [`@solana/codecs` package](https://github.com/anza-xyz/kit/tree/main/packages/codecs).
````

### JavaScript package that extends a monorepo

````markdown
# Codama ➤ Renderers ➤ JavaScript

[![npm][npm-image]][npm-url]
[![npm-downloads][npm-downloads-image]][npm-url]

[npm-downloads-image]: https://img.shields.io/npm/dm/@codama/renderers-js.svg?style=flat
[npm-image]: https://img.shields.io/npm/v/@codama/renderers-js.svg?style=flat&label=%40codama%2Frenderers-js
[npm-url]: https://www.npmjs.com/package/@codama/renderers-js

This package generates JavaScript clients from your Codama IDLs. The generated clients are compatible with [`@solana/kit`](https://github.com/anza-xyz/kit).

## Installation

```sh
pnpm install @codama/renderers-js
```

## Usage

Add the following script to your Codama configuration file.

```json
{
  "scripts": {
    "js": {
      "from": "@codama/renderers-js",
      "args": ["clients/js/src/generated"]
    }
  }
}
```

An object can be passed as a second argument to further configure the renderer. See the [Options](#options) section below for more details.

## Options

The `renderVisitor` accepts the following options.

| Name                          | Type                                                                                                                    | Default | Description                                                                                                                                                                                                                                                                               |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deleteFolderBeforeRendering` | `boolean`                                                                                                               | `true`  | Whether the base directory should be cleaned before generating new files.                                                                                                                                                                                                                 |
| `formatCode`                  | `boolean`                                                                                                               | `true`  | Whether we should use Prettier to format the generated code.                                                                                                                                                                                                                              |
| `prettierOptions`             | `PrettierOptions`                                                                                                       | `{}`    | The options to use when formatting the code using Prettier.                                                                                                                                                                                                                               |
| `asyncResolvers`              | `string[]`                                                                                                              | `[]`    | The exhaustive list of `ResolverValueNode`'s names whose implementation is asynchronous in JavaScript.                                                                                                                                                                                    |
| `customAccountData`           | `string[]`                                                                                                              | `[]`    | The names of all `AccountNodes` whose data should be manually written in JavaScript.                                                                                                                                                                                                      |
| `customInstructionData`       | `string[]`                                                                                                              | `[]`    | The names of all `InstructionNodes` whose data should be manually written in JavaScript.                                                                                                                                                                                                  |
| `linkOverrides`               | `Record<'accounts' \| 'definedTypes' \| 'instructions' \| 'pdas' \| 'programs' \| 'resolvers', Record<string, string>>` | `{}`    | A object that overrides the import path of link nodes. For instance, `{ definedTypes: { counter: 'hooked' } }` uses the `hooked` folder to import any link node referring to the `counter` type.                                                                                          |
| `dependencyMap`               | `Record<string, string>`                                                                                                | `{}`    | A mapping between import aliases and their actual package name or path in JavaScript.                                                                                                                                                                                                     |
| `dependencyVersions`          | `Record<string, string>`                                                                                                | `{}`    | A mapping between external package names — e.g. `@solana/kit` — and the version range we should use for them — e.g. `^5.0.0`. The renderer offers default values for all external dependencies it relies on but this option may be used to override some of these values or add new ones. |
| `internalNodes`               | `string[]`                                                                                                              | `[]`    | The names of all nodes that should be generated but not exported by the `index.ts` files.                                                                                                                                                                                                 |
| `nameTransformers`            | `Partial<NameTransformers>`                                                                                             | `{}`    | An object that enables us to override the names of any generated type, constant or function.                                                                                                                                                                                              |
| `nonScalarEnums`              | `string[]`                                                                                                              | `[]`    | The names of enum variants with no data that should be treated as a data union instead of a native `enum` type. This is only useful if you are referencing an enum value in your Codama IDL.                                                                                              |
| `renderParentInstructions`    | `boolean`                                                                                                               | `false` | When using nested instructions, whether the parent instructions should also be rendered. When set to `false` (default), only the instruction leaves are being rendered.                                                                                                                   |
| `useGranularImports`          | `boolean`                                                                                                               | `false` | Whether to import the `@solana/kit` library using sub-packages such as `@solana/addresses` or `@solana/codecs-strings`. When set to `true`, the main `@solana/kit` library is used which enables generated clients to install it as a `peerDependency`.                                   |
| `syncPackageJson`             | `boolean`                                                                                                               | `false` | Whether to update the dependencies of the existing `package.json` — or create a new `package.json` when missing — at the provided `packageFolder` option if provided.                                                                                                                     |
| `packageFolder`               | `string`                                                                                                                |         | The package folder of the generated JS client — i.e. where the `package.json` lives. Note that this option must be provided for the `syncPackageJson` option to work.                                                                                                                     |
````

## Process

1. Determine the target README path:

   - If `$1` is provided and ends with `.md`, use it directly.
   - If `$1` is a directory path, use `$1/README.md`.
   - If `$1` is not provided, use `./README.md`.

2. Check if the README exists:

   - If it exists, read it to understand the current structure.
   - If it doesn't exist, prepare to create one from scratch.

3. Analyze the project context:

   - Examine `package.json` (if exists) for package name, description, dependencies.
   - Look at the source code to understand what the library does.
   - Identify key exports, main functions, and typical usage patterns.
   - Check for existing tests or examples that show usage.
   - Research any related libraries or frameworks that influence usage.
   - If a README is part of a package inside a monorepo, examine any existing READMEs in the other packages to ensure consistency in style and structure.

4. Create or update the README:

   - **For existing READMEs**: Identify missing sections or areas needing improvement.
   - **For new READMEs**: Build the full structure following the guidelines.
   - Preserve the intro unless improvements are clear.
   - Ensure the Usage section has a strong, clear example.
   - Add or improve deep dive sections as needed.
   - Include realistic code snippets throughout.

5. Present the complete README for review before applying changes.
6. Do not update any real code outside of the README file itself! If you identify errors in the codebase, warn the user about them but do not fix them.
