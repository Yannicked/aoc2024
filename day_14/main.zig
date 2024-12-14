const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const vector = struct { x: i64, y: i64 };
const vectorf = struct { x: f64, y: f64 };

const robot = struct { position: vector, velocity: vector };

fn add(a: vector, b: vector) vector {
    return .{ .x = a.x + b.x, .y = a.y + b.y };
}

fn periodic_bounds(position: vector, bounds: vector) vector {
    var new_pos = position;
    if (position.x > bounds.x - 1) new_pos.x -= bounds.x;
    if (position.x < 0) new_pos.x += bounds.x;
    if (position.y > bounds.y - 1) new_pos.y -= bounds.y;
    if (position.y < 0) new_pos.y += bounds.y;
    return new_pos;
}

fn parse_vector(line: []const u8) !vector {
    var it = std.mem.splitScalar(u8, line, ',');
    const x_str = it.next().?;
    const y_str = it.next().?;
    const x = try std.fmt.parseInt(i64, x_str, 10);
    const y = try std.fmt.parseInt(i64, y_str, 10);
    return .{ .x = x, .y = y };
}

fn parse_robot(line: []const u8) !robot {
    var it = std.mem.splitScalar(u8, line, ' ');
    const pos_str = it.next().?[2..];
    const vel_str = it.next().?[2..];
    const robot_pos = try parse_vector(pos_str);
    const robot_vel = try parse_vector(vel_str);
    return .{ .position = robot_pos, .velocity = robot_vel };
}

fn print_grid(robots: []const robot, bounds: vector) void {
    for (0..@intCast(bounds.y)) |y| {
        for (0..@intCast(bounds.x)) |x| {
            var n_robots: u64 = 0;
            for (robots) |r| {
                if (r.position.x == x and r.position.y == y) {
                    n_robots += 1;
                }
            }
            if (n_robots > 0) {
                print("{}", .{n_robots});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
}

fn calcuate_safety(robots: []const robot, bounds: vector) u64 {
    var ul: u64 = 0;
    var ur: u64 = 0;
    var bl: u64 = 0;
    var br: u64 = 0;
    const hx = @divExact(bounds.x - 1, 2);
    const hy = @divExact(bounds.y - 1, 2);
    for (robots) |r| {
        if (r.position.x < hx) {
            if (r.position.y < hy) {
                ul += 1;
            } else if (r.position.y > hy) {
                ur += 1;
            }
        } else if (r.position.x > hx) {
            if (r.position.y < hy) {
                bl += 1;
            } else if (r.position.y > hy) {
                br += 1;
            }
        }
    }
    return ul * ur * bl * br;
}

fn part1(input: []const u8, bounds: vector) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    var robots = std.ArrayList(robot).init(allocator);
    defer robots.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        const r = try parse_robot(line);
        try robots.append(r);
    }

    for (0..100) |_| {
        for (robots.items) |*r| {
            const new_pos = add(r.position, r.velocity);
            const new_pos_periodic = periodic_bounds(new_pos, bounds);
            r.*.position = new_pos_periodic;
        }
        // print("T={}\n", .{t});
        // print_grid(robots.items, bounds);
    }
    const safety = calcuate_safety(robots.items, bounds);
    print("Safety: {}\n", .{safety});
}

fn calculate_variance(robots: []const robot) vectorf {
    var mean_x: f64 = 0;
    var mean_y: f64 = 0;
    for (robots) |r| {
        mean_x += @floatFromInt(r.position.x);
        mean_y += @floatFromInt(r.position.y);
    }
    const n: f64 = @floatFromInt(robots.len);
    mean_x /= n;
    mean_y /= n;

    var var_x: f64 = 0;
    var var_y: f64 = 0;
    for (robots) |r| {
        var_x += std.math.pow(f64, @as(f64, @floatFromInt(r.position.x)) - mean_x, 2);
        var_y += std.math.pow(f64, @as(f64, @floatFromInt(r.position.y)) - mean_y, 2);
    }
    var_x /= n;
    var_y /= n;
    return .{ .x = var_x, .y = var_y };
}

fn part2(input: []const u8, bounds: vector) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    var robots = std.ArrayList(robot).init(allocator);
    defer robots.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        const r = try parse_robot(line);
        try robots.append(r);
    }

    for (0..10000) |t| {
        for (robots.items) |*r| {
            const new_pos = add(r.position, r.velocity);
            const new_pos_periodic = periodic_bounds(new_pos, bounds);
            r.*.position = new_pos_periodic;
        }
        const variance = calculate_variance(robots.items);
        // print("{any}\n", .{variance});
        if (variance.x < 7e2 and variance.y < 7e2) {
            print("T={}\n", .{t + 1});
            print_grid(robots.items, bounds);
        }
    }
    const safety = calcuate_safety(robots.items, bounds);
    print("Safety: {}\n", .{safety});
}

pub fn main() !void {
    const bounds = vector{ .x = 101, .y = 103 };
    const input = @embedFile("input.txt");
    try part1(input, bounds);
    try part2(input, bounds);
}

test "Part 1 - sample" {
    const bounds = vector{ .x = 11, .y = 7 };
    const input = @embedFile("sample.txt");
    try part1(input, bounds);
}

test "Part 2 - sample" {
    const bounds = vector{ .x = 11, .y = 7 };
    const input = @embedFile("sample.txt");
    try part2(input, bounds);
}
