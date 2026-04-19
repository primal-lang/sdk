---
title: Path
tags:
  - reference
  - io
sources:
  - lib/compiler/library/path/
---

# Path

**TLDR**: Functions for manipulating file path strings including joining, extracting components, normalizing, and checking if paths are absolute.

Number of functions: 6

## Operations

### Basename

- **Signature:** `path.basename(a: String): String`
- **Input:** A file path string.
- **Output:** The filename portion of the path.
- **Purity:** Pure
- **Example:**

```
path.basename("/home/user/file.txt") // returns "file.txt"
```

### Dirname

- **Signature:** `path.dirname(a: String): String`
- **Input:** A file path string.
- **Output:** The directory portion of the path.
- **Purity:** Pure
- **Example:**

```
path.dirname("/home/user/file.txt") // returns "/home/user"
```

### Extension

- **Signature:** `path.extension(a: String): String`
- **Input:** A file path string.
- **Output:** The file extension (including the dot).
- **Purity:** Pure
- **Example:**

```
path.extension("/home/user/file.txt") // returns ".txt"
```

### Is Absolute

- **Signature:** `path.isAbsolute(a: String): Boolean`
- **Input:** A file path string.
- **Output:** True if the path is absolute, false otherwise.
- **Purity:** Pure
- **Example:**

```
path.isAbsolute("/home/user") // returns true
```

### Join

- **Signature:** `path.join(a: List): String`
- **Input:** A list of path segments.
- **Output:** The path segments joined together with the appropriate separator.
- **Purity:** Pure
- **Example:**

```
path.join(["home", "user", "file.txt"]) // returns "home/user/file.txt"
```

### Normalize

- **Signature:** `path.normalize(a: String): String`
- **Input:** A file path string.
- **Output:** The normalized path with redundant separators and segments removed.
- **Purity:** Pure
- **Example:**

```
path.normalize("/home//user/../user/file.txt") // returns "/home/user/file.txt"
```
