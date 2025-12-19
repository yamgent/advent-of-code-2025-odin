package day01

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/01/input.txt", string)

CommandType :: enum {
	Left,
	Right,
}

Command :: struct {
	type:  CommandType,
	count: int,
}

Input :: struct {
	commands: [dynamic]Command,
}

parse_input :: proc(input: string, allocator := context.allocator) -> Input {
	result := Input {
		commands = make([dynamic]Command, allocator),
	}

	input := strings.trim_space(input)
	lines, lines_err := strings.split_lines(input)
	defer delete(lines)

	if lines_err != nil {
		panic("cannot split lines")
	}

	for line in lines {
		dir := line[0]

		num_str := line[1:]
		num, num_ok := strconv.parse_int(num_str, 10)
		if !num_ok {
			panic("expected number")
		}

		type: CommandType

		if dir == 'L' {
			type = .Left
		} else if dir == 'R' {
			type = .Right
		} else {
			panic("invalid direction")
		}

		append(&result.commands, Command{type = type, count = num})
	}

	return result
}

delete_input :: proc(input: ^Input) {
	delete(input.commands)
}

part1 :: proc(input: string) -> string {
	input := parse_input(input)
	defer delete_input(&input)

	dial := 50
	count := 0

	for command in input.commands {
		switch command.type {
		case .Left:
			{
				dial -= command.count
			}
		case .Right:
			{
				dial += command.count
			}
		}

		dial %= 100
		if dial == 0 {
			count += 1
		}
	}

	result_builder := strings.builder_make()
	defer strings.builder_destroy(&result_builder)
	// TODO: is this use-after-free?
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
	testing.expect_value(t, part2(SAMPLE_INPUT), "6")
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), "6223")
}
