const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

pub fn count_occurrences(haystack: []const u8, needle: []const u8) usize {
    var count: usize = 0;
    var index: ?usize = std.mem.indexOf(u8, haystack, needle);
    var offset: usize = 0;

    while (index) |idx| {
        count += 1;
        offset = idx + needle.len;

        if (offset >= haystack.len) break;

        index = std.mem.indexOf(u8, haystack[offset..], needle);
        if (index) |next_idx| {
            index = next_idx + offset;
        }
    }

    return count;
}

pub fn get_diagonals(matrix: std.ArrayList(std.ArrayList(u8))) !std.ArrayList(std.ArrayList(u8)) {
    const rows = matrix.items.len;
    const cols = matrix.items[0].items.len;

    var diagonals = std.ArrayList(std.ArrayList(u8)).init(allocator);

    // Top-left to bottom-right diagonals
    for (0..rows + cols - 1) |d| {
        var diagonal = std.ArrayList(u8).init(allocator);
        const row_start = if (d < cols) 0 else d - cols + 1;
        const col_start = if (d < cols) d else 0;

        const len = @min(rows - row_start, cols - col_start);
        for (row_start..row_start + len, col_start..col_start + len) |i, j| {
            try diagonal.append(matrix.items[i].items[j]);
        }
        try diagonals.append(diagonal);
    }
    return diagonals;
}

fn reverse(arr: std.ArrayList(std.ArrayList(u8))) !std.ArrayList(std.ArrayList(u8)) {
    var rev = std.ArrayList(std.ArrayList(u8)).init(allocator);
    for (arr.items) |row| {
        var new_row = std.ArrayList(u8).init(allocator);
        for (0..row.items.len) |i| {
            try new_row.append(row.items[row.items.len - i - 1]);
        }
        try rev.append(new_row);
    }
    return rev;
}

fn transpose(arr: std.ArrayList(std.ArrayList(u8))) !std.ArrayList(std.ArrayList(u8)) {
    const n_columns = arr.items[0].items.len;
    var columns = std.ArrayList(std.ArrayList(u8)).init(allocator);
    while (columns.items.len < n_columns) {
        var column = std.ArrayList(u8).init(allocator);
        try column.appendNTimes(0, arr.items.len);
        try columns.append(column);
    }
    for (0..arr.items.len) |i| {
        for (0..n_columns) |j| {
            columns.items[j].items[i] = arr.items[i].items[j];
        }
    }
    return columns;
}

fn count_xmas(arr: std.ArrayList(std.ArrayList(u8))) u64 {
    var count: u64 = 0;
    for (arr.items) |line| {
        count += count_occurrences(line.items, "XMAS");
    }
    return count;
}

fn check_mas(arr: std.ArrayList(std.ArrayList(u8)), i: usize, j: usize) u64 {
    const tl = arr.items[i - 1].items[j - 1];
    const bl = arr.items[i + 1].items[j - 1];
    const tr = arr.items[i - 1].items[j + 1];
    const br = arr.items[i + 1].items[j + 1];

    const diag1 = (tr == 'M' and bl == 'S') or (tr == 'S' and bl == 'M');
    const diag2 = (br == 'M' and tl == 'S') or (br == 'S' and tl == 'M');

    if (diag1 and diag2) {
        return 1;
    }
    return 0;
}

fn count_mas(arr: std.ArrayList(std.ArrayList(u8))) u64 {
    var count: u64 = 0;
    for (1..arr.items.len - 1) |i| {
        for (1..arr.items[0].items.len - 1) |j| {
            if (arr.items[i].items[j] == 'A') {
                count += check_mas(arr, i, j);
            }
        }
    }
    return count;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer rows.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        var row = std.ArrayList(u8).init(allocator);
        try row.appendSlice(line);
        try rows.append(row);
    }

    const row_rev = try reverse(rows);
    const columns = try transpose(rows);
    const columns_rev = try reverse(columns);
    const diagonals = try get_diagonals(rows);
    const diagonals_rev = try reverse(diagonals);
    const diagonals2 = try get_diagonals(row_rev);
    const diagonals2_rev = try reverse(diagonals2);

    const count = count_xmas(rows) + count_xmas(row_rev) + count_xmas(columns) + count_xmas(columns_rev) + count_xmas(diagonals) + count_xmas(diagonals_rev) + count_xmas(diagonals2) + count_xmas(diagonals2_rev);
    return count;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer rows.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        var row = std.ArrayList(u8).init(allocator);
        try row.appendSlice(line);
        try rows.append(row);
    }

    const count = count_mas(rows);
    return count;
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
    try std.testing.expect(a == 18);
}

test "Part 2 - sample" {
    const input = @embedFile("sample2.txt");
    const a = try part2(input);
    try std.testing.expect(a == 9);
}
