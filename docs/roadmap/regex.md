We currently have `str.match` which accepts string-based regex patterns, but this can be error-prone and less readable. Introducing first-class regex syntax with literal regexes would improve readability and allow for better validation during lexing/parsing. A dedicated regex runtime value would also provide a cleaner API for regex operations. This proposal would also introduce a new `regex.*` namespace in the standard library to house regex-related functions. Raw strings and regex literals would complement each other well, providing flexibility for different use cases.

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
