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

    // the output functino takes an output path and outputs the
    // max height of the height cache as the total height of the
    // grid after all the pieces have been placed and full rows
    // have been completed
    pub fn output(self: *Grid, output_path: []const u8) !void {
        const file = try std.fs.cwd().createFile(output_path, .{});
        defer file.close();

        const writer = file.writer();
        var buf_writer = std.io.bufferedWriter(writer);

        var max_height: usize = 0;

        // start at 0 in case the grid is empty
        var current_row: usize = 0;
        var col: usize = 0;

        // loop from bottom to top once we encounter an empty row we break
        // and return the max height
        while (current_row < self.height) : (current_row += 1) {
            col = 0;
            var empty_row = true;

            while (col < self.width) : (col += 1) {
                if (self.get_cell(current_row, col) != 0) {
                    empty_row = false;
                    break;
                }
            }

            if (!empty_row) {
                // because the first row is 0 we offset height as current_row + 1
                max_height = current_row + 1;
            } else {
                break;
            }
        }

        // Write the maximum height to the file
        try buf_writer.writer().print("{d}\n", .{max_height});
        std.debug.print("Max height: {}\n", .{max_height});

        // Flush the buffered writer to ensure the value is written
        try buf_writer.flush();
    }
};
