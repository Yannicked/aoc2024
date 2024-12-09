const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

fn checksum(input: []const ?u64) u64 {
    var result: u64 = 0;
    for (input, 0..input.len) |optval, i| {
        if (optval) |val| {
            result += val * i;
        }
    }
    return result;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    const line = it.next().?;
    var x: usize = 0;
    var file_id: u64 = 0;

    var memory_array = std.ArrayList(?u64).init(allocator);
    defer memory_array.deinit();
    var free_spaces = std.ArrayList(usize).init(allocator);
    defer free_spaces.deinit();
    while (x < line.len) : (x += 2) {
        const n_files = line[x] - 48;
        for (0..n_files) |_| {
            try memory_array.append(file_id);
        }
        if (x + 1 >= line.len) break;
        const n_free = line[x + 1] - 48;
        for (0..n_free) |_| {
            try free_spaces.append(memory_array.items.len);
            try memory_array.append(null);
        }
        file_id += 1;
    }

    var i: usize = memory_array.items.len;
    var j: usize = 0;
    while (i > 0 and j < free_spaces.items.len) {
        i -= 1;
        const free_space = free_spaces.items[j];
        if (i < free_space) {
            break;
        }
        if (memory_array.items[i]) |value| {
            memory_array.items[i] = null;
            memory_array.items[free_space] = value;
            j += 1;
        }
    }
    const c = checksum(memory_array.items);
    // print("{}\n", .{c});
    return c;
}

const fileblock = struct { id: u64, start: usize, end: usize };

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    const line = it.next().?;
    var x: usize = 0;
    var file_id: u64 = 0;

    var memory_array = std.ArrayList(?u64).init(allocator);
    defer memory_array.deinit();
    var free_spaces = std.ArrayList(fileblock).init(allocator);
    defer free_spaces.deinit();
    var file_blocks = std.ArrayList(fileblock).init(allocator);
    defer file_blocks.deinit();
    while (x < line.len) : (x += 2) {
        const n_files = line[x] - 48;
        const f = fileblock{ .id = file_id, .start = memory_array.items.len, .end = memory_array.items.len + n_files };
        try file_blocks.append(f);
        for (0..n_files) |_| {
            try memory_array.append(file_id);
        }
        if (x + 1 >= line.len) break;
        const n_free = line[x + 1] - 48;
        const g = fileblock{ .id = file_id, .start = memory_array.items.len, .end = memory_array.items.len + n_free };
        try free_spaces.append(g);
        for (0..n_free) |_| {
            try memory_array.append(null);
        }
        file_id += 1;
    }

    var i: usize = file_blocks.items.len;
    while (i > 0) {
        i -= 1;
        const file_block = file_blocks.items[i];
        const file_block_len = file_block.end - file_block.start;
        for (0..free_spaces.items.len) |j| {
            var free_space = &free_spaces.items[j];
            const free_space_len = free_space.end - free_space.start;
            if (free_space.start < file_block.start) {
                if (free_space_len >= file_block_len) {
                    for (free_space.start..free_space.start + file_block_len, file_block.start..file_block.end) |k, l| {
                        memory_array.items[k] = memory_array.items[l];
                        memory_array.items[l] = null;
                    }
                    free_space.start += file_block_len;
                    break;
                }
            }
        }
    }
    const c = checksum(memory_array.items);
    // print("{}\n", .{c});
    return c;
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
    try std.testing.expect(a == 1928);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const b = try part2(input);
    try std.testing.expect(b == 2858);
}
