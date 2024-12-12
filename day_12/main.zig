const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const region = struct { area: i64, perimeter: i64 };

fn add(a: region, b: region) region {
    return .{ .area = a.area + b.area, .perimeter = a.perimeter + b.perimeter };
}

const point = struct { x: usize, y: usize };

fn consume_point(cur: point, grid: *std.ArrayList(std.ArrayList(u8))) region {
    const c = grid.items[cur.y].items[cur.x];
    var r = region{ .area = 1, .perimeter = 4 };
    if (cur.y > 0) {
        if (grid.items[cur.y - 1].items[cur.x] == c) {
            r.perimeter -= 2;
        }
    }
    if (cur.y < grid.items.len - 1) {
        if (grid.items[cur.y + 1].items[cur.x] == c) {
            r.perimeter -= 2;
        }
    }

    if (cur.x > 0) {
        if (grid.items[cur.y].items[cur.x - 1] == c) {
            r.perimeter -= 2;
        }
    }

    if (cur.x < grid.items[cur.y].items.len - 1) {
        if (grid.items[cur.y].items[cur.x + 1] == c) {
            r.perimeter -= 2;
        }
    }
    grid.items[cur.y].items[cur.x] = '.';
    if (cur.y > 0) {
        if (grid.items[cur.y - 1].items[cur.x] == c) {
            r = add(r, consume_point(.{ .x = cur.x, .y = cur.y - 1 }, grid));
        }
    }
    if (cur.y < grid.items.len - 1) {
        if (grid.items[cur.y + 1].items[cur.x] == c) {
            r = add(r, consume_point(.{ .x = cur.x, .y = cur.y + 1 }, grid));
        }
    }

    if (cur.x > 0) {
        if (grid.items[cur.y].items[cur.x - 1] == c) {
            r = add(r, consume_point(.{ .x = cur.x - 1, .y = cur.y }, grid));
        }
    }

    if (cur.x < grid.items[cur.y].items.len - 1) {
        if (grid.items[cur.y].items[cur.x + 1] == c) {
            r = add(r, consume_point(.{ .x = cur.x + 1, .y = cur.y }, grid));
        }
    }

    return r;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    defer {
        for (grid.items) |line| {
            line.deinit();
        }
    }
    while (it.next()) |line| {
        if (line.len == 0) break;
        var l = std.ArrayList(u8).init(allocator);
        for (line) |char| {
            try l.append(char);
        }
        try grid.append(l);
    }
    var total: u64 = 0;
    for (grid.items, 0..grid.items.len) |g, y| {
        for (g.items, 0..g.items.len) |c, x| {
            if (c == '.') continue;
            const r = consume_point(.{ .x = x, .y = y }, &grid);
            total += @intCast(r.area * r.perimeter);
        }
    }
    return total;
}

fn calculate_sides(cur: point, grid: *std.ArrayList(std.ArrayList(u8))) i64 {
    const c = grid.items[cur.y].items[cur.x];
    if (c != '.') return 0;

    // l+t+b

    const xsize = grid.items[cur.y].items.len;
    const ysize = grid.items.len;

    var edges: i64 = 0;
    const left = if (cur.x == 0) false else grid.items[cur.y].items[cur.x - 1] == '.';
    const right = if (cur.x == xsize - 1) false else grid.items[cur.y].items[cur.x + 1] == '.';
    const top = if (cur.y == 0) false else grid.items[cur.y - 1].items[cur.x] == '.';
    const bottom = if (cur.y == ysize - 1) false else grid.items[cur.y + 1].items[cur.x] == '.';
    const topleft = if (cur.x == 0 or cur.y == 0) false else grid.items[cur.y - 1].items[cur.x - 1] == '.';
    const topright = if (cur.x == xsize - 1 or cur.y == 0) false else grid.items[cur.y - 1].items[cur.x + 1] == '.';
    const bottomleft = if (cur.x == 0 or cur.y == ysize - 1) false else grid.items[cur.y + 1].items[cur.x - 1] == '.';

    // Add new top edge
    if (!top and !left) {
        edges += 1;
    }
    if (topleft and !top and left) {
        edges += 1;
    }
    // Add new bottom edge
    if (!bottom and !left) {
        edges += 1;
    }
    if (!bottom and left and bottomleft) {
        edges += 1;
    }
    // Add new left edge
    if (!left and !top) {
        edges += 1;
    }
    if (topleft and top and !left) {
        edges += 1;
    }
    // add new right edge
    if (!right and !top) {
        edges += 1;
    }
    if (!right and top and topright) {
        edges += 1;
    }
    return edges;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    defer {
        for (grid.items) |line| {
            line.deinit();
        }
    }
    while (it.next()) |line| {
        if (line.len == 0) break;
        var l = std.ArrayList(u8).init(allocator);
        for (line) |char| {
            try l.append(char);
        }
        try grid.append(l);
    }
    var total: u64 = 0;
    for (grid.items, 0..grid.items.len) |g, y| {
        for (g.items, 0..g.items.len) |c, x| {
            if (c == '.' or c == '#') continue;
            const curpoint = point{ .x = x, .y = y };
            const r = consume_point(curpoint, &grid);
            var blobsides: i64 = 0;
            for (0..grid.items.len) |y2| {
                for (0..g.items.len) |x2| {
                    if (grid.items[y2].items[x2] == '.') {
                        const curpoint2 = point{ .x = x2, .y = y2 };
                        const sides = calculate_sides(curpoint2, &grid);
                        blobsides += sides;
                    }
                }
            }
            for (0..grid.items.len) |y2| {
                for (0..g.items.len) |x2| {
                    if (grid.items[y2].items[x2] == '.') {
                        grid.items[y2].items[x2] = '#';
                    }
                }
            }
            total += @intCast(r.area * blobsides);
        }
    }
    return total;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    const one = try part1(input);
    print("Part 1: {}\n", .{one});
    const two = try part2(input);
    print("Part 2: {}\n", .{two});
}

test "Part 1 - sample" {
    const input = @embedFile("sample.txt");
    const one = try part1(input);
    try std.testing.expect(one == 1930);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const two = try part2(input);
    try std.testing.expect(two == 1206);
}
