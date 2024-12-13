const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const vector = struct { x: i64, y: i64 };

const challenge = struct { a: vector, b: vector, target: vector };

const head = struct { pos: vector, cost: u64 };

fn add(a: vector, b: vector) vector {
    return .{ .x = a.x + b.x, .y = a.y + b.y };
}

fn parse_in(it: *std.mem.SplitIterator(u8, .scalar)) !challenge {
    const a_line = it.next().?[10..];
    var a_it = std.mem.splitSequence(u8, a_line, ", ");
    const a_x = try std.fmt.parseInt(i64, a_it.next().?[1..], 10);
    const a_y = try std.fmt.parseInt(i64, a_it.next().?[1..], 10);
    const a = vector{ .x = a_x, .y = a_y };
    const b_line = it.next().?[10..];
    var b_it = std.mem.splitSequence(u8, b_line, ", ");
    const b_x = try std.fmt.parseInt(i64, b_it.next().?[1..], 10);
    const b_y = try std.fmt.parseInt(i64, b_it.next().?[1..], 10);
    const b = vector{ .x = b_x, .y = b_y };
    const target_line = it.next().?[7..];
    var target_it = std.mem.splitSequence(u8, target_line, ", ");
    const target_x = try std.fmt.parseInt(i64, target_it.next().?[2..], 10);
    const target_y = try std.fmt.parseInt(i64, target_it.next().?[2..], 10);
    const target = vector{ .x = target_x, .y = target_y };
    return challenge{ .a = a, .b = b, .target = target };
}

fn print_heads(heads: *std.AutoHashMap(vector, u64)) void {
    var head_it = heads.iterator();
    while (head_it.next()) |h| {
        print("{any}: {}\n", .{ h.key_ptr.*, h.value_ptr.* });
    }
}

fn dijkstra(c: challenge, heads: *std.AutoHashMap(vector, u64), head_pos: vector) !?vector {
    if (!heads.contains(head_pos)) return null;
    const cur_cost = heads.get(head_pos).?;
    // print_heads(heads);
    if (head_pos.x != c.target.x or head_pos.y != c.target.y) {
        _ = heads.remove(head_pos);
    }
    // A
    const pos_a = add(head_pos, c.a);
    if (pos_a.x <= c.target.x and pos_a.y <= c.target.y) {
        // print("A pos: {any}\n", .{pos_a});
        try heads.put(pos_a, cur_cost + 3);
    }
    // B
    const pos_b = add(head_pos, c.b);
    if (pos_b.x <= c.target.x and pos_b.y <= c.target.y) {
        // print("B pos: {any}\n", .{pos_b});
        try heads.put(pos_b, cur_cost + 1);
    }

    // print("{any}\n", .{heads.items});
    // Find cheapest head_idx
    var cheapest_pos = pos_b;
    var cheapest_cost: u64 = std.math.maxInt(u64);
    var head_it = heads.iterator();
    while (head_it.next()) |h| {
        if (h.value_ptr.* < cheapest_cost) {
            cheapest_cost = h.value_ptr.*;
            cheapest_pos = h.key_ptr.*;
        }
    }
    return cheapest_pos;
}

fn dijkstra_nonrecursive(c: challenge, heads: *std.AutoHashMap(vector, u64), _head_pos: vector) !?u64 {
    var head_pos = _head_pos;
    while (true) {
        const h = try dijkstra(c, heads, head_pos);
        if (h) |hh| {
            if (hh.x == c.target.x and hh.y == c.target.y) return heads.get(hh);
            head_pos = hh;
        } else {
            return null;
        }
    }
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    const start_pos = vector{ .x = 0, .y = 0 };
    var total_cost: u64 = 0;
    while (it.peek()) |line| {
        if (line.len == 0) {
            _ = it.next();
            continue;
        }
        const c = try parse_in(&it);
        // print("{any}\n", .{c});
        var heads = std.AutoHashMap(vector, u64).init(allocator);
        try heads.put(start_pos, 0);
        defer heads.deinit();
        const cc = try dijkstra_nonrecursive(c, &heads, start_pos);
        if (cc) |ccc| {
            total_cost += ccc;
        }
    }
    return total_cost;
}

fn matrix_method(c: challenge) ?i64 {
    if (c.a.x * c.b.y - c.a.y * c.b.x == 0) return null;
    const inv: f64 = 1 / @as(f64, @floatFromInt(c.a.x * c.b.y - c.a.y * c.b.x));
    const n_a: i64 = @intFromFloat(std.math.round(inv * @as(f64, @floatFromInt(c.b.y * c.target.x - c.b.x * c.target.y))));
    const n_b: i64 = @intFromFloat(std.math.round(inv * @as(f64, @floatFromInt(c.a.x * c.target.y - c.a.y * c.target.x))));
    if (n_a * c.a.x + n_b * c.b.x != c.target.x) return null;
    if (n_a * c.a.y + n_b * c.b.y != c.target.y) return null;
    return (n_a * 3 + n_b);
}

fn part2(input: []const u8) !i64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var total_cost: i64 = 0;
    while (it.peek()) |line| {
        if (line.len == 0) {
            _ = it.next();
            continue;
        }
        var c = try parse_in(&it);
        c.target.x += 10000000000000;
        c.target.y += 10000000000000;
        if (matrix_method(c)) |cost| {
            total_cost += cost;
        }
    }
    return total_cost;
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
    try std.testing.expect(one == 480);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const two = try part2(input);
    try std.testing.expect(two == 875318608908);
}
