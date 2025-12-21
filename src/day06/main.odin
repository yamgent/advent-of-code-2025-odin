package aoc

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/06/input.txt", string)

Part1Result :: int
Part2Result :: int

Op :: enum {
	Plus,
	Mul,
}

part1 :: proc(input: string) -> Part1Result {
	input_trimmed := strings.trim_space(input)
	lines, lines_err := strings.split_lines(input_trimmed)
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	ops := make([dynamic]Op)
	defer delete(ops)
	vals := make([dynamic]int)
	defer delete(vals)

	for ch in lines[len(lines) - 1] {
		switch ch {
		case '+':
			append(&ops, Op.Plus)
			append(&vals, 0)
		case '*':
			append(&ops, Op.Mul)
			append(&vals, 1)
		}
	}

	for line, line_idx in lines {
		if line_idx == len(lines) - 1 {
			break
		}

		numbers, numbers_err := strings.split(line, " ")
		defer delete(numbers)

		if numbers_err != nil {
			panic(fmt.tprintf("cannot split line %i", line_idx))
		}

		current_idx := 0

		for num_str in numbers {
			if len(strings.trim_space(num_str)) == 0 {
				continue
			}

			num, num_ok := strconv.parse_int(num_str, 10)
			if !num_ok {
				panic(fmt.tprintf("unable to parse number %v, line %i", num_str, line_idx))
			}

			switch ops[current_idx] {
			case .Plus:
				vals[current_idx] += num
			case .Mul:
				vals[current_idx] *= num
			}

			current_idx += 1
		}
	}

	acc := 0
	for val in vals {
		acc += val
	}

	return acc
}

Vals :: struct {
	op:    Op,
	start: int,
	end:   int,
	val:   int,
}

part2 :: proc(input: string) -> Part2Result {
	input_trimmed := strings.trim_space(input)
	lines, lines_err := strings.split_lines(input_trimmed)
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	vals := make([dynamic]Vals)
	defer delete(vals)

	for ch, idx in lines[len(lines) - 1] {
		if ch == '+' || ch == '*' {
			if len(vals) > 0 {
				vals[len(vals) - 1].end = idx - 2
			}

			switch ch {
			case '+':
				append(&vals, Vals{op = .Plus, start = idx, end = idx, val = 0})
			case '*':
				append(&vals, Vals{op = .Mul, start = idx, end = idx, val = 1})
			}
		}
	}

	furthest_x := len(lines[0])
	for line in lines {
		furthest_x = max(furthest_x, len(line))
	}

	vals[len(vals) - 1].end = furthest_x - 1

	for &val in vals {
		for x := val.end; x >= val.start; x -= 1 {
			current_number := 0

			for y := 0; y < len(lines) - 1; y += 1 {
				ch := lines[y][x]
				if ch != ' ' {
					current_number = current_number * 10 + (int(ch) - int('0'))
				}
			}

			switch val.op {
			case .Plus:
				val.val += current_number
			case .Mul:
				val.val *= current_number
			}
		}
	}

	acc := 0
	for val in vals {
		acc += val.val
	}

	return acc
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 4277556)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 4722948564882)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 3263827)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 9581313737063)
}
