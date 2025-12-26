import ranges
import math.big

fn test_range() {
	mut result := []int{}
	for i in ranges.range[int](0, 10, 1) {
		result << i
	}
	assert result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

fn test_range_exclusive() {
	mut result := []int{}
	for i in ranges.range[int](0, 10, 1, exclusive: true) {
		result << i
	}
	assert result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
}

fn test_range_negative() {
	mut result := []int{}
	for i in ranges.range[int](10, 0, -1) {
		result << i
	}
	assert result == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
}

fn test_range_negative_exclusive() {
	mut result := []int{}
	for i in ranges.range[int](10, 0, -1, exclusive: true) {
		result << i
	}
	assert result == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
}

fn test_range_with_step() {
	mut result := []int{}
	for i in ranges.range[int](0, 10, 2) {
		result << i
	}
	assert result == [0, 2, 4, 6, 8, 10]
}

fn test_range_with_negative_step() {
	mut result := []int{}
	for i in ranges.range[int](5, 0, -1) {
		result << i
	}
	assert result == [5, 4, 3, 2, 1, 0]
}

fn test_range_with_non_odd_step() {
	mut result := []int{}
	for i in ranges.range[int](0, 5, 2) {
		result << i
	}
	assert result == [0, 2, 4]
}

fn test_range_single_item() {
	mut result := []int{}
	for i in ranges.range(0, 0, 1) {
		result << i
	}
	assert result == [0]
}

fn test_range_single_item_exclusive() {
	mut result := []int{}
	for i in ranges.range(0, 1, 1, exclusive: true) {
		result << i
	}
	assert result == [0]
}

fn test_range_bigint() {
	start := big.zero_int
	end := big.integer_from_int(5)
	step := big.one_int
	mut result := []big.Integer{}
	for i in ranges.range[big.Integer](start, end, step) {
		result << i
	}
	assert result == [
		big.integer_from_int(0),
		big.integer_from_int(1),
		big.integer_from_int(2),
		big.integer_from_int(3),
		big.integer_from_int(4),
		big.integer_from_int(5),
	]
}

fn test_range_from_string() {
	assert ranges.from_string[int]('0-10')! == [ranges.range(0, 10, 1)]
	assert ranges.from_string[int]('0-7,8-15')! == [ranges.range(0, 7, 1),
		ranges.range(8, 15, 1)]
	assert ranges.from_string[int]('0-6,7,8-15')! == [ranges.range(0, 6, 1),
		ranges.range(7, 7, 1), ranges.range(8, 15, 1)]
	assert ranges.from_string[i64]('5:2:15', sep: ':')! == [ranges.range[i64](5, 15, 2)]
	assert ranges.from_string[int]('100:-1:0', sep: ':')! == [
		ranges.range(100, 0, -1),
	]
	assert ranges.from_string[int]('1..10', sep: '..')! == [ranges.range(1, 10, 1)]
	assert ranges.from_string[int]('-256..256', sep: '..')! == [
		ranges.range(-256, 256, 1),
	]
	assert ranges.from_string[int]('256..-256', sep: '..')! == [
		ranges.range(256, -256, 1),
	]
	assert ranges.from_string[f32]('0.0..99.99', sep: '..')! == [
		ranges.range[f32](0.0, 99.99, 1),
	]
}

struct Int {
	val int
}

fn (a Int) + (b Int) Int {
	return Int{a.val + b.val}
}

fn (a Int) - (b Int) Int {
	return Int{a.val - b.val}
}

fn (a Int) < (b Int) bool {
	return a.val < b.val
}

fn (a Int) == (b Int) bool {
	return a.val == b.val
}

fn test_range_custom_type() {
	// vfmt off
	mut result := []Int{}
	for i in ranges.range[Int](Int{ val: 0 }, Int{ val: 5 }, Int{ val: 1 }) {
		result << i
	}
	assert result == [Int{0}, Int{1}, Int{2}, Int{3}, Int{4}, Int{5}]
	// vfmt on
}

//
// Note this bug: https://github.com/vlang/v/issues/26156
//

fn test_range_from_string_custom_type() {
	assert ranges.from_string_custom[Int]('0-5', fn (s string) !Int {
		if s.is_int() {
			return Int{ val: s.int() }
		} else {
			return error('invalid integer value: ${s}')
		}
	})! == [ranges.range[Int](Int{0}, Int{5}, Int{1})]

	convert_fn := fn (s string) !Int {
		if s.is_int() {
			return Int{
				val: s.int()
			}
		} else {
			return error('invalid integer value: ${s}')
		}
	}
	assert ranges.from_string_custom[Int]('0..10', convert_fn,
		sep: '..'
	)! == [ranges.range[Int](Int{0}, Int{10}, Int{1})]
}
