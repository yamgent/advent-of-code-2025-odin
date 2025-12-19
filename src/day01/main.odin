package day01

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/01/input.txt", string)

part1 :: proc(input: string) -> string {
	input := strings.trim_space(input)
	lines, lines_err := strings.split_lines(input)
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	dial := 50
	count := 0

	for line in lines {
		dir := line[0]

		num_str := line[1:]
		num, num_ok := strconv.parse_int(num_str, 10)
		if !num_ok {
			panic("expected number")
		}

		if dir == 'L' {
			dial -= num
		} else if dir == 'R' {
			dial += num
		} else {
			panic("invalid direction")
		}

		dial %= 100
		if dial == 0 {
			count += 1
		}
	}

	result_builder := strings.builder_make()
	defer strings.builder_destroy(&result_builder)
	return fmt.sbprintf(&result_builder, "%i", count)
}

part2 :: proc(input: string) -> string {
	return ""
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: #load("sample.txt", string)

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), "3")
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), "1066")
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), "")
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), "")
}
