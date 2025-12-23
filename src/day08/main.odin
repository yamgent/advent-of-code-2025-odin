package aoc

import "core:fmt"
import vmem "core:mem/virtual"
import "core:slice/heap"
import "core:sort"
import "core:strconv"
import "core:strings"
import "core:testing"

ACTUAL_INPUT :: #load("../../actual_inputs/2025/08/input.txt", string)

Part1Result :: int
Part2Result :: int

parse_input :: proc(input: string, allocator := context.allocator) -> [dynamic][3]int {
	arena: vmem.Arena
	arena_allocator := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	input_trimmed := strings.trim_space(input)

	lines, lines_err := strings.split_lines(input_trimmed, arena_allocator)
	if lines_err != nil {
		panic("cannot split into lines")
	}

	result := make([dynamic][3]int, allocator)

	for line in lines {
		parts, parts_err := strings.split(line, ",", arena_allocator)
		if parts_err != nil {
			panic("cannot split line into parts")
		}

		parts_num: [3]int

		for i in 0 ..< 3 {
			part_num, part_ok := strconv.parse_int(parts[i])
			if !part_ok {
				panic(fmt.tprintf("tried to parse %v into int but failed", parts[i]))
			}
			parts_num[i] = part_num
		}

		append(&result, parts_num)
	}

	return result
}

Distance :: struct {
	dist: int,
	a:    int,
	b:    int,
}

get_dist :: proc(a: [3]int, b: [3]int) -> int {
	d := a - b
	return d.x * d.x + d.y * d.y + d.z * d.z
}

// odin's binary heap is a max-heap, so we need to reverse the
// comparison
heap_dist_less :: proc(a: Distance, b: Distance) -> bool {
	return a.dist >= b.dist
}

UnionFind :: struct {
	parent: [dynamic]int,
	size:   [dynamic]int,
}

uf_init :: proc(total: int) -> UnionFind {
	parent := make([dynamic]int, total, total)
	rank := make([dynamic]int, total, total)

	for i in 0 ..< total {
		parent[i] = i
		rank[i] = 1
	}

	return UnionFind{parent, rank}
}

uf_find :: proc(uf: ^UnionFind, i: int) -> int {
	root := i

	for root != uf.parent[root] {
		root = uf.parent[root]
	}

	update := i
	for update != root {
		uf.parent[update], update = root, uf.parent[update]
	}

	return root
}

uf_union :: proc(uf: ^UnionFind, a: int, b: int) {
	ai := uf_find(uf, a)
	bi := uf_find(uf, b)

	if ai != bi {
		if uf.size[ai] < uf.size[bi] {
			ai, bi = bi, ai
		}
		uf.parent[bi] = ai
		uf.size[ai] += uf.size[bi]
	}
}

uf_delete :: proc(uf: ^UnionFind) {
	delete(uf.parent)
	delete(uf.size)
}

make_distances_binary_heap :: proc(
	boxes: [dynamic][3]int,
	allocator := context.allocator,
) -> [dynamic]Distance {
	distances := make([dynamic]Distance, allocator)

	for ai := 0; ai < len(boxes); ai += 1 {
		for bi := ai + 1; bi < len(boxes); bi += 1 {
			append(&distances, Distance{dist = get_dist(boxes[ai], boxes[bi]), a = ai, b = bi})
		}
	}

	heap.make(distances[:], heap_dist_less)

	return distances
}

part1 :: proc(input: string, connect_count: int) -> Part1Result {
	boxes := parse_input(input)
	defer delete(boxes)

	distances := make_distances_binary_heap(boxes)
	defer delete(distances)

	ufs := uf_init(len(boxes))
	defer uf_delete(&ufs)

	for _ in 0 ..< connect_count {
		next_distance := distances[0]

		uf_union(&ufs, next_distance.a, next_distance.b)

		heap.pop(distances[:], heap_dist_less)
		pop(&distances)
	}

	sizes := make(map[int]int)
	defer delete(sizes)

	for id in 0 ..< len(ufs.parent) {
		sizes[uf_find(&ufs, id)] += 1
	}

	sizes_sorted := make([dynamic]int)
	defer delete(sizes_sorted)

	for _, v in sizes {
		append(&sizes_sorted, v)
	}

	sort.quick_sort(sizes_sorted[:])

	a := sizes_sorted[len(sizes_sorted) - 1]
	b := sizes_sorted[len(sizes_sorted) - 2]
	c := sizes_sorted[len(sizes_sorted) - 3]

	return a * b * c
}

part2 :: proc(input: string) -> Part2Result {
	boxes := parse_input(input)
	defer delete(boxes)

	distances := make_distances_binary_heap(boxes)
	defer delete(distances)

	ufs := uf_init(len(boxes))
	defer uf_delete(&ufs)

	used := make(map[[3]int]struct{})
	defer delete(used)

	for {
		next_distance := distances[0]

		uf_union(&ufs, next_distance.a, next_distance.b)

		used[next_distance.a] = {}
		used[next_distance.b] = {}

		heap.pop(distances[:], heap_dist_less)
		pop(&distances)

		if len(used) == len(boxes) {
			return boxes[next_distance.a].x * boxes[next_distance.b].x
		}
	}
}

main :: proc() {
	fmt.println(part1(ACTUAL_INPUT, 1000))
	fmt.println(part2(ACTUAL_INPUT))
}

SAMPLE_INPUT :: `
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
`

@(test)
test_part1_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE_INPUT, 10), 40)
}

@(test)
test_part1_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(ACTUAL_INPUT, 1000), 24360)
}

@(test)
test_part2_sample :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE_INPUT), 25272)
}

@(test)
test_part2_actual :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(ACTUAL_INPUT), 2185817796)
}
