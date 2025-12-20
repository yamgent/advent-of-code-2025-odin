package aoc

import "core:fmt"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/04/input.txt", string)

Part1Result :: int
Part2Result :: int

World :: struct {
	grid: map[[2]int]struct{},
	size: [2]int,
}

make_world :: proc(allocator := context.allocator) -> World {
	return World{grid = make(map[[2]int]struct{}, allocator), size = {}}
}

free_world :: proc(world: ^World) {
	delete(world.grid)
}

parse_input :: proc(input: string, allocator := context.allocator) -> World {
	world := make_world(allocator)

	input_trimmed := strings.trim_space(input)
	lines := strings.split_lines(input_trimmed)
	defer delete(lines)

	world.size.x = len(lines[0])
	world.size.y = len(lines)

	for y := 0; y < world.size.y; y += 1 {
		for x := 0; x < world.size.x; x += 1 {
			if lines[y][x] == '@' {
				world.grid[{x, y}] = {}
			}
		}
	}

	return world
}

count_neighbours :: proc(grid: map[[2]int]struct{}, coord: [2]int) -> int {
	neighbours := [?][2]int {
		{coord.x - 1, coord.y - 1},
		{coord.x, coord.y - 1},
		{coord.x + 1, coord.y - 1},
		{coord.x - 1, coord.y},
		{coord.x + 1, coord.y},
		{coord.x - 1, coord.y + 1},
		{coord.x, coord.y + 1},
		{coord.x + 1, coord.y + 1},
	}

	count := 0

	for neighbour in neighbours {
		if _, exists := grid[neighbour]; exists {
			count += 1
		}
	}

	return count
}

part1 :: proc(input: string) -> Part1Result {
	world := parse_input(input)
	defer free_world(&world)

	count := 0

	for y := 0; y < world.size.y; y += 1 {
		for x := 0; x < world.size.x; x += 1 {
			if _, exists := world.grid[{x, y}]; exists {
				neighbours := count_neighbours(world.grid, {x, y})
				if neighbours < 4 {
					count += 1
				}
			}
		}
	}

	return count
}

part2 :: proc(input: string) -> Part2Result {
	return 0
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 13)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 1474)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 0)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 0)
}
