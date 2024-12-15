const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const vector = struct { x: i64, y: i64 };

fn add(a: vector, b: vector) vector {
    return .{ .x = a.x + b.x, .y = a.y + b.y };
}

const entity = enum(u8) { robot = '@', box = 'O', wall = '#', empty = '.', box_left = '[', box_right = ']' };

const grid_map_t = std.AutoHashMap(vector, entity);

const grid_t = struct { map: grid_map_t, robot: vector, bounds: vector };

fn parse_field(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !grid_t {
    var grid_map = grid_map_t.init(allocator);
    var y: i64 = 0;
    var x: i64 = 0;
    var robot = vector{ .x = 0, .y = 0 };
    while (it.next()) |line| {
        if (line.len == 0) break;
        for (0..line.len, line) |_x, char| {
            x = @intCast(_x);
            const cur_vec = vector{ .x = x, .y = y };
            switch (char) {
                '@' => {
                    robot = cur_vec;
                },
                '#' => {
                    try grid_map.put(cur_vec, entity.wall);
                },
                'O' => {
                    try grid_map.put(cur_vec, entity.box);
                },
                else => {},
            }
        }
        y += 1;
    }
    const grid = grid_t{ .map = grid_map, .robot = robot, .bounds = vector{ .x = x + 1, .y = y } };

    return grid;
}

fn parse_field2(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !grid_t {
    var grid_map = grid_map_t.init(allocator);
    var y: i64 = 0;
    var x: i64 = 0;
    var robot = vector{ .x = 0, .y = 0 };
    while (it.next()) |line| {
        if (line.len == 0) break;
        for (0..line.len, line) |_x, char| {
            x = @intCast(_x);
            const left_vec = vector{ .x = x * 2, .y = y };
            const right_vec = vector{ .x = x * 2 + 1, .y = y };
            switch (char) {
                '@' => {
                    robot = left_vec;
                },
                '#' => {
                    try grid_map.put(left_vec, entity.wall);
                    try grid_map.put(right_vec, entity.wall);
                },
                'O' => {
                    try grid_map.put(left_vec, entity.box_left);
                    try grid_map.put(right_vec, entity.box_right);
                },
                else => {},
            }
        }
        y += 1;
    }
    const grid = grid_t{ .map = grid_map, .robot = robot, .bounds = vector{ .x = (x + 1) * 2, .y = y } };

    return grid;
}

fn parse_directions(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !std.ArrayList(vector) {
    var directions = std.ArrayList(vector).init(allocator);
    while (it.next()) |line| {
        for (line) |c| {
            if (line.len == 0) break;
            switch (c) {
                '^' => {
                    try directions.append(.{ .x = 0, .y = -1 });
                },
                'v' => {
                    try directions.append(.{ .x = 0, .y = 1 });
                },
                '<' => {
                    try directions.append(.{ .x = -1, .y = 0 });
                },
                '>' => {
                    try directions.append(.{ .x = 1, .y = 0 });
                },
                else => {},
            }
        }
    }
    return directions;
}

fn print_grid(grid: grid_t) void {
    for (0..@as(usize, @intCast(grid.bounds.y))) |y| {
        for (0..@as(usize, @intCast(grid.bounds.x))) |x| {
            var v = grid.map.get(vector{ .x = @intCast(x), .y = @intCast(y) }) orelse entity.empty;
            if (grid.robot.x == x and grid.robot.y == y) {
                v = entity.robot;
            }
            print("{c}", .{@intFromEnum(v)});
        }
        print("\n", .{});
    }
}

fn is_entity_movable(grid: *grid_t, entity_position: vector, entity_direction: vector) bool {
    const entity_type = grid.map.get(entity_position) orelse entity.empty;
    if (entity_type == entity.wall) return false;
    if (entity_type == entity.empty) return true;

    const new_pos = add(entity_position, entity_direction);
    // print("Entity: {c}\n", .{@intFromEnum(entity_type)});
    // print("testing move from {},{} to {},{}\n", .{ entity_position.x, entity_position.y, new_pos.x, new_pos.y });
    if (entity_type == entity.box) {
        return is_entity_movable(grid, new_pos, entity_direction);
    }

    if (entity_type == entity.box_left) {
        const new_pos2 = add(new_pos, vector{ .x = 1, .y = 0 });
        if (entity_direction.y == 0) {
            if (entity_direction.x > 0) {
                return is_entity_movable(grid, new_pos2, entity_direction);
            } else {
                return is_entity_movable(grid, new_pos, entity_direction);
            }
        }
        return is_entity_movable(grid, new_pos, entity_direction) and is_entity_movable(grid, new_pos2, entity_direction);
    }
    if (entity_type == entity.box_right) {
        const new_pos2 = add(new_pos, vector{ .x = -1, .y = 0 });
        if (entity_direction.y == 0) {
            if (entity_direction.x > 0) {
                return is_entity_movable(grid, new_pos, entity_direction);
            } else {
                return is_entity_movable(grid, new_pos2, entity_direction);
            }
        }
        return is_entity_movable(grid, new_pos, entity_direction) and is_entity_movable(grid, new_pos2, entity_direction);
    }

    return false;
}

fn move_entity(grid: *grid_t, entity_position: vector, entity_direction: vector) !bool {
    const entity_type = grid.map.get(entity_position) orelse entity.empty;
    if (entity_type == entity.wall) return false;
    if (entity_type == entity.empty) return true;
    // print("Trying to move {}, {} in direction {}, {}\n", .{ entity_position.x, entity_position.y, entity_direction.x, entity_direction.y });

    const new_pos = add(entity_position, entity_direction);
    if (entity_type == entity.box) {
        if (is_entity_movable(grid, new_pos, entity_direction)) {
            if (try move_entity(grid, new_pos, entity_direction)) {
                _ = grid.map.remove(entity_position);
                try grid.map.put(new_pos, entity_type);
                return true;
            }
        }
    }
    if (entity_type == entity.box_left) {
        const new_pos2 = add(new_pos, .{ .x = 1, .y = 0 });
        const pos2 = add(entity_position, .{ .x = 1, .y = 0 });
        if (entity_direction.y == 0) {
            if (entity_direction.x > 0) {
                if (is_entity_movable(grid, new_pos2, entity_direction)) {
                    if (try move_entity(grid, new_pos2, entity_direction)) {
                        _ = grid.map.remove(entity_position);
                        try grid.map.put(new_pos, entity_type);
                        try grid.map.put(new_pos2, entity.box_right);
                        return true;
                    }
                }
            } else {
                if (is_entity_movable(grid, new_pos, entity_direction)) {
                    if (try move_entity(grid, new_pos, entity_direction)) {
                        _ = grid.map.remove(entity_position);
                        try grid.map.put(new_pos, entity_type);
                        _ = grid.map.remove(pos2);
                        try grid.map.put(new_pos2, entity.box_right);
                        return true;
                    }
                }
            }
        } else {
            if (is_entity_movable(grid, new_pos, entity_direction) and is_entity_movable(grid, new_pos2, entity_direction)) {
                if (try move_entity(grid, new_pos, entity_direction) and try move_entity(grid, new_pos2, entity_direction)) {
                    _ = grid.map.remove(entity_position);
                    try grid.map.put(new_pos, entity_type);
                    _ = grid.map.remove(pos2);
                    try grid.map.put(new_pos2, entity.box_right);
                    return true;
                }
            }
        }
    }
    if (entity_type == entity.box_right) {
        const new_pos2 = add(new_pos, .{ .x = -1, .y = 0 });
        const pos2 = add(entity_position, .{ .x = -1, .y = 0 });
        if (entity_direction.y == 0) {
            if (entity_direction.x > 0) {
                if (is_entity_movable(grid, new_pos, entity_direction)) {
                    if (try move_entity(grid, new_pos, entity_direction)) {
                        _ = grid.map.remove(entity_position);
                        try grid.map.put(new_pos, entity_type);
                        _ = grid.map.remove(pos2);
                        try grid.map.put(new_pos2, entity.box_left);
                        return true;
                    }
                }
            } else {
                if (is_entity_movable(grid, new_pos2, entity_direction)) {
                    if (try move_entity(grid, new_pos2, entity_direction)) {
                        _ = grid.map.remove(entity_position);
                        try grid.map.put(new_pos, entity_type);
                        try grid.map.put(new_pos2, entity.box_left);
                        return true;
                    }
                }
            }
        } else {
            if (is_entity_movable(grid, new_pos, entity_direction) and is_entity_movable(grid, new_pos2, entity_direction)) {
                if (try move_entity(grid, new_pos, entity_direction) and try move_entity(grid, new_pos2, entity_direction)) {
                    _ = grid.map.remove(entity_position);
                    try grid.map.put(new_pos, entity_type);
                    _ = grid.map.remove(pos2);
                    try grid.map.put(new_pos2, entity.box_left);
                    return true;
                }
            }
        }
    }

    return false;
}

fn move_robot(grid: *grid_t, entity_direction: vector) !void {
    const new_pos = add(grid.robot, entity_direction);
    if (try move_entity(grid, new_pos, entity_direction)) {
        grid.robot = new_pos;
    }
}

fn calculate_box_sum(grid: grid_t) i64 {
    var entity_it = grid.map.iterator();
    var total: i64 = 0;
    while (entity_it.next()) |v| {
        if (v.value_ptr.* != entity.box and v.value_ptr.* != entity.box_left) continue;
        total += 100 * v.key_ptr.y + v.key_ptr.x;
    }
    return total;
}

fn part1(input: []const u8) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    var grid = try parse_field(&it);
    const directions = try parse_directions(&it);
    // print_grid(grid);
    for (directions.items) |direction| {
        try move_robot(&grid, direction);
        // print_grid(grid);
    }
    const box_sum = calculate_box_sum(grid);
    print("Part 1: {}\n", .{box_sum});
}

fn part2(input: []const u8) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    var grid = try parse_field2(&it);
    const directions = try parse_directions(&it);
    // print_grid(grid);
    for (directions.items) |direction| {
        try move_robot(&grid, direction);
        // print_grid(grid);
    }
    const box_sum = calculate_box_sum(grid);
    print("Part 2: {}\n", .{box_sum});
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    try part1(input);
    try part2(input);
}

test "Part 1 - sample" {
    const input = @embedFile("sample.txt");
    try part1(input);
}

test "Part 2 - sample" {
    const input = @embedFile("sample2.txt");
    try part2(input);
}
