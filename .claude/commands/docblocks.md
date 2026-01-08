---
description: Add missing docblocks to exported items in the repository
argument-hint: "[path] [--all]"
---

# Add Missing Docblocks

Scan the specified path (or entire repository if no path given) and add missing docblocks to all exported functions, classes, interfaces, types, and constants.

## Arguments

- `$1` (optional): Path to narrow the scope (e.g., 'src/utils' or 'packages/umi/src')
- `$2` (optional): Use `--all` flag to include non-exported items

## Docblock Style Guidelines

Use JSDoc format with the following conventions:

- Start with `/**` on its own line.
- Use `*` prefix for each line.
- End with `*/` on its own line.
- Keep descriptions concise but complete.
- Start your sentences with a capital letter and end with a period.
- Limit your usage of em dashes (—) but, when you do use them, use spaces on both sides.
- Begin with a clear one or two line summary (no @summary tag needed).
- Add a blank line after the summary if adding more details.
- Include `@param` tags for all parameters.
- Include `@typeParam` tags for all type parameters.
- Include `@return` tag briefly describing the return value.
- Add `@throws` for functions that may throw errors and list these errors.
- Include at least one `@example` section whenever usage examples would be helpful. If the file is a TypeScript file, use TypeScript syntax in examples. Try to make the examples realistic but consise and pleasant to read. They must illustrate the concepts clearly at first glance. When more than one example is preferred, use multiple `@example` tags and keep the first one as simple as possible to illustrate the basic usage. Never use `any` type in examples. Display the `import` statements required for the example to work when imports from multiple libraries are required. It is acceptable to use placeholder variable names like `myUser` or even `/* ... */` for parts that are not relevant to the example. When multiple example sections are provided, add a brief description before each code block to quickly explain what the example illustrates.
- In the rare case where more advanced documentation is also needed for the item, use the `@remarks` tag to add this extra information after any example sections. These remarks can include longer explanations and even additional code blocks if necessary.
- When an item is deprecated, include a `@deprecated` tag with a brief explanation and, if applicable, suggest an alternative.
- Use `{@link ...}` tags to reference other items in the codebase when relevant.
- Add `@see` tags at the very end when applicable to point to other related items or documentation. Use `@see {@link ...}` format when linking to other code items.

## Examples of Good Docblocks

````ts
/**
 * Fixes a `Uint8Array` to the specified length.
 *
 * If the array is longer than the specified length, it is truncated.
 * If the array is shorter than the specified length, it is padded with zeroes.
 *
 * @param bytes - The byte array to truncate or pad.
 * @param length - The desired length of the byte array.
 * @return The byte array truncated or padded to the desired length.
 *
 * @example
 * Truncates the byte array to the desired length.
 * ```ts
 * const bytes = new Uint8Array([0x01, 0x02, 0x03, 0x04]);
 * const fixedBytes = fixBytes(bytes, 2);
 * //    ^ [0x01, 0x02]
 * ```
 *
 * @example
 * Adds zeroes to the end of the byte array to reach the desired length.
 * ```ts
 * const bytes = new Uint8Array([0x01, 0x02]);
 * const fixedBytes = fixBytes(bytes, 4);
 * //    ^ [0x01, 0x02, 0x00, 0x00]
 * ```
 *
 * @example
 * Returns the original byte array if it is already at the desired length.
 * ```ts
 * const bytes = new Uint8Array([0x01, 0x02]);
 * const fixedBytes = fixBytes(bytes, 2);
 * // bytes === fixedBytes
 * ```
 */
export const fixBytes = (
  bytes: ReadonlyUint8Array | Uint8Array,
  length: number
): ReadonlyUint8Array | Uint8Array =>
  padBytes(bytes.length <= length ? bytes : bytes.slice(0, length), length);
````

````ts
/**
 * Returns an encoder for custom objects.
 *
 * This encoder serializes an object by encoding its fields sequentially,
 * using the provided field encoders.
 *
 * For more details, see {@link getStructCodec}.
 *
 * @typeParam TFields - The fields of the struct, each paired with an encoder.
 *
 * @param fields - The name and encoder of each field.
 * @returns A `FixedSizeEncoder` or `VariableSizeEncoder` for encoding custom objects.
 *
 * @example
 * Encoding a custom struct.
 * ```ts
 * const encoder = getStructEncoder([
 *   ['name', fixCodecSize(getUtf8Encoder(), 5)],
 *   ['age', getU8Encoder()]
 * ]);
 *
 * const bytes = encoder.encode({ name: 'Alice', age: 42 });
 * // 0x416c6963652a
 * //   |         └── Age (42)
 * //   └── Name ("Alice")
 * ```
 *
 * @see {@link getStructCodec}
 */
