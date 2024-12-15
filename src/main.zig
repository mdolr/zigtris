const std = @import("std");

const grid = @import("./utils/grid.zig");
const pieces = @import("./utils/pieces.zig");

// A function that parses command line arguments and returns
// the input and output file paths.
pub fn get_args(allocator: *const std.mem.Allocator) !struct {
    input_path: []const u8,
    output_path: []const u8,
} {
    const args = try std.process.argsAlloc(allocator.*);
    defer std.process.argsFree(allocator.*, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <input_file> <output_file>\n", .{args[0]});
        return error.InvalidArguments;
    }

    // Dupe the input and output arguments so they can be returned without
    // needing to worry about the lifetime of the original arguments.
    const input_path = try allocator.*.dupe(u8, args[1]);
    const output_path = try allocator.*.dupe(u8, args[2]);

    return .{
        .input_path = input_path,
        .output_path = output_path,
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try get_args(&allocator);

    const input_path = args.input_path;
    const output_path = args.output_path;

    std.debug.print("Input path raw: {s}\n", .{input_path});
    std.debug.print("Output path raw: {s}\n", .{output_path});

    // Initialize a matrix to represent the Tetris grid
    // of height = 100 and width = 10
    // as pointed out in the subject we assume a height of 100 as it's said that no test cases
    // will exceed this height, however we could make this dynamic if needed

    const height: u8 = 100;
    const width: u8 = 10;

    var tetris_grid = try grid.Grid.init(height, width, &allocator);

    // open the file, split by "," and print each element
    var file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    // create a buffered reader to read the file
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // set the buffer size to 16 bytes as we know each element is relatively small by
    // being composed of a letter and a number between 0 and 9
    var buf: [16]u8 = undefined;

    // read the file using "," as a delimiter then iterate over each element
    while (try in_stream.readUntilDelimiterOrEof(&buf, ',')) |elem| {

        // each element is composed of a letter and a number
        // the letter indicating the type of piece it is and the number indicating the starting column
        const letter = elem[0];

        // convert the column number to an integer by using - '0' to remove the ASCII offset
        // and get the actual integer value representing the column
        // it's a bit hacky, we could also use std.fmt.parseInt to parse the number
        const column = elem[1] - '0';

        // in case the column is out of bounds we print an error message and skip to the next element
        if (column < 0 or column >= width) {
            std.debug.print("Invalid column: {d}\n", .{column});
            continue;
        }

        switch (letter) {
            'Q' => {
                var piece = pieces.Square;
                tetris_grid.set_piece(&piece, column);
            },
            'I' => {
                var piece = pieces.Line;
                tetris_grid.set_piece(&piece, column);
            },
            'T' => {
                var piece = pieces.T;
                tetris_grid.set_piece(&piece, column);
            },
            'L' => {
                var piece = pieces.L;
                tetris_grid.set_piece(&piece, column);
            },
            'J' => {
                var piece = pieces.J;
                tetris_grid.set_piece(&piece, column);
            },
            'Z' => {
                var piece = pieces.Z;
                tetris_grid.set_piece(&piece, column);
            },
            'S' => {
                var piece = pieces.S;
                tetris_grid.set_piece(&piece, column);
            },
            else => {
                std.debug.print("Invalid piece: {c}\n", .{letter});
            },
        }
    }

    try tetris_grid.output(output_path);
    defer tetris_grid.deinit(&allocator);
}
