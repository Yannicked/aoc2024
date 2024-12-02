const std = @import("std");
const print = std.debug.print;

fn part1(input: []const u8) !u32 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var okay_reports: u32 = 0;
    reports: while (it.next()) |line| {
        if (line.len == 0) break;
        var it2 = std.mem.splitScalar(u8, line, ' ');
        var firstnum: i32 = 0;
        if (it2.next()) |num| {
            firstnum = try std.fmt.parseInt(i32, num, 10);
        }
        var curnum = firstnum;
        var increasing = false;
        if (it2.next()) |num| {
            curnum = try std.fmt.parseInt(i32, num, 10);
            if (curnum < firstnum and firstnum - curnum <= 3) {
                increasing = false;
            } else if (curnum > firstnum and curnum - firstnum <= 3) {
                increasing = true;
            } else {
                continue :reports;
            }
        }
        while (it2.next()) |num| {
            const thisnum = try std.fmt.parseInt(i32, num, 10);
            if (!increasing and thisnum < curnum and curnum - thisnum <= 3) {
                curnum = thisnum;
            } else if (increasing and thisnum > curnum and thisnum - curnum <= 3) {
                curnum = thisnum;
            } else {
                continue :reports;
            }
        }
        okay_reports += 1;
    }
    return okay_reports;
}

fn excludeIndex(arr: []const u32, exclude_index: usize) ![]u32 {
    var allocator = std.heap.page_allocator;
    var result = try allocator.alloc(u32, arr.len - 1);

    var j: usize = 0;
    for (arr, 0..arr.len) |val, i| {
        if (i == exclude_index) continue;
        result[j] = val;
        j += 1;
    }
    return result;
}

fn is_increasing(arr: []const u32, max_faults: u32) !bool {
    var allocator = std.heap.page_allocator;
    var lastnum = arr[0];
    for (arr[1..], 1..arr.len) |num, i| {
        if (num > lastnum and num - lastnum <= 3) {
            lastnum = num;
        } else {
            if (max_faults == 0) return false;
            const copy1 = try excludeIndex(arr, i);
            defer allocator.free(copy1);
            const copy2 = try excludeIndex(arr, i - 1);
            defer allocator.free(copy2);

            if (!try is_increasing(copy1, max_faults - 1) and !try is_increasing(copy2, max_faults - 1)) {
                return false;
            } else {
                break;
            }
        }
    }
    return true;
}
fn is_decreasing(arr: []const u32, max_faults: u32) !bool {
    var allocator = std.heap.page_allocator;
    var lastnum = arr[0];
    for (arr[1..], 1..arr.len) |num, i| {
        if (num < lastnum and lastnum - num <= 3) {
            lastnum = num;
        } else {
            if (max_faults == 0) return false;
            const copy1 = try excludeIndex(arr, i);
            defer allocator.free(copy1);
            const copy2 = try excludeIndex(arr, i - 1);
            defer allocator.free(copy2);

            if (!try is_decreasing(copy1, max_faults - 1) and !try is_decreasing(copy2, max_faults - 1)) {
                return false;
            } else {
                break;
            }
        }
    }
    return true;
}

fn part2(input: []const u8) !u32 {
    const allocator = std.heap.page_allocator;
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
        if (try is_increasing(report_list.items, 1)) {
            counter += 1;
            print("PASS1: {s}\n", .{line});
        } else if (try is_decreasing(report_list.items, 1)) {
            counter += 1;
            print("PASS2: {s}\n", .{line});
        } else {
            print("FAIL: {s}\n", .{line});
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
