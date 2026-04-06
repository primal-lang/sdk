### Ranges, Slices, and Spread

These features remove a large amount of current verbosity around collection construction and access.

#### Ranges

```primal
1..5      // [1, 2, 3, 4, 5]
1..<5     // [1, 2, 3, 4]
5..1      // [5, 4, 3, 2, 1]
```

#### Range Rules

- Ranges are numeric.
- `..` is inclusive.
- `..<` is exclusive at the end.
- Step is inferred as `+1` or `-1`.
- V1 does not need custom step syntax.

#### Slices

```primal
xs[2:5]
xs[:3]
xs[3:]
"hello"[1:4]
```

#### Slice Rules

- Supported on lists and strings.
- Omitted start means from the beginning.
- Omitted end means to the end.
- V1 should reject negative indices to stay consistent with current indexing rules.

#### Spread

List spread:

```primal
[0, ...xs, 99]
```

Map spread:

```primal
{"name": name, ...defaults, "active": true}
```

#### Spread Rules

- Spread is valid only inside list and map literals.
- List spread requires a list value.
- Map spread requires a map value.
- Spread expressions are evaluated in literal order.
