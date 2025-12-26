module ranges

import strconv
import math.big

struct Range[T] {
	limit  T
	step   T
	is_neg bool
mut:
	cur T
}

// next returns the new element from range or none if range end is reached.
pub fn (mut r Range[T]) next() ?T {
	if (r.is_neg && r.cur < r.limit) || (!r.is_neg && r.cur > r.limit) {
		return none
	}
	defer {
		r.cur += r.step
	}
	return r.cur
}

@[params]
pub struct RangeConfig {
pub:
	// If true exclude the end value from range.
	exclusive bool
}

// range creates new Range iterator with given start, end and step values.
//
// Generally numbers are expected. If type is a struct the following operators
// must be overloaded to perform comparisons and arithmetics: `+`, `-`, `<`, `==`.
// See https://docs.vlang.io/limited-operator-overloading.html for details.
//
// By default, the range includes the end value. This behavior can be changed
// by enabling the 'exclusive' option.
//
// Note: Zero step value will cause an infitite loop!
pub fn range[T](start T, end T, step T, config RangeConfig) Range[T] {
	mut limit := end
	if config.exclusive {
		limit -= step
	}
	return Range[T]{
		limit:  limit
		step:   step
		cur:    start
		is_neg: start > end
	}
}

@[params]
pub struct RangeFromStringConfig {
	RangeConfig
pub:
	sep       string = '-'
	group_sep string = ','
}

// from_string parses the input string and returns an array of iterators.
// This function supports only V native number types and big.Integer.
// Use from_string_custom if you want to use custom type with special string
// convertion rules.
//
// Supported string formats are `start-end`, `start[:step]end`. start and end
// values are sepatared by 'sep' which is hypen (`-`) by default. Single number
// will be interpreted as range of one element. Several ranges can be specified
// in a line, separated by 'group_sep' (comma by default). 'sep' and 'group_sep'
// can be overrided by user.
//
// Some example input strings:
//
// * `5` - range from 5 to 5 (single element).
// * `0-10` - range from 0 to 10.
// * `15:-1:0` - range in MathLab-style syntax from 15 to 0 with negative step -1.
// * `1..8` - range from 1 to 8 with '..' sep.
// * `0-7,64-71` - multiple ranges: from 0 to 7 and from 64 to 71.
//
// Only MathLab-style syntax allows you to specify a step directly in the string.
// For all other cases, the step is equal to one.
//
// Example: assert ranges.from_string[int]('1-7')! == [ranges.range(1, 7, 1)]
pub fn from_string[T](s string, config RangeFromStringConfig) ![]Range[T] {
	mut result := []Range[T]{}
	for i in s.split(config.group_sep) {
		range_str := parse_string(i, config.sep)!
		// vfmt off
		result << range[T](
			convert_string[T](range_str[0])!,
			convert_string[T](range_str[1])!,
			convert_string[T](range_str[2])!,
			config.RangeConfig)
		// vfmt on
	}
	return result
}

pub type StringConvertFn[T] = fn (s string) !T

// from_string_custom parses the input string using `conv` function to convert
// string values into numbers and returns an array of iterators. This is an extended
// version of from_string with the same semanthics.
// Example:
// ```v
// import math.big
// import ranges
//
// conv := fn (s string) !big.Integer {
// 	return big.integer_from_string(s)!
// }
//
// for range in ranges.from_string_custom('0-3,8,11-13', conv)! {
// 	for i in range {
// 		println(i)
// 	}
// }
// // 0
// // 1
// // 2
// // 3
// // 8
// // 11
// // 12
// // 13
// ```
pub fn from_string_custom[T](s string, conv StringConvertFn[T], config RangeFromStringConfig) ![]Range[T] {
	mut result := []Range[T]{}
	for i in s.split(config.group_sep) {
		range_str := parse_string(i, config.sep)!
		start := conv[T](range_str[0])!
		end := conv[T](range_str[1])!
		step := conv[T](range_str[2])!
		result << range(start, end, step, config.RangeConfig)
	}
	return result
}

fn parse_string(s string, sep string) ![]string {
	parts := s.split(sep)
	if parts.any(|x| x.is_blank()) || parts.len !in [1, 2, 3] {
		return error('`start${sep}end` or `start[:step]:end`' +
			"formatted string expected, not '${s}'")
	}
	if parts.len == 1 {
		return [parts[0], parts[0], '1']
	} else if parts.len == 2 {
		return [parts[0], parts[1], '1']
	} else if sep == ':' && parts.len == 3 {
		return [parts[0], parts[2], parts[1]]
	}
	return error('invalid range string: ${s}')
}

fn convert_string[T](s string) !T {
	$match T {
		int {
			return strconv.atoi(s)!
		}
		i8 {
			return strconv.atoi8(s)!
		}
		i16 {
			return strconv.atoi16(s)!
		}
		i32 {
			return strconv.atoi32(s)!
		}
		i64 {
			return strconv.atoi64(s)!
		}
		isize {
			return isize(strconv.atoi64(s)!)
		}
		u8 {
			return strconv.atou8(s)!
		}
		u16 {
			return strconv.atou16(s)!
		}
		u32 {
			return strconv.atou32(s)!
		}
		u64 {
			return strconv.atou64(s)!
		}
		usize {
			return usize(strconv.atou64(s)!)
		}
		f32 {
			return f32(strconv.atof64(s)!)
		}
		f64 {
			return strconv.atof64(s)!
		}
		big.Integer {
			return big.integer_from_string(s)!
		}
		$else {
			return error("cannot convert '${s}' to ${typeof[T]().name}")
		}
	}
	return error('unexpected string convert error')
}
