package aoc

import "core:fmt"
import vmem "core:mem/virtual"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/07/input.txt", string)

Part1Result :: int
Part2Result :: int

World :: struct {
	start_x:   int,
	end_y:     int,
	splitters: map[int]map[int]struct{},
}

parse_input :: proc(input: string, allocator := context.allocator) -> World {
	arena: vmem.Arena
	arena_allocator := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	input_trimmed := strings.trim_space(input)
	lines, lines_err := strings.split_lines(input_trimmed, arena_allocator)

	if lines_err != nil {
		panic("Fail to parse input to lines")
	}

	start_x := 0
	end_y := 0
	splitters := make(map[int]map[int]struct{}, allocator)

	for ch, x in lines[0] {
		if ch == 'S' {
			start_x = x
			break
		}
	}

	end_y = len(lines)

	for line, y in lines {
		for ch, x in line {
			if ch == '^' {
				_, list, _, alloc_err := map_entry(&splitters, y)

				if alloc_err != nil {
					panic("Fail to allocate")
				}

				list[x] = {}
			}
		}
	}

	return World{start_x, end_y, splitters}
}

delete_world :: proc(world: ^World) {
	for _, v in world.splitters {
		delete(v)
	}
	delete(world.splitters)
}

solve :: proc(input: string) -> (Part1Result, Part2Result) {
	world := parse_input(input)
	defer delete_world(&world)

	hit := 0

	current_xs := make(map[int]int)
	defer delete(current_xs)
	next_xs := make(map[int]int)
	defer delete(next_xs)

	current_xs[world.start_x] = 1
	current_y := 1

	for current_y < world.end_y {
		if current_splitters, have_splitters := world.splitters[current_y]; have_splitters {
			clear(&next_xs)

			for x, x_beams in current_xs {
				if _, have_splitter := current_splitters[x]; have_splitter {
					hit += 1
					next_xs[x - 1] += x_beams
					next_xs[x + 1] += x_beams
				} else {
					next_xs[x] += x_beams
				}
			}

			current_xs, next_xs = next_xs, current_xs
		}

		current_y += 1
	}

	total_beams := 0
	for _, beams in current_xs {
		total_beams += beams
	}

	return hit, total_beams
}

part1 :: proc(input: string) -> Part1Result {
	ans, _ := solve(input)
	return ans
}

part2 :: proc(input: string) -> Part2Result {
	_, ans := solve(input)
	return ans
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 21)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 1541)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 40)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 80158285728929)
}
