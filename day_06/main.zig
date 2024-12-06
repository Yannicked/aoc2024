const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const obstacle = enum { right };
const point = struct { x: i64, y: i64 };

fn add(a: point, b: point) point {
    return .{ .x = a.x + b.x, .y = a.y + b.y };
}

fn rot90(a: point) point {
    return .{ .x = -a.y, .y = a.x };
}

fn test_path(_guard_position: point, _guard_direction: point, border: point, obstacles: std.AutoHashMap(point, obstacle)) !bool {
    var guard_position: point = _guard_position;
    var guard_direction: point = _guard_direction;
    var touched_points = std.AutoHashMap(point, point).init(allocator);
    defer touched_points.deinit();
    while (true) {
        while (true) {
            const nextpos = add(guard_position, guard_direction);
            if (obstacles.contains(nextpos)) {
                guard_direction = rot90(guard_direction);
            } else {
                // print("Moving to: {any}\n", .{guard_position});
                guard_position = nextpos;
                break;
            }
        }
        if (touched_points.get(guard_position)) |dir| {
            if (dir.x == guard_direction.x and dir.y == guard_direction.y) {
                // print("{any}\n", .{guard_position});
                return false;
            }
        }
        try touched_points.put(guard_position, guard_direction);
        if (guard_position.x < 0 or guard_position.y < 0 or guard_position.x >= border.x or guard_position.y >= border.y) {
            break;
        }
    }
    return true;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var obstacles = std.AutoHashMap(point, obstacle).init(allocator);
    var touched_points = std.AutoHashMap(point, bool).init(allocator);
    var y: i64 = 0;
    var guard_position: point = .{ .x = 0, .y = 0 };
    var guard_direction: point = .{ .x = 0, .y = 0 };
    var x: i64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        // print("{s}\n", .{line});
        for (line, 0..line.len) |char, i| {
            if (char == '#') {
                try obstacles.put(.{ .x = @intCast(i), .y = y }, obstacle.right);
                // print("Obstacle: {any}\n", .{point{ .x = @intCast(i), .y = y }});
            } else if (char == '^') {
                guard_position = .{ .x = @intCast(i), .y = y };
                guard_direction = .{ .x = 0, .y = -1 };
            }
        }
        y += 1;
        x = @intCast(line.len);
    }
    while (true) {
        // print("Pos: {any}, dir: {any}\n", .{ guard_position, guard_direction });
        try touched_points.put(guard_position, true);
        while (true) {
            const nextpos = add(guard_position, guard_direction);
            if (obstacles.contains(nextpos)) {
                guard_direction = rot90(guard_direction);
            } else {
                guard_position = add(guard_position, guard_direction);
                break;
            }
        }
        if (guard_position.x < 0 or guard_position.y < 0 or guard_position.x >= x or guard_position.y >= y) {
            break;
        }
    }
    var key_it = touched_points.keyIterator();
    var t: u64 = 0;
    while (key_it.next()) |_| {
        t += 1;
    }
    return t;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var obstacles = std.AutoHashMap(point, obstacle).init(allocator);
    var border: point = .{ .x = 0, .y = 0 };
    var guard_position: point = .{ .x = 0, .y = 0 };
    var guard_direction: point = .{ .x = 0, .y = 0 };
    while (it.next()) |line| {
        if (line.len == 0) break;
        // print("{s}\n", .{line});
        for (line, 0..line.len) |char, i| {
            if (char == '#') {
                try obstacles.put(.{ .x = @intCast(i), .y = border.y }, obstacle.right);
                // print("Obstacle: {any}\n", .{point{ .x = @intCast(i), .y = y }});
            } else if (char == '^') {
                guard_position = .{ .x = @intCast(i), .y = border.y };
                guard_direction = .{ .x = 0, .y = -1 };
            }
        }
        border.y += 1;
        border.x = @intCast(line.len);
    }

    var b: u64 = 0;
    for (0..@intCast(border.x)) |x| {
        for (0..@intCast(border.y)) |y| {
            const p: point = .{ .x = @intCast(x), .y = @intCast(y) };
            if (obstacles.contains(p)) continue;
            try obstacles.put(p, obstacle.right);
            if (!try test_path(guard_position, guard_direction, border, obstacles)) {
                print("{any}\n", .{p});
                b += 1;
            }
            _ = obstacles.remove(p);
        }
    }
    return b;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    const one = try part1(input);
    print("Part 1: {}\n", .{one});
    const b = try part2(input);
    print("Part 2: {}\n", .{b});
}

test "Part 1 - sample" {
    const input = @embedFile("sample.txt");
    const a = try part1(input);
    try std.testing.expect(a == 41);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const a = try part2(input);
    try std.testing.expect(a == 6);
}