export function getStructEncoder<
  const TFields extends Fields<FixedSizeEncoder<any>>
>(fields: TFields): FixedSizeEncoder<GetEncoderTypeFromFields<TFields>>;
export function getStructEncoder<const TFields extends Fields<Encoder<any>>>(
  fields: TFields
): VariableSizeEncoder<GetEncoderTypeFromFields<TFields>>;
export function getStructEncoder<const TFields extends Fields<Encoder<any>>>(
  fields: TFields
): Encoder<GetEncoderTypeFromFields<TFields>> {
  type TFrom = GetEncoderTypeFromFields<TFields>;
  const fieldCodecs = fields.map(([, codec]) => codec);
  const fixedSize = sumCodecSizes(fieldCodecs.map(getFixedSize));
  const maxSize = sumCodecSizes(fieldCodecs.map(getMaxSize)) ?? undefined;

  return createEncoder({
    ...(fixedSize === null
      ? {
          getSizeFromValue: (value: TFrom) =>
            fields
              .map(([key, codec]) =>
                getEncodedSize(value[key as keyof TFrom], codec)
              )
              .reduce((all, one) => all + one, 0),
          maxSize,
        }
      : { fixedSize }),
    write: (struct: TFrom, bytes, offset) => {
      fields.forEach(([key, codec]) => {
        offset = codec.write(struct[key as keyof TFrom], bytes, offset);
      });
      return offset;
    },
  });
}
````

````ts
/**
 * Returns a codec for encoding and decoding custom objects.
 *
 * This codec serializes objects by encoding and decoding each field sequentially.
 *
 * @typeParam TFields - The fields of the struct, each paired with a codec.
 *
 * @param fields - The name and codec of each field.
 * @returns A `FixedSizeCodec` or `VariableSizeCodec` for encoding and decoding custom objects.
 *
 * @example
 * Encoding and decoding a custom struct.
 * ```ts
 * const codec = getStructCodec([
 *   ['name', fixCodecSize(getUtf8Codec(), 5)],
 *   ['age', getU8Codec()]
 * ]);
 *
 * const bytes = codec.encode({ name: 'Alice', age: 42 });
 * // 0x416c6963652a
 * //   |         └── Age (42)
 * //   └── Name ("Alice")
 *
 * const struct = codec.decode(bytes);
 * // { name: 'Alice', age: 42 }
 * ```
 *
 * @remarks
 * Separate {@link getStructEncoder} and {@link getStructDecoder} functions are available.
 *
 * ```ts
 * const bytes = getStructEncoder([
 *   ['name', fixCodecSize(getUtf8Encoder(), 5)],
 *   ['age', getU8Encoder()]
 * ]).encode({ name: 'Alice', age: 42 });
 *
 * const struct = getStructDecoder([
 *   ['name', fixCodecSize(getUtf8Decoder(), 5)],
 *   ['age', getU8Decoder()]
 * ]).decode(bytes);
 * ```
 *
 * @see {@link getStructEncoder}
 * @see {@link getStructDecoder}
 */
export function getStructCodec<
  const TFields extends Fields<FixedSizeCodec<any>>
>(
  fields: TFields
): FixedSizeCodec<
  GetEncoderTypeFromFields<TFields>,
  GetDecoderTypeFromFields<TFields> & GetEncoderTypeFromFields<TFields>
>;
export function getStructCodec<const TFields extends Fields<Codec<any>>>(
  fields: TFields
): VariableSizeCodec<
  GetEncoderTypeFromFields<TFields>,
  GetDecoderTypeFromFields<TFields> & GetEncoderTypeFromFields<TFields>
>;
export function getStructCodec<const TFields extends Fields<Codec<any>>>(
  fields: TFields
): Codec<
  GetEncoderTypeFromFields<TFields>,
  GetDecoderTypeFromFields<TFields> & GetEncoderTypeFromFields<TFields>
> {
  return combineCodec(
    getStructEncoder(fields),
    getStructDecoder(fields) as Decoder<
      GetDecoderTypeFromFields<TFields> & GetEncoderTypeFromFields<TFields>
    >
  );
}
````

