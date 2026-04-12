Destructuring should be shared by:

- `do ... end` bindings
- value bindings inside `where`
- comprehension generators

#### Supported Patterns

List patterns:

```primal
[a, b] = [10, 20]
[head, ...tail] = [1, 2, 3, 4]
[_, second, ...rest] = [10, 20, 30, 40]
```

Map patterns:

```primal
{"x": x, "y": y} = {"x": 3, "y": 4}
{"x": x, ...rest} = {"x": 1, "y": 2, "z": 3}
```

Nested patterns:

```primal
[name, {"age": age, "tags": [firstTag, ...otherTags]}] =
  ["Alice", {"age": 30, "tags": ["admin", "editor"]}]
```

#### Rules

- `_` discards a matched value.
- `...rest` captures remaining list elements or remaining map entries.
- `...rest` may appear at most once in a pattern.
- In list patterns, `...rest` must be in the final position.
- In map patterns, `...rest` captures unmatched entries.
- Map patterns require listed keys to exist.
- Extra map keys are ignored unless captured by `...rest`.
- List patterns require exact length unless `...rest` is present.
- Reusing the same bound name in a single pattern should be a semantic error.

#### Error Model

Pattern mismatch should raise a runtime error.

Examples:

```primal
main() = do
  [a, b] = [1]
  a + b
end
```

```primal
main() = do
  {"x": x} = {"y": 10}
  x
end
```

Both should fail with a dedicated runtime error such as `PatternMatchError`.