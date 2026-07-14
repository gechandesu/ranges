import ranges
import math.big

fn test_range() {
	mut result := []int{}
	for i in ranges.range[int](0, 10, 1) {
		result << i
	}
	assert result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

fn test_range_negative() {
	mut result := []int{}
	for i in ranges.range[int](10, 0, -1) {
		result << i
	}
	assert result == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
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
	assert ranges.from_string[int]('0-7,8-15')! == [
		ranges.range(0, 7, 1),
		ranges.range(8, 15, 1),
	]
	assert ranges.from_string[int]('0-6,7,8-15')! == [
		ranges.range(0, 6, 1),
		ranges.range(7, 7, 1),
		ranges.range(8, 15, 1),
	]
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
	assert ranges.from_string[int]('0-100/5')! == [ranges.range(0, 100, 5)]
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
	mut result := []Int{}
	start := Int{0}
	end := Int{5}
	step := Int{1}
	for i in ranges.range[Int](start, end, step) {
		result << i
	}
	assert result == [
		Int{0},
		Int{1},
		Int{2},
		Int{3},
		Int{4},
		Int{5},
	]
}

fn test_range_from_string_custom_type() {
	assert ranges.from_string_custom[Int]('0-5', fn (s string) !Int {
		if s.is_int() {
			return Int{
				val: s.int()
			}
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

fn test_range_reset() {
	mut result := []int{}
	mut iter := ranges.range(0, 5, 1)

	for {
		if elem := iter.next() {
			result << elem
		} else {
			break
		}
	}
	assert result == [0, 1, 2, 3, 4, 5]

	iter.reset()

	result = []int{}

	for i in iter {
		result << i
	}
	assert result == [0, 1, 2, 3, 4, 5]
}

fn test_range_new_with_step() {
	mut result := []int{}
	mut iter := ranges.range(0, 5, 1)

	for i in iter.with_step(2) {
		result << i
	}
	assert result == [0, 2, 4]
}

fn test_range_bounds() {
	r := ranges.range(0, 10, 2)
	a, b, c := r.bounds()
	assert a == 0
	assert b == 10
	assert c == 2
}

fn test_range_to_array_int() {
	r := ranges.range(0, 5, 1)
	assert r.to_array() == [0, 1, 2, 3, 4, 5]
}

fn test_range_to_array_float() {
	r := ranges.range[f64](3.0, 3.14, 0.01)
	assert r.to_array() == [
		f64(3.0),
		3.01,
		3.0199999999999996,
		3.0299999999999994,
		3.039999999999999,
		3.049999999999999,
		3.0599999999999987,
		3.0699999999999985,
		3.0799999999999983,
		3.089999999999998,
		3.099999999999998,
		3.1099999999999977,
		3.1199999999999974,
		3.1299999999999972,
		3.139999999999997,
	]
}

fn test_range_to_array_bigint() {
	r := ranges.range(big.zero_int, big.three_int, big.one_int)
	assert r.to_array() == [big.zero_int, big.one_int, big.two_int, big.three_int]
}

fn test_range_empty() {
	r := ranges.range(0, 0, 0)
	assert r.to_array() == []
}

fn test_range_empty_bigint() {
	r := ranges.range(big.zero_int, big.zero_int, big.zero_int)
	assert r.to_array() == []
}

fn test_range_is_empty() {
	r := ranges.range(0, 0, -9000)
	assert r.is_empty()
	assert r.to_array() == []
}

fn test_new() {
	r := ranges.new(0, 10, 1)!
	a, b, c := r.bounds()
	assert a == 0
	assert b == 10
	assert c == 1
	assert r.to_array() == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

fn test_new_with_step() {
	r := ranges.new(0, 10, 2)!
	assert r.to_array() == [0, 2, 4, 6, 8, 10]
}

fn test_new_reversed() {
	r := ranges.new(10, 0, -1)!
	assert r.to_array() == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
}

fn test_new_with_negative_step() {
	r := ranges.new(10, 0, -2)!
	assert r.to_array() == [10, 8, 6, 4, 2, 0]
}

fn test_new_single_item() {
	r := ranges.new(5, 5, 1)!
	assert r.to_array() == [5]
}

fn test_new_error_zero_step() {
	if _ := ranges.new(0, 10, 0) {
		assert false, 'expected error for zero step'
	} else {
		assert err.msg() == 'step value is zero'
	}
}

fn test_new_error_positive_step_start_gt_end() {
	if _ := ranges.new(10, 0, 1) {
		assert false, 'expected error for positive step with start > end'
	} else {
		assert err.msg() == 'step is positive, but start value is greather than end value'
	}
}

fn test_new_error_negative_step_start_lt_end() {
	if _ := ranges.new(0, 10, -1) {
		assert false, 'expected error for negative step with start <= end'
	} else {
		assert err.msg() == 'step is negative, but start value is lesser than or equals end value'
	}
}

fn test_new_error_negative_step_start_eq_end() {
	if _ := ranges.new(5, 5, -1) {
		assert false, 'expected error for negative step with start <= end'
	} else {
		assert err.msg() == 'step is negative, but start value is lesser than or equals end value'
	}
}
