package aoc

import "core:fmt"
import "core:math"
import "core:slice"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/03/input.txt", string)

Part1Result :: int
Part2Result :: int

get_digits :: proc(num: string, allocator := context.allocator) -> [dynamic]int {
	result := make([dynamic]int, allocator)
	for ch in num {
		append(&result, int(ch) - int('0'))
	}
	return result
}

solve_joltage_p1 :: proc(num: string) -> int {
	digits := get_digits(num)
	defer delete(digits)

	max_so_far := make([dynamic]int, len(digits), len(digits))
	defer delete(max_so_far)

	max_so_far[0] = digits[0]

	for i := 1; i < len(digits); i += 1 {
		max_so_far[i] = max(max_so_far[i - 1], digits[i])
	}

	best := max_so_far[len(digits) - 2] * 10 + digits[len(digits) - 1]

	for i := len(digits) - 2; i > 0; i -= 1 {
		best = max(best, max_so_far[i - 1] * 10 + digits[i])
	}

	return best
}

part1 :: proc(input: string) -> Part1Result {
	lines, lines_err := strings.split_lines(strings.trim_space(input))
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	sum := 0

	for line in lines {
		sum += solve_joltage_p1(line)
	}

	return sum
}

solve_joltage_p2 :: proc(num: string, total_size: int) -> int {
	digits_reversed := get_digits(num)
	defer delete(digits_reversed)
	slice.reverse(digits_reversed[:])

	current_max_so_far := make([dynamic]int, 0, len(digits_reversed))
	defer delete(current_max_so_far)
	next_max_so_far := make([dynamic]int, 0, len(digits_reversed))
	defer delete(next_max_so_far)

	// group size = 1
	append(&current_max_so_far, digits_reversed[0])
	for i := 1; i < len(digits_reversed); i += 1 {
		append(&current_max_so_far, max(current_max_so_far[i - 1], digits_reversed[i]))
	}

	// group size = s
	for s := 2; s <= total_size; s += 1 {
		clear(&next_max_so_far)

		acc := 0
		for i := 0; i < s; i += 1 {
			acc += digits_reversed[i] * int(math.pow_f64(10, f64(i)))
		}

		append(&next_max_so_far, acc)
		for i := s; i < len(digits_reversed); i += 1 {
			candidate :=
				digits_reversed[i] * int(math.pow_f64(10, f64(s - 1))) +
				current_max_so_far[i - s + 1]

			append(&next_max_so_far, max(candidate, next_max_so_far[i - s]))
		}

		current_max_so_far, next_max_so_far = next_max_so_far, current_max_so_far
	}

	return current_max_so_far[len(current_max_so_far) - 1]
}

part2 :: proc(input: string) -> Part2Result {
	lines, lines_err := strings.split_lines(strings.trim_space(input))
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	sum := 0

	for line in lines {
		sum += solve_joltage_p2(line, 12)
	}

	return sum
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
987654321111111
811111111111119
234234234234278
818181911112111
`

@(test)
test_solve_joltage_p1 :: proc(t: ^testing.T) {
	testing.expect_value(t, solve_joltage_p1("987654321111111"), 98)
	testing.expect_value(t, solve_joltage_p1("811111111111119"), 89)
	testing.expect_value(t, solve_joltage_p1("234234234234278"), 78)
	testing.expect_value(t, solve_joltage_p1("818181911112111"), 92)
}

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 357)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 17376)
}

@(test)
test_solve_joltage_p2 :: proc(t: ^testing.T) {
	testing.expect_value(t, solve_joltage_p2("987654321111111", 12), 987654321111)
	testing.expect_value(t, solve_joltage_p2("811111111111119", 12), 811111111119)
	testing.expect_value(t, solve_joltage_p2("234234234234278", 12), 434234234278)
	testing.expect_value(t, solve_joltage_p2("818181911112111", 12), 888911112111)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 3121910778619)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 172119830406258)
}
