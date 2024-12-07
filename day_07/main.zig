const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const operator = enum {
    plus,
    times,
    concat,
};

fn apply_operators(numbers: []u64, operators: []const operator) u64 {
    var result: u64 = numbers[0];
    for (operators, 0..operators.len) |op, i| {
        if (op == operator.times) {
            result *= numbers[i + 1];
        } else if (op == operator.plus) {
            result += numbers[i + 1];
        } else if (op == operator.concat) {
            result *= std.math.pow(u64, 10, std.math.log10(numbers[i + 1]) + 1);
            result += numbers[i + 1];
        }
    }
    return result;
}

fn operator_combinations(len: usize) !std.ArrayList(std.ArrayList(operator)) {
    var o = std.ArrayList(std.ArrayList(operator)).init(allocator);
    const l = len - 1;
    for (0..std.math.pow(usize, 2, l)) |i| {
        var b = std.ArrayList(operator).init(allocator);
        for (0..l) |k| {
            if (((i >> @intCast(k)) & 1) == 0) {
                try b.append(operator.plus);
            } else {
                try b.append(operator.times);
            }
        }
        try o.append(b);
    }
    return o;
}

fn operator_combinations2(len: usize) !std.ArrayList(std.ArrayList(operator)) {
    var o = std.ArrayList(std.ArrayList(operator)).init(allocator);
    const l = len - 1;
    for (0..std.math.pow(usize, 3, l)) |i| {
        var b = std.ArrayList(operator).init(allocator);
        for (0..l) |k| {
            const op_choice = (i / std.math.pow(usize, 3, k)) % 3;
            if (op_choice == 0) {
                try b.append(operator.plus);
            } else if (op_choice == 1) {
                try b.append(operator.times);
            } else if (op_choice == 2) {
                try b.append(operator.concat);
            }
        }
        try o.append(b);
    }
    return o;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var total: u64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var numbers = std.ArrayList(u64).init(allocator);
        defer numbers.deinit();
        var it2 = std.mem.splitSequence(u8, line, ": ");
        const res = it2.next().?;
        const result = try std.fmt.parseInt(u64, res, 10);
        const nums = it2.next().?;
        var it3 = std.mem.splitScalar(u8, nums, ' ');
        while (it3.next()) |num| {
            const n = try std.fmt.parseInt(u64, num, 10);
            try numbers.append(n);
        }
        const combs = try operator_combinations(numbers.items.len);
        for (combs.items) |comb| {
            if (apply_operators(numbers.items, comb.items) == result) {
                total += result;
                break;
            }
        }
        for (combs.items) |comb| {
            comb.deinit();
        }
        combs.deinit();
    }
    return total;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var total: u64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var numbers = std.ArrayList(u64).init(allocator);
        defer numbers.deinit();
        var it2 = std.mem.splitSequence(u8, line, ": ");
        const res = it2.next().?;
        const result = try std.fmt.parseInt(u64, res, 10);
        const nums = it2.next().?;
        var it3 = std.mem.splitScalar(u8, nums, ' ');
        while (it3.next()) |num| {
            const n = try std.fmt.parseInt(u64, num, 10);
            try numbers.append(n);
        }
        const combs = try operator_combinations2(numbers.items.len);
        for (combs.items) |comb| {
            const r = apply_operators(numbers.items, comb.items);
            if (r == result) {
                total += result;
                break;
            }
        }
        for (combs.items) |comb| {
            comb.deinit();
        }
        combs.deinit();
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
    try std.testing.expect(a == 3749);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const a = try part2(input);
    print("{}\n", .{a});
}
