const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const vector = struct {
    x: i64,
    y: i64,
};

fn add(a: vector, b: vector) vector {
    return .{ .x = a.x + b.x, .y = a.y + b.y };
}

fn subtract(a: vector, b: vector) vector {
    return .{ .x = a.x - b.x, .y = a.y - b.y };
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var antennas = std.AutoHashMap(u8, std.ArrayList(vector)).init(allocator);
    defer antennas.deinit();
    defer {
        var val_it = antennas.valueIterator();
        while (val_it.next()) |val| {
            val.deinit();
        }
    }
    var y: i64 = 0;
    var max_x: i64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..line.len) |char, x| {
            if (char != '.') {
                const a = try antennas.getOrPut(char);
                if (!a.found_existing) {
                    a.value_ptr.* = std.ArrayList(vector).init(allocator);
                }
                try a.value_ptr.*.append(.{ .x = @intCast(x), .y = y });
            }
        }
        y += 1;
        max_x = @intCast(line.len);
    }

    var antinodes = std.AutoHashMap(vector, usize).init(allocator);
    defer antinodes.deinit();

    var key_it = antennas.keyIterator();
    while (key_it.next()) |key| {
        const antennalist = antennas.get(key.*).?.items;
        for (0..antennalist.len - 1) |i| {
            for (i + 1..antennalist.len) |j| {
                const point1 = antennalist[i];
                const point2 = antennalist[j];
                const diff = subtract(point1, point2);
                const antinode1 = add(point1, diff);
                const antinode2 = subtract(point2, diff);
                if (-1 < antinode1.x and antinode1.x < max_x and -1 < antinode1.y and antinode1.y < y) {
                    try antinodes.put(antinode1, 1);
                }
                if (-1 < antinode2.x and antinode2.x < max_x and -1 < antinode2.y and antinode2.y < y) {
                    try antinodes.put(antinode2, 1);
                }
            }
        }
    }
    var antinode_it = antinodes.keyIterator();

    var total: u64 = 0;
    while (antinode_it.next()) |_| {
        total += 1;
    }
    return total;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var antennas = std.AutoHashMap(u8, std.ArrayList(vector)).init(allocator);
    defer antennas.deinit();
    defer {
        var val_it = antennas.valueIterator();
        while (val_it.next()) |val| {
            val.deinit();
        }
    }
    var y: i64 = 0;
    var max_x: i64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..line.len) |char, x| {
            if (char != '.') {
                const a = try antennas.getOrPut(char);
                if (!a.found_existing) {
                    a.value_ptr.* = std.ArrayList(vector).init(allocator);
                }
                try a.value_ptr.*.append(.{ .x = @intCast(x), .y = y });
            }
        }
        y += 1;
        max_x = @intCast(line.len);
    }

    var antinodes = std.AutoHashMap(vector, usize).init(allocator);
    defer antinodes.deinit();

    var key_it = antennas.keyIterator();
    while (key_it.next()) |key| {
        const antennalist = antennas.get(key.*).?.items;
        for (0..antennalist.len - 1) |i| {
            for (i + 1..antennalist.len) |j| {
                const point1 = antennalist[i];
                const point2 = antennalist[j];
                // The antennas are now also antinodes
                try antinodes.put(point1, 1);
                try antinodes.put(point2, 1);

                const diff = subtract(point1, point2);
                var antinode1 = add(point1, diff);
                var antinode2 = subtract(point2, diff);
                while (-1 < antinode1.x and antinode1.x < max_x and -1 < antinode1.y and antinode1.y < y) {
                    try antinodes.put(antinode1, 1);
                    antinode1 = add(antinode1, diff);
                }
                while (-1 < antinode2.x and antinode2.x < max_x and -1 < antinode2.y and antinode2.y < y) {
                    try antinodes.put(antinode2, 1);
                    antinode2 = subtract(antinode2, diff);
                }
            }
        }
    }
    var antinode_it = antinodes.keyIterator();

    var total: u64 = 0;
    while (antinode_it.next()) |_| {
        // print("({}, {})\n", .{ a.*.x, a.*.y });
        total += 1;
    }
    return total;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    const a = try part1(input);
    print("Part 1: {}\n", .{a});
    const b = try part2(input);
    print("Part 2: {}\n", .{b});
}

test "Part 1 - sample" {
    const input = @embedFile("sample.txt");
    const a = try part1(input);
    try std.testing.expect(a == 14);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const b = try part2(input);
    try std.testing.expect(b == 34);
}
