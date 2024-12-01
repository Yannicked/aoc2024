#!/bin/bash

set -e

template=$(cat <<EOF
const std = @import("std");
const print = std.debug.print;

fn part1(input: []const u8) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        print("{s}\n", .{line});
    }
}

fn part2(input: []const u8) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        print("{s}\n", .{line});
    }
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
    const input = @embedFile("sample.txt");
    try part2(input);
}
EOF
)

day="$1"

directory=$(printf "day_%02d" "$day")

if [ -d "$directory" ]; then
    echo "This $directory already exists!"
    exit 1
fi

mkdir -p "$directory"
echo "$template" > "./$directory/main.zig"
touch "./$directory/sample.txt"
touch "./$directory/input.txt"

