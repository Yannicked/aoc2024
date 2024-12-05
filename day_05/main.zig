const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

fn bloepsort() fn (std.AutoHashMap(u32, std.ArrayList(u32)), u32, u32) bool {
    return struct {
        pub fn inner(map: std.AutoHashMap(u32, std.ArrayList(u32)), a: u32, b: u32) bool {
            const l = map.get(a);
            if (l) |k| {
                for (k.items) |v| {
                    if (v == b) return false;
                }
            }
            return true;
        }
    }.inner;
}

fn part1(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var map = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer map.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        var it2 = std.mem.splitScalar(u8, line, '|');
        const num_before = try std.fmt.parseInt(u32, it2.next().?, 10);
        const num = try std.fmt.parseInt(u32, it2.next().?, 10);
        const a = try map.getOrPut(num);
        if (!a.found_existing) {
            a.value_ptr.* = std.ArrayList(u32).init(allocator);
        }
        try a.value_ptr.*.append(num_before);
    }
    var sum: u64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var list = std.ArrayList(u32).init(allocator);
        defer list.deinit();
        var it2 = std.mem.splitScalar(u8, line, ',');
        while (it2.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try list.append(num);
        }
        var listcopy = try list.clone();
        defer listcopy.deinit();
        const listslice = try listcopy.toOwnedSlice();
        defer allocator.free(listslice);
        std.mem.sort(u32, listslice, map, bloepsort());
        if (std.mem.eql(u32, list.items, listslice)) {
            sum += listslice[listslice.len / 2];
        }
    }
    return sum;
}

fn part2(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var map = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer map.deinit();
    while (it.next()) |line| {
        if (line.len == 0) break;
        var it2 = std.mem.splitScalar(u8, line, '|');
        const num_before = try std.fmt.parseInt(u32, it2.next().?, 10);
        const num = try std.fmt.parseInt(u32, it2.next().?, 10);
        const a = try map.getOrPut(num);
        if (!a.found_existing) {
            a.value_ptr.* = std.ArrayList(u32).init(allocator);
        }
        try a.value_ptr.*.append(num_before);
    }
    var sum: u64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;
        var list = std.ArrayList(u32).init(allocator);
        defer list.deinit();
        var it2 = std.mem.splitScalar(u8, line, ',');
        while (it2.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try list.append(num);
        }
        var listcopy = try list.clone();
        defer listcopy.deinit();
        const listslice = try listcopy.toOwnedSlice();
        defer allocator.free(listslice);
        std.mem.sort(u32, listslice, map, bloepsort());
        if (!std.mem.eql(u32, list.items, listslice)) {
            sum += listslice[listslice.len / 2];
        }
    }
    return sum;
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
    try std.testing.expect(one == 143);
}

test "Part 2 - sample" {
    const input = @embedFile("sample.txt");
    const two = try part2(input);
    try std.testing.expect(two == 123);
}
