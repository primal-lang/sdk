Primal already exposes `str.match`, but string-based regex patterns are harder to read and easier to mistype.

**Design notes:**

- Literal regexes should be validated during lexing/parsing, not only at runtime.
- A dedicated regex runtime value would be cleaner than treating regexes as plain strings.
- This proposal implies a new `regex.*` namespace in the standard library.
- Raw strings and regex literals complement each other well.

Add first-class regex syntax:

```
pattern = /[a-z]+[0-9]+/
matched = regex.match("hello123", pattern)
groups = regex.findAll("abc123def456", /\d+/)
replaced = regex.replace("hello123", /\d+/, "XXX")
```
