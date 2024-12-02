const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

fn exclude_index(arr: []const u32, index: usize) ![]u32 {
    var result = try allocator.alloc(u32, arr.len - 1);

    var j: usize = 0;
    for (arr, 0..arr.len) |val, i| {
        if (i == index) continue;
        result[j] = val;
        j += 1;
    }
    return result;
}

fn is_trend(arr: []const u32, max_faults: u32, compare: fn (u32, u32) bool) !bool {
    var last_num = arr[0];
    for (arr[1..], 1..arr.len) |current_num, i| {
        if (compare(current_num, last_num)) {
            last_num = current_num;
        } else {
            if (max_faults == 0) return false;

            const arr_without_current = try exclude_index(arr, i);
            defer allocator.free(arr_without_current);
            const arr_without_previous = try exclude_index(arr, i - 1);
            defer allocator.free(arr_without_previous);

            const is_valid =
                try is_trend(arr_without_current, max_faults - 1, compare) or
                try is_trend(arr_without_previous, max_faults - 1, compare);

            if (!is_valid) return false;

            break;
        }
    }
    return true;
}

fn increasing(a: u32, b: u32) bool {
    return a > b and a - b <= 3;
}

fn decreasing(a: u32, b: u32) bool {
    return a < b and b - a <= 3;
}

fn part1(input: []const u8) !u32 {
    var counter: u32 = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) break;
        var report_list = std.ArrayList(u32).init(allocator);
        defer report_list.deinit();
        var it2 = std.mem.splitScalar(u8, line, ' ');
        while (it2.next()) |num| {
            const i = try std.fmt.parseInt(u32, num, 10);
            try report_list.append(i);
        }
        if (try is_trend(report_list.items, 0, increasing)) {
            counter += 1;
            // print("PASS1: {s}\n", .{line});
        } else if (try is_trend(report_list.items, 0, decreasing)) {
            counter += 1;
            // print("PASS2: {s}\n", .{line});
        } else {
            // print("FAIL: {s}\n", .{line});
        }
    }
    return counter;
}

fn part2(input: []const u8) !u32 {
    var counter: u32 = 0;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) break;
        var report_list = std.ArrayList(u32).init(allocator);
        defer report_list.deinit();
        var it2 = std.mem.splitScalar(u8, line, ' ');
        while (it2.next()) |num| {
            const i = try std.fmt.parseInt(u32, num, 10);
            try report_list.append(i);
        }
        if (try is_trend(report_list.items, 1, increasing)) {
            counter += 1;
            // print("PASS1: {s}\n", .{line});
        } else if (try is_trend(report_list.items, 1, decreasing)) {
            counter += 1;
            // print("PASS2: {s}\n", .{line});
        } else {
            // print("FAIL: {s}\n", .{line});
        }
    }
    return counter;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    const i = try part1(input);
    print("Part 1: {}\n", .{i});
    const j = try part2(input);
    print("Part 2: {}\n", .{j});
}

test "Part 1 - sample" {
    const input = @embedFile("sample.txt");
    const i = try part1(input);
    try std.testing.expect(i == 2);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const i = try part2(input);
    try std.testing.expect(i == 4);
}
