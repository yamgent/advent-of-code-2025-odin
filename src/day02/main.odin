package aoc

import "core:fmt"
import "core:math"
import vmem "core:mem/virtual"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/02/input.txt", string)

Part1Result :: int
Part2Result :: int

Range :: struct {
	start: int,
	end:   int,
}

Input :: struct {
	ranges: [dynamic]Range,
}

parse_input :: proc(input: string) -> Input {
	arena: vmem.Arena
	arena_allocator := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	input_trimmed := strings.trim_space(input)

	entries, entries_err := strings.split(input_trimmed, ",", arena_allocator)
	if entries_err != nil {
		panic("cannot split entries")
	}

	result := Input {
		ranges = make([dynamic]Range),
	}

	for entry in entries {
		parts, parts_err := strings.split(entry, "-", arena_allocator)
		if parts_err != nil {
			panic("cannot split parts")
		}

		start, start_ok := strconv.parse_int(parts[0], 10)
		if !start_ok {
			panic("fail to parse start")
		}

		end, end_ok := strconv.parse_int(parts[1], 10)
		if !end_ok {
			panic("fail to parse start")
		}

		range := Range{start, end}
		append(&result.ranges, range)
	}

	return result
}

destroy_input :: proc(input: ^Input) {
	delete(input.ranges)
}

count_digits :: proc(num: int) -> int {
	acc := num
	count := 0

	for acc > 0 {
		count += 1
		acc /= 10
	}

	return count
}

split_number_into_two :: proc(num: int) -> ([2]int, bool) {
	result := [2]int{}

	total_digits := count_digits(num)
	if total_digits % 2 != 0 {
		return result, false
	}

	acc := num
	remaining_digits := total_digits
	for i in 0 ..< total_digits {
		digit := acc % 10
		acc /= 10

		if i >= total_digits / 2 {
			result[1] += digit * int(math.pow10_f64(f64(i - (total_digits / 2))))
		} else {
			result[0] += digit * int(math.pow10_f64(f64(i)))
		}
	}

	return result, true
}

part1 :: proc(input: string) -> Part1Result {
	parsed := parse_input(input)
	defer destroy_input(&parsed)

	result := 0

	for range in parsed.ranges {
		for num in range.start ..= range.end {
			split, split_success := split_number_into_two(num)
			if !split_success {
				continue
			}
			if split[0] == split[1] {
				result += num
			}
		}
	}

	return result
}

split_number :: proc(num: int, total_parts: int) -> ([20]int, bool) {
	result := [20]int{}

	total_digits := count_digits(num)
	if total_digits % total_parts != 0 {
		return result, false
	}

	part_total_digits := total_digits / total_parts

	acc := num
	remaining_digits := total_digits
	for i in 0 ..< total_digits {
		digit := acc % 10
		acc /= 10

		part_idx := i / part_total_digits
		result[part_idx] += digit * int(math.pow10_f64(f64(i - part_idx * part_total_digits)))
	}

	return result, true
}

part2 :: proc(input: string) -> Part2Result {
	parsed := parse_input(input)
	defer destroy_input(&parsed)

	result := 0

	for range in parsed.ranges {
		each_number: for num in range.start ..= range.end {
			total_digits := count_digits(num)

			each_total_parts: for total_parts in 2 ..= total_digits {
				split, split_success := split_number(num, total_parts)
				if !split_success {
					continue each_total_parts
				}

				for i in 1 ..< total_parts {
					if split[0] != split[i] {
						continue each_total_parts
					}
				}

				result += num
				continue each_number
			}
		}
	}

	return result
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 1227775554)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 15873079081)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 4174379265)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 22617871034)
}
