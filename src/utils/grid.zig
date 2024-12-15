const std = @import("std");
const pieces = @import("./pieces.zig");

pub const Grid = struct {
    height: usize,
    width: usize,
    cells: [][]u8,
    heights_cache: []usize, // a cache to store the current max height of each column

    pub fn init(height: usize, width: usize, allocator: *const std.mem.Allocator) !Grid {
        // Allocate memory for row pointers
        const rows = try allocator.alloc([]u8, height);

        // Initialize each row as a slice
        for (rows) |*row| {
            row.* = try allocator.alloc(u8, width);

            // Set all cells in the row to 0
            for (row.*) |*cell| {
                cell.* = 0;
            }
        }

        const heights_cache = try allocator.alloc(usize, width);

        for (0..width) |i| {
            heights_cache[i] = 0;
        }

        return .{
            .height = height,
            .width = width,
            .cells = rows,
            .heights_cache = heights_cache,
        };
    }

    pub fn deinit(self: *Grid, allocator: *const std.mem.Allocator) void {
        allocator.free(self.cells);
    }

    pub fn get_cell(self: *Grid, row: usize, col: usize) u8 {
        return self.cells[row][col];
    }

    pub fn set_cell(self: *Grid, row: usize, col: usize, value: u8) void {
        self.cells[row][col] = value;
    }

    // Check completion of rows
    pub fn check(self: *Grid) !void {
        var row: usize = 0;
        var col: u32 = 0;

        // start from the bottom and go up
        while (row < self.height) : (row += 1) {
            col = 0;

            var full = true;

            while (col < self.width) : (col += 1) {
                if (self.get_cell(row, col) == 0) {
                    full = false;
                    break;
                }
            }

            // if the row is not full we skip to next iteration (1 row up)
            if (!full) {
                continue;
            }

            // if the row is full we remove it and move all the rows above it one row down
            col = 0;

            while (col < self.width) : (col += 1) {
                for (row..self.height - 1) |r| {
                    self.set_cell(r, col, self.get_cell(r + 1, col));
                }

                // set the top row to 0
                self.set_cell(self.height - 1, col, 0);

                if (self.heights_cache[col] > 0)
                    self.heights_cache[col] -= 1;
            }
        }
    }

    // the set_piece function takes a TetrisPiece, a starting column (of the top left pixel of the piece)
    // then finds the first available cell at which it can be placed so that it doesn't overlap with any other piece
    // and places it there
    pub fn set_piece(self: *Grid, piece: *pieces.TetrisPiece, col: usize) void {
        const shape = piece.get_shape();
        const symbol = piece.get_symbol();

        // find the first available row to place the piece
        // starting from the first available row in that column
        var row: usize = self.heights_cache[col];

        // iterate over all rows in the grid starting from 0
        while (row < self.height) {
            // at first we assume there is no collision for that position (row, col)
            var collision = false;

            // we check for every unit/pixel in the piece if it's position is already occupied
            for (shape) |unit| {
                const unit_row: usize = row + unit[0];
                const unit_col: usize = col + unit[1];

                // if it's already occupied we set collision to true then
                // we skip to checking the row above
                if (self.get_cell(unit_row, unit_col) != 0) {
                    collision = true;
                }
            }

            // if there is collision we check the (row + 1, col) starting position
            if (collision) {
                row += 1;
            }

            // else we place our piece at the current starting position
            else {
                for (shape) |unit| {
                    const unit_row = row + unit[0];
                    const unit_col = col + unit[1];

                    // set the cell to the symbol of the piece
                    self.set_cell(unit_row, unit_col, symbol);

                    // update the height cache for that column if it's one of the upper pixels in the shape
                    if (unit_row > self.heights_cache[unit_col]) {
                        self.heights_cache[unit_col] = unit_row;
                    }
                }

                try self.check();
                break;
            }
        }
    }

    // the output functino takes an output path and writes the grid to a file
    // the grid is written as a matrix of characters
    // lines are rendered from top to bottom
    // however lines full of 0s are not written
    pub fn output(self: *Grid, output_path: []const u8) !void {
        // Open the file for writing
        const file = try std.fs.cwd().createFile(output_path, .{});
        defer file.close();

        const writer = file.writer();
        var buf_writer = std.io.bufferedWriter(writer);

        var row: usize = self.height;
        var col: u32 = 0;

        // Loop through rows from `self.height` down to 0
        while (row > 0) : (row -= 1) {
            var empty_row = true;

            col = 0;
            while (col < self.width) : (col += 1) {
                const cell = self.get_cell(row - 1, col);

                // Check if the row has any non-zero cell
                if (cell != 0) {
                    empty_row = false;
                    break; // Exit the loop early if a non-zero cell is found
                }
            }

            // If the row is not empty, write it to the file
            if (!empty_row) {
                col = 0;
                while (col < self.width) : (col += 1) {
                    const cell = self.get_cell(row - 1, col);
                    const char = if (cell != 0) cell else ' ';

                    try buf_writer.writer().print("{c}", .{char});
                }

                if (row > 1) {
                    // Add a newline after each row except the last one
                    try buf_writer.writer().print("\n", .{});
                }
            }
        }

        // Flush the buffered writer to ensure all data is written to the file
        try buf_writer.flush();
    }
};
