package aoc

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/05/input.txt", string)

Part1Result :: int
Part2Result :: int

Range :: struct {
	start: int,
	end:   int,
}

Input :: struct {
	ranges:      [dynamic]Range,
	ingredients: [dynamic]int,
}

parse_input :: proc(input: string, allocator := context.allocator) -> Input {
	trimmed_input := strings.trim_space(input)
	lines, lines_err := strings.split_lines(strings.trim_space(trimmed_input))
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split input into lines")
	}

	ranges := make([dynamic]Range, allocator)
	ingredients := make([dynamic]int, allocator)

	parsing_range := true

	for &line in lines {
		if line == "" {
			parsing_range = false
		} else if parsing_range {
			range := Range{}
			part_idx := 0

			for part in strings.split_iterator(&line, "-") {
				num, num_ok := strconv.parse_int(part)

				if !num_ok {
					panic(fmt.tprintf("expected number, found %v in %v", part, line))
				}

				switch part_idx {
				case 0:
					range.start = num
				case 1:
					range.end = num
				case:
					panic(fmt.tprintf("this line has too many parts, line: %v", line))
				}

				part_idx += 1
			}

			append(&ranges, range)
		} else {
			num, num_ok := strconv.parse_int(line)

			if !num_ok {
				panic(fmt.tprintf("expected number, found %v", line))
			}

			append(&ingredients, num)
		}
	}

	return Input{ranges, ingredients}
}

delete_input :: proc(input: ^Input) {
	delete(input.ranges)
	delete(input.ingredients)
}

part1 :: proc(input: string) -> Part1Result {
	list := parse_input(input)
	defer delete_input(&list)

	count := 0

	next_ingredient: for ingredient in list.ingredients {
		for range in list.ranges {
			if ingredient >= range.start && ingredient <= range.end {
				count += 1
				continue next_ingredient
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
3-5
10-14
16-20
12-18

1
5
8
11
17
32
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 3)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 712)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 0)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 0)
}
