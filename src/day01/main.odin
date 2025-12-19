package day01

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/01/input.txt", string)

Part1Result :: int
Part2Result :: int

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

START_NUMBER :: 50
TOTAL_NUMBERS :: 100

part1 :: proc(input: string) -> Part1Result {
	input := parse_input(input)
	defer delete_input(&input)

	dial := START_NUMBER
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

		dial %= TOTAL_NUMBERS
		if dial == 0 {
			count += 1
		}
	}

	return count
}


part2 :: proc(input: string) -> Part2Result {
	input := parse_input(input)
	defer delete_input(&input)

	dial := START_NUMBER
	count := 0

	for command in input.commands {
		switch command.type {
		case .Left:
			{
				if dial == command.count {
					count += 1
				} else if dial < command.count {
					remaining := command.count - dial
					if dial != 0 {
						count += 1
					}
					count += remaining / TOTAL_NUMBERS
				}
				dial = (dial - command.count) %% TOTAL_NUMBERS
			}
		case .Right:
			{
				count += (dial + command.count) / TOTAL_NUMBERS
				dial = (dial + command.count) %% TOTAL_NUMBERS
			}
		}
	}

	return count
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: #load("sample.txt", string)

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 3)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 1066)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 6)
}

@(test)
test_part2_additional :: proc(t: ^testing.T) {
	testing.expect_value(t, part2("L50"), 1)
	testing.expect_value(t, part2("L50\nL99"), 1)
	testing.expect_value(t, part2("L50\nL100"), 2)
	testing.expect_value(t, part2("L50\nL101"), 2)
	testing.expect_value(t, part2("L50\nL199"), 2)
	testing.expect_value(t, part2("L50\nL200"), 3)
	testing.expect_value(t, part2("L50\nL201"), 3)
	testing.expect_value(t, part2("L50\nR99"), 1)
	testing.expect_value(t, part2("L50\nR100"), 2)
	testing.expect_value(t, part2("L50\nR101"), 2)
	testing.expect_value(t, part2("L50\nR199"), 2)
	testing.expect_value(t, part2("L50\nR200"), 3)
	testing.expect_value(t, part2("L50\nR201"), 3)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 6223)
}
