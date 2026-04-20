---
title: Directory
tags:
  - reference
  - io
sources:
  - lib/compiler/library/directory/
---

# Directory

**TLDR**: Functions for creating, listing, and manipulating directories on the filesystem including copy, move, delete, and property access.

Number of functions: 11

> **Note:** Directory functions are not implemented on the web platform.

## Creation

### From Path

- **Signature:** `directory.fromPath(a: String): Directory`
- **Input:** A string.
- **Output:** A directory pointing to the given path.
- **Purity:** Pure
- **Example:**

```
directory.fromPath("/home/user") // returns a directory object
```

### Create

- **Signature:** `directory.create(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory was created, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.create(directory.fromPath("/home/user/new")) // returns true if successful
```

## Operations

### Exists

- **Signature:** `directory.exists(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory exists, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.exists(directory.fromPath("/home/user")) // returns true if it exists
```

### Delete

- **Signature:** `directory.delete(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory was deleted, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.delete(directory.fromPath("/home/user/old")) // returns true if successful
```

### Copy

- **Signature:** `directory.copy(a: Directory, b: Directory): Boolean`
- **Input:** Two directories.
- **Output:** True if the directory was copied, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.copy(
    directory.fromPath("src"),
    directory.fromPath("backup")
) // returns true if successful
```

### Move

- **Signature:** `directory.move(a: Directory, b: Directory): Boolean`
- **Input:** Two directories.
- **Output:** True if the directory was moved, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.move(
    directory.fromPath("old"),
    directory.fromPath("new")
) // returns true if successful
```

### Rename

- **Signature:** `directory.rename(a: Directory, b: String): Boolean`
- **Input:** A directory and a string.
- **Output:** True if the directory was renamed, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory.rename(directory.fromPath("old"), "new") // returns true if successful
```

### List

- **Signature:** `directory.list(a: Directory): List`
- **Input:** A directory.
- **Output:** A list of directories and files in the directory.
- **Purity:** Impure
- **Example:**

```
directory.list(directory.fromPath("/home/user")) // returns [file1, file2, ...]
```

## Properties

### Path

- **Signature:** `directory.path(a: Directory): String`
- **Input:** A directory.
- **Output:** The path of the directory.
- **Purity:** Pure
- **Example:**

```
directory.path(directory.fromPath("/home/user")) // returns "/home/user"
```

### Name

- **Signature:** `directory.name(a: Directory): String`
- **Input:** A directory.
- **Output:** The name of the directory.
- **Purity:** Pure
- **Example:**

```
directory.name(directory.fromPath("/home/user")) // returns "user"
```

### Parent

- **Signature:** `directory.parent(a: Directory): Directory`
- **Input:** A directory.
- **Output:** The parent directory.
- **Purity:** Pure
- **Example:**

```
directory.parent(directory.fromPath("/home/user")) // returns "/home" directory
```
