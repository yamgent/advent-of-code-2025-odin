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

delete_world :: proc(world: ^World) {
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

get_adjacents :: proc(coord: [2]int) -> [8][2]int {
	return {
		{coord.x - 1, coord.y - 1},
		{coord.x, coord.y - 1},
		{coord.x + 1, coord.y - 1},
		{coord.x - 1, coord.y},
		{coord.x + 1, coord.y},
		{coord.x - 1, coord.y + 1},
		{coord.x, coord.y + 1},
		{coord.x + 1, coord.y + 1},
	}
}

count_neighbours :: proc(grid: map[[2]int]struct{}, coord: [2]int) -> int {
	candidates := get_adjacents(coord)
	count := 0

	for candidate in candidates {
		if _, exists := grid[candidate]; exists {
			count += 1
		}
	}

	return count
}

part1 :: proc(input: string) -> Part1Result {
	world := parse_input(input)
	defer delete_world(&world)

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
	world := parse_input(input)
	defer delete_world(&world)

	count := 0

	paper_roll_to_process := make(map[[2]int]struct{})
	defer delete(paper_roll_to_process)
	paper_roll_to_delete := make(map[[2]int]struct{})
	defer delete(paper_roll_to_delete)
	next_rolls := make(map[[2]int]struct{})
	defer delete(next_rolls)

	for coord in world.grid {
		paper_roll_to_process[coord] = {}
	}

	for len(paper_roll_to_process) > 0 {
		clear(&next_rolls)
		clear(&paper_roll_to_delete)

		for roll in paper_roll_to_process {
			neighbours_count := count_neighbours(world.grid, roll)
			if neighbours_count < 4 {
				count += 1
				paper_roll_to_delete[roll] = {}

				potential_neighbours := get_adjacents(roll)
				for candidate in potential_neighbours {
					if _, exists := world.grid[candidate]; exists {
						next_rolls[candidate] = {}
					}
				}
			}
		}

		for roll in paper_roll_to_delete {
			delete_key(&world.grid, roll)
			delete_key(&next_rolls, roll)
		}

		paper_roll_to_process, next_rolls = next_rolls, paper_roll_to_process
	}

	return count
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
	testing.expect_value(t, part2(SAMPLE_INPUT), 43)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 8910)
}
