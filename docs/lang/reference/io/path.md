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

- **Signature:** `path_basename(a: String): String`
- **Input:** A file path string.
- **Output:** The filename portion of the path.
- **Purity:** Pure
- **Example:**

```
path_basename("/home/user/file.txt") // returns "file.txt"
```

### Dirname

- **Signature:** `path_dirname(a: String): String`
- **Input:** A file path string.
- **Output:** The directory portion of the path.
- **Purity:** Pure
- **Example:**

```
path_dirname("/home/user/file.txt") // returns "/home/user"
```

### Extension

- **Signature:** `path_extension(a: String): String`
- **Input:** A file path string.
- **Output:** The file extension (including the dot).
- **Purity:** Pure
- **Example:**

```
path_extension("/home/user/file.txt") // returns ".txt"
```

### Is Absolute

- **Signature:** `path_isAbsolute(a: String): Boolean`
- **Input:** A file path string.
- **Output:** True if the path is absolute, false otherwise.
- **Purity:** Pure
- **Example:**

```
path_isAbsolute("/home/user") // returns true
```

### Join

- **Signature:** `path_join(a: String, b: String): String`
- **Input:** Two path segments.
- **Output:** The path segments joined together with the appropriate separator.
- **Purity:** Pure
- **Example:**

```
path_join("home/user", "file.txt") // returns "home/user/file.txt"
```

### Normalize

- **Signature:** `path_normalize(a: String): String`
- **Input:** A file path string.
- **Output:** The normalized path with redundant separators and segments removed.
- **Purity:** Pure
- **Example:**

```
path_normalize("/home//user/../user/file.txt") // returns "/home/user/file.txt"
```
