# zigtris

A tetris engine written in Zig

## Requirements

- Zig 0.13.0

## Building

I've attached a pre-built executables for different platforms (Mac Apple silicon, Windows, Linux x86) in the `zig-out/bin` directory, you can use them directly if you want or you can build your own with:

```sh
zig build
```

The executable will be placed in the `zig-out/bin` directory as `tetris`.

## Running

```sh
# for convenience you can move the executable corresponding to your version if you want by doing
mv zig-out/bin/tetris_aarch64-macos ./tetris

# and then invoke it as
./tetris <input_file_path> <output_file_path>
# e.g:
./tetris ./inputs/input1.txt ./outputs/output.txt

# note without moving you can also invoke directly as
./zig-out/bin/tetris_x86_64-linux-gnu <input_file_path> <output_file_path>
```

## Approach

Went for an "object-oriented programming" approach, each piece is defined by a shape inherited from a default piece, then there is a grid that has all the functions to place pieces at the correct position and check line completions.
