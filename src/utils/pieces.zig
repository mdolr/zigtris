// A Tetris piece is represented by a symbol (letter) and a shape.
// The shape consists of each unit's coordinates starting from the bottom left corner.
pub const TetrisPiece = struct {
    symbol: u8,
    shape: []const [2]u8,

    pub fn init(symbol: u8, shape: []const [2]u8) TetrisPiece {
        return .{
            .symbol = symbol,
            .shape = shape,
        };
    }

    pub fn get_shape(self: TetrisPiece) []const [2]u8 {
        return self.shape;
    }

    pub fn get_symbol(self: TetrisPiece) u8 {
        return self.symbol;
    }
};

pub const Square: TetrisPiece = .{
    .symbol = 'Q',
    .shape = &[_][2]u8{ .{ 0, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 1, 1 } },
};

pub const Line: TetrisPiece = .{
    .symbol = 'I',
    .shape = &[_][2]u8{ .{ 0, 0 }, .{ 0, 1 }, .{ 0, 2 }, .{ 0, 3 } },
};

pub const T: TetrisPiece = .{
    .symbol = 'T',
    .shape = &[_][2]u8{ .{ 1, 0 }, .{ 1, 1 }, .{ 1, 2 }, .{ 0, 1 } },
};

pub const L: TetrisPiece = .{
    .symbol = 'L',
    .shape = &[_][2]u8{ .{ 2, 0 }, .{ 1, 0 }, .{ 0, 0 }, .{ 0, 1 } },
};

pub const J: TetrisPiece = .{
    .symbol = 'J',
    .shape = &[_][2]u8{ .{ 2, 1 }, .{ 1, 1 }, .{ 0, 1 }, .{ 0, 0 } },
};

pub const Z: TetrisPiece = .{
    .symbol = 'Z',
    .shape = &[_][2]u8{ .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ 0, 2 } },
};

pub const S: TetrisPiece = .{
    .symbol = 'S',
    .shape = &[_][2]u8{ .{ 0, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ 1, 2 } },
};
