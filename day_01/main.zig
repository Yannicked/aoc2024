const std = @import("std");

fn one() !void {
    const allocator = std.heap.page_allocator;
    const input = @embedFile("input.txt");

    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var list2 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        var it2 = std.mem.splitSequence(u8, line, "   ");
        if (it2.next()) |num| {
            const i = try std.fmt.parseInt(i32, num, 10);
            try list1.append(i);
        }
        if (it2.next()) |num| {
            const i = try std.fmt.parseInt(i32, num, 10);
            try list2.append(i);
        }
    }

    std.mem.sort(i32, list1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, comptime std.sort.asc(i32));

    var distance: u32 = 0;
    for (list1.items, list2.items) |elem1, elem2| {
        distance += @abs(elem2 - elem1);
    }
    std.debug.print("1: {}\n", .{distance});
}

fn two() !void {
    const allocator = std.heap.page_allocator;
    const input = @embedFile("input.txt");

    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var map1 = std.AutoHashMap(i32, i32).init(
        allocator,
    );
    defer map1.deinit();

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        var it2 = std.mem.splitSequence(u8, line, "   ");
        if (it2.next()) |num| {
            const i = try std.fmt.parseInt(i32, num, 10);
            try list1.append(i);
        }
        if (it2.next()) |num| {
            const i = try std.fmt.parseInt(i32, num, 10);
            const v = try map1.getOrPut(i);
            if (!v.found_existing) {
                v.value_ptr.* = 0;
            }
            v.value_ptr.* += 1;
        }
    }

    var score: i64 = 0;
    for (list1.items) |elem| {
        if (map1.get(elem)) |v| {
            score += elem * v;
        }
    }
    std.debug.print("2: {}\n", .{score});
}

pub fn main() !void {
    try one();
    try two();
}
