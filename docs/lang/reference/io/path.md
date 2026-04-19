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

### Join

- **Signature:** `path.join(a: String, b: String): String`
- **Input:** Two path segments
- **Output:** A combined path with the appropriate separator
- **Purity:** Pure
- **Example:**

```
path.join("/home/user", "file.txt") // returns "/home/user/file.txt"
path.join("folder", "subfolder") // returns "folder/subfolder"
```

### Dirname

- **Signature:** `path.dirname(a: String): String`
- **Input:** A path string
- **Output:** The directory portion of the path (everything before the last separator)
- **Purity:** Pure
- **Example:**

```
path.dirname("/home/user/file.txt") // returns "/home/user"
path.dirname("folder/subfolder/file.txt") // returns "folder/subfolder"
path.dirname("file.txt") // returns "."
```

### Basename

- **Signature:** `path.basename(a: String): String`
- **Input:** A path string
- **Output:** The filename portion of the path (the last component after the separator)
- **Purity:** Pure
- **Example:**

```
path.basename("/home/user/file.txt") // returns "file.txt"
path.basename("folder/subfolder") // returns "subfolder"
path.basename("file.txt") // returns "file.txt"
```

### Extension

- **Signature:** `path.extension(a: String): String`
- **Input:** A path string
- **Output:** The file extension without the leading dot, or an empty string if none
- **Purity:** Pure
- **Example:**

```
path.extension("/home/user/file.txt") // returns "txt"
path.extension("archive.tar.gz") // returns "gz"
path.extension("Makefile") // returns ""
path.extension(".gitignore") // returns ""
```

### Is Absolute

- **Signature:** `path.isAbsolute(a: String): Boolean`
- **Input:** A path string
- **Output:** True if the path is absolute, false otherwise
- **Purity:** Pure
- **Example:**

```
path.isAbsolute("/home/user") // returns true
path.isAbsolute("folder/file.txt") // returns false
path.isAbsolute("./relative") // returns false
```

### Normalize

- **Signature:** `path.normalize(a: String): String`
- **Input:** A path string
- **Output:** A normalized path with redundant separators and relative segments resolved
- **Purity:** Pure
- **Example:**

```
path.normalize("/home/user/../other") // returns "/home/other"
path.normalize("./folder//subfolder") // returns "folder/subfolder"
path.normalize("/home/./user") // returns "/home/user"
```
