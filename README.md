# Operating with Ranges of Numbers

The `ranges` module provides tools for creating ranges of numbers.

Ranges are represented by the generic `Range` iterator, which has start and
end points, and a step size.

```v
import ranges

// Iterate from 0 to 5 with step 2. Negative values also supported.
for i in ranges.range(0, 5, 2) {
	println(i)
}
// 0
// 2
// 4
```

See more usage examples in [ranges_test.v](ranges_test.v).
