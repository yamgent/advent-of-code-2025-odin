package aoc

import "core:fmt"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/01/input.txt", string)

Part1Result :: int
Part2Result :: int

part1 :: proc(input: string) -> Part1Result {
	return 0
}

part2 :: proc(input: string) -> Part2Result {
	return 0
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: ``

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT), 0)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT), 0)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 0)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 0)
}
