const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const point = struct { x: usize, y: usize };
const start_end = struct { start: point, end: ?point };

const FooErrors = error{
    OutOfMemory,
};

fn do_step(start_point: point, from_point: point, to_point: point, dimensions: point, routes: *std.AutoHashMap(start_end, usize), map: std.ArrayList(std.ArrayList(u8))) FooErrors!void {
    const route = start_end{ .start = start_point, .end = to_point };
    // if (routes.contains(route)) return;

    const from_val = map.items[from_point.y].items[from_point.x];
    const to_val = map.items[to_point.y].items[to_point.x];

    if (from_val + 1 != to_val) return;

    const val = try routes.getOrPut(route);
    if (!val.found_existing) {
        val.value_ptr.* = 0;
    }
    val.value_ptr.* += 1;
    try step_around(start_point, to_point, dimensions, routes, map);
}

fn step_around(start_point: point, current_point: point, dimensions: point, routes: *std.AutoHashMap(start_end, usize), map: std.ArrayList(std.ArrayList(u8))) FooErrors!void {
    // left, right up down
    if (current_point.x > 0) {
        const left = point{ .x = current_point.x - 1, .y = current_point.y };
        try do_step(start_point, current_point, left, dimensions, routes, map);
    }
    if (current_point.x < dimensions.x) {
        const right = point{ .x = current_point.x + 1, .y = current_point.y };
        try do_step(start_point, current_point, right, dimensions, routes, map);
    }
    if (current_point.y > 0) {
        const up = point{ .x = current_point.x, .y = current_point.y - 1 };
        try do_step(start_point, current_point, up, dimensions, routes, map);
    }
    if (current_point.y < dimensions.y) {
        const down = point{ .x = current_point.x, .y = current_point.y + 1 };
        try do_step(start_point, current_point, down, dimensions, routes, map);
    }
}

fn part1(input: []const u8) !u64 {
    var map = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var routes = std.AutoHashMap(start_end, usize).init(allocator);
    var start_points = std.ArrayList(point).init(allocator);
    var it = std.mem.splitScalar(u8, input, '\n');
    var y: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var map_row = std.ArrayList(u8).init(allocator);
        for (line, 0..line.len) |c, x| {
            if (c == '0') {
                try start_points.append(point{ .x = x, .y = y });
            }
            try map_row.append(c - 48);
        }
        try map.append(map_row);
        y += 1;
    }
    for (start_points.items) |start_point| {
        try step_around(start_point, start_point, point{ .x = map.items[0].items.len - 1, .y = y - 1 }, &routes, map);
    }

    var score: u64 = 0;
    var routes_it = routes.keyIterator();
    while (routes_it.next()) |r| {
        if (r.end) |e| {
            const endval = map.items[e.y].items[e.x];
            if (endval == 9) {
                score += 1;
            }
        }
    }
    return score;
}

fn part2(input: []const u8) !u64 {
    var map = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var routes = std.AutoHashMap(start_end, usize).init(allocator);
    var start_points = std.ArrayList(point).init(allocator);
    var it = std.mem.splitScalar(u8, input, '\n');
    var y: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var map_row = std.ArrayList(u8).init(allocator);
        for (line, 0..line.len) |c, x| {
            if (c == '0') {
                try start_points.append(point{ .x = x, .y = y });
            }
            try map_row.append(c - 48);
        }
        try map.append(map_row);
        y += 1;
    }
    for (start_points.items) |start_point| {
        try step_around(start_point, start_point, point{ .x = map.items[0].items.len - 1, .y = y - 1 }, &routes, map);
    }

    var score: u64 = 0;
    var routes_it = routes.iterator();
    while (routes_it.next()) |r| {
        if (r.key_ptr.end) |e| {
            const endval = map.items[e.y].items[e.x];
            if (endval == 9) {
                score += r.value_ptr.*;
            }
        }
    }
    return score;
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
    try std.testing.expect(a == 36);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const b = try part2(input);
    try std.testing.expect(b == 81);
}
