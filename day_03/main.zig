const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const parse_result = struct { index: usize, result: u64 };

fn parse_next(input: []const u8) !parse_result {
    const index_ = std.mem.indexOf(u8, input, "mul(");
    if (index_ == null) {
        return .{ .index = input.len, .result = 0 };
    }
    const index = index_.? + 4;
    var i: u32 = 0;
    var first_integer_str = std.ArrayList(u8).init(allocator);
    defer first_integer_str.deinit();
    while (true) {
        const c = input[index + i];
        if (c >= '0' and c <= '9') {
            try first_integer_str.append(c);
            i += 1;
        } else {
            break;
        }
    }
    if (first_integer_str.items.len == 0) return .{ .index = index + i, .result = 0 };
    if (input[index + i] != ',') return .{ .index = index + i, .result = 0 };
    i += 1;
    var second_integer_str = std.ArrayList(u8).init(allocator);
    defer second_integer_str.deinit();
    while (true) {
        const c = input[index + i];
        if (c >= '0' and c <= '9') {
            try second_integer_str.append(c);
            i += 1;
        } else {
            break;
        }
    }
    if (second_integer_str.items.len == 0) return .{ .index = index + i, .result = 0 };
    if (input[index + i] != ')') return .{ .index = index + i, .result = 0 };
    i += 1;
    const first_integer = try std.fmt.parseInt(u32, first_integer_str.items, 10);
    const second_integer = try std.fmt.parseInt(u32, second_integer_str.items, 10);
    // print("{s} * {s} = {}\n", .{ first_integer_str.items, second_integer_str.items, first_integer * second_integer });
    return .{ .index = index + i, .result = first_integer * second_integer };
}

fn part1(input: []const u8) !u64 {
    var result: u64 = 0;
    var index: usize = 0;
    while (index < input.len) {
        const r = try parse_next(input[index..]);
        index += r.index;
        result += r.result;
    }
    return result;
}

fn find_last_do(input: []const u8) !bool {
    const do_index = std.mem.lastIndexOf(u8, input, "do()") orelse 0;
    const dont_index = std.mem.lastIndexOf(u8, input, "don't()");
    if (dont_index == null) return true;
    return do_index > dont_index.?;
}

fn part2(input: []const u8) !u64 {
    var result: u64 = 0;
    var index: usize = 0;
    while (index < input.len) {
        const r = try parse_next(input[index..]);
        index += r.index;
        if (try find_last_do(input[0..index])) {
            result += r.result;
        }
    }
    return result;
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
    try std.testing.expect(a == 161);
}

test "Part 2 - sample" {
    const input = @embedFile("sample2.txt");
    const a = try part2(input);
    try std.testing.expect(a == 48);
}