````ts
/**
 * A set of instructions with constraints on how they can be executed.
 *
 * This is structured as a recursive tree of plans in order to allow for
 * parallel execution, sequential execution and combinations of both.
 *
 * Namely the following plans are supported:
 * - {@link SingleInstructionPlan} - A plan that contains a single instruction.
 *   This is a simple instruction wrapper and the simplest leaf in this tree.
 * - {@link ParallelInstructionPlan} - A plan that contains other plans that
 *   can be executed in parallel.
 * - {@link SequentialInstructionPlan} - A plan that contains other plans that
 *   must be executed sequentially. It also defines whether the plan is divisible
 *   meaning that instructions inside it can be split into separate transactions.
 * - {@link MessagePackerInstructionPlan} - A plan that can dynamically pack
 *  instructions into transaction messages.
 *
 * Helpers are provided for each of these plans to make it easier to create them.
 *
 * @example
 * ```ts
 * const myInstructionPlan: InstructionPlan = parallelInstructionPlan([
 *    sequentialInstructionPlan([instructionA, instructionB]),
 *    instructionC,
 *    instructionD,
 * ]);
 * ```
 *
 * @see {@link SingleInstructionPlan}
 * @see {@link ParallelInstructionPlan}
 * @see {@link SequentialInstructionPlan}
 * @see {@link MessagePackerInstructionPlan}
 */
export type InstructionPlan =
  | MessagePackerInstructionPlan
  | ParallelInstructionPlan
  | SequentialInstructionPlan
  | SingleInstructionPlan;
````

````ts
/**
 * A plan wrapping other plans that must be executed sequentially.
 *
 * It also defines whether nested plans are divisible — meaning that
 * the instructions inside them can be split into separate transactions.
 * When `divisible` is `false`, the instructions inside the plan should
 * all be executed atomically — either in a single transaction or in a
 * transaction bundle.
 *
 * You may use the {@link sequentialInstructionPlan} and {@link nonDivisibleSequentialInstructionPlan}
 * helpers to create objects of this type.
 *
 * @example Simple sequential plan with two instructions.
 * ```ts
 * const plan = sequentialInstructionPlan([instructionA, instructionB]);
 * plan satisfies SequentialInstructionPlan;
 * ```
 *
 * @example Non-divisible sequential plan with two instructions.
 * ```ts
 * const plan = nonDivisibleSequentialInstructionPlan([instructionA, instructionB]);
 * plan satisfies SequentialInstructionPlan & { divisible: false };
 * ```
 *
 * @example Sequential plan with nested parallel plans.
 * Here, instructions A and B can be executed in parallel, but they must both be finalized
 * before instructions C and D can be sent — which can also be executed in parallel.
 * ```ts
 * const plan = sequentialInstructionPlan([
 *   parallelInstructionPlan([instructionA, instructionB]),
 *   parallelInstructionPlan([instructionC, instructionD]),
 * ]);
 * plan satisfies SequentialInstructionPlan & { divisible: false };
 * ```
 *
 * @see {@link sequentialInstructionPlan}
 * @see {@link nonDivisibleSequentialInstructionPlan}
 */
export type SequentialInstructionPlan = Readonly<{
  divisible: boolean;
  kind: "sequential";
  plans: InstructionPlan[];
}>;
````

```ts
/**
 * Plans one or more transactions according to the provided instruction plan.
 *
 * @param instructionPlan - The instruction plan to be planned and executed.
 * @param config - Optional configuration object that can include an `AbortSignal` to cancel the planning process.
 * @return A promise that resolves to the planned transactions.
 *
 * @see {@link InstructionPlan}
 * @see {@link TransactionPlan}
 */
export type TransactionPlanner = (
  instructionPlan: InstructionPlan,
  config?: { abortSignal?: AbortSignal }
) => Promise<TransactionPlan>;
```

## Process

1. If `$1` is provided, scan only that path; otherwise scan the entire repository.
2. Look for TypeScript/JavaScript files (`.ts`, `.tsx`, `.js`, `.jsx`).
3. Identify exported items without docblocks:
   - `export function`
   - `export class`
   - `export interface`
   - `export type`
   - `export const` (for constants and arrow functions)
4. If `$2` equals `--all`, also identify non-exported items.
5. Do not modify real code outside of docblocks! Do not modify existing docblocks!
6. For each item missing a docblock:
   - Analyze the code to understand its purpose (this may span multiple files).
   - Examine parameters, return types, and behavior.
   - Generate an appropriate docblock following the style guide.
7. Present all changes clearly, grouped by file. Apply all changes without requiring further approval.
