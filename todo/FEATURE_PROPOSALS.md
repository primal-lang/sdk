## 8. Regular Expression Literals

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add first-class regex syntax:

```
pattern = /[a-z]+[0-9]+/
matched = regex.match("hello123", pattern)
groups = regex.findAll("abc123def456", /\d+/)
replaced = regex.replace("hello123", /\d+/, "XXX")
```

**Why it belongs:** Primal already exposes `str.match`, but string-based regex patterns are harder to read and easier to mistype.

**Design notes:**

- Literal regexes should be validated during lexing/parsing, not only at runtime.
- A dedicated regex runtime value would be cleaner than treating regexes as plain strings.
- This proposal implies a new `regex.*` namespace in the standard library.
- Raw strings and regex literals complement each other well.

---

## 13. Sequence / Do Expressions

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Allow evaluating expressions in order and returning the last one:

```
main = do
  console.writeLn("Enter name:")
  name = console.read()
  console.writeLn("Hello, " + name)
  name
end
```

**Why it belongs:** Primal is expression-oriented, but practical scripting still needs a readable way to sequence I/O and local bindings.

**Design notes:**

- `do ... end` is most useful if it also supports local bindings.
- The block should evaluate top-to-bottom and yield the last expression.
- This overlaps with `where` and any future `let`-like feature; those designs should be coordinated rather than implemented independently.
- This is a larger change than it looks because it introduces nested scope and ordered evaluation as explicit syntax.

---

## 15. Record Types

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Add named-field structures:

```
record Person(name, age)

alice = Person("Alice", 30)
name = alice.name
older = alice with { age: 31 }
```

**Why it belongs:** Maps are flexible but weakly communicative. Records would give Primal a lightweight way to model structured data with named fields.

**Design notes:**

- A dynamic first version does not need field type annotations.
- Field access and functional update are the key capabilities.
- A simple implementation could lower records to tagged maps at first.
- This interacts with the lexer/parser because dot access is not currently a general expression form.

---

## 19. Multiline / Raw Strings

**Current Fit:** High | **Complexity:** Low | **Impact:** High

Add triple-quoted multiline strings and raw strings:

```
query = """
  SELECT * FROM users
  WHERE age > 18
"""

path = r"C:\Users\name"
pattern = r"\d+\.\d+"
```

**Why it belongs:** Primal already has solid string escape handling. Extending the lexer to support raw and multiline forms would provide immediate value for scripts, regexes, JSON snippets, and embedded text.

**Design notes:**

- Indentation trimming rules should be explicit.
- Raw strings should disable escape processing entirely.
- Triple-quoted strings should preserve line breaks naturally.
- This is a very good near-term feature because the value is high and the scope is contained.

---

## 22. Maybe / Option Type

**Current Fit:** Medium | **Complexity:** Medium-High | **Impact:** High

Add explicit values for present or absent results:

```
safeHead(xs) =
  if (list.isEmpty(xs)) none else some(list.first(xs))

value = maybe.unwrapOr(safeHead([]), 0)
```

**Why it belongs:** The language currently uses exceptions for many missing-value cases, such as indexing failures. `Option` would provide a safer, more explicit path for ordinary absence.

**Design notes:**

- A minimal representation could be atoms/tags plus payload, but a dedicated runtime type is cleaner.
- The standard library would need helpers such as `maybe.map`, `maybe.flatMap`, `maybe.unwrapOr`, and `maybe.isSome`.
- This becomes especially valuable if safe indexing/lookups are added.
- It also reduces overuse of `try(a, b)` for non-exceptional control flow.
