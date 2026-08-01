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

- **Signature:** `directory_fromPath(a: String): Directory`
- **Input:** A string.
- **Output:** A directory pointing to the given path.
- **Purity:** Pure
- **Example:**

```
directory_fromPath("/home/user") // returns a directory object
```

### Create

- **Signature:** `directory_create(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory was created, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_create(directory_fromPath("/home/user/new")) // returns true if successful
```

## Operations

### Exists

- **Signature:** `directory_exists(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory exists, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_exists(directory_fromPath("/home/user")) // returns true if it exists
```

### Delete

- **Signature:** `directory_delete(a: Directory): Boolean`
- **Input:** A directory.
- **Output:** True if the directory was deleted, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_delete(directory_fromPath("/home/user/old")) // returns true if successful
```

### Copy

- **Signature:** `directory_copy(a: Directory, b: Directory): Boolean`
- **Input:** Two directories.
- **Output:** True if the directory was copied, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_copy(
    directory_fromPath("src"),
    directory_fromPath("backup")
) // returns true if successful
```

### Move

- **Signature:** `directory_move(a: Directory, b: Directory): Boolean`
- **Input:** Two directories.
- **Output:** True if the directory was moved, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_move(
    directory_fromPath("old"),
    directory_fromPath("new")
) // returns true if successful
```

### Rename

- **Signature:** `directory_rename(a: Directory, b: String): Boolean`
- **Input:** A directory and a string.
- **Output:** True if the directory was renamed, false otherwise.
- **Purity:** Impure
- **Example:**

```
directory_rename(directory_fromPath("old"), "new") // returns true if successful
```

### List

- **Signature:** `directory_list(a: Directory): List`
- **Input:** A directory.
- **Output:** A list of directories and files in the directory.
- **Purity:** Impure
- **Example:**

```
directory_list(directory_fromPath("/home/user")) // returns [file1, file2, ...]
```

## Properties

### Path

- **Signature:** `directory_path(a: Directory): String`
- **Input:** A directory.
- **Output:** The path of the directory.
- **Purity:** Pure
- **Example:**

```
directory_path(directory_fromPath("/home/user")) // returns "/home/user"
```

### Name

- **Signature:** `directory_name(a: Directory): String`
- **Input:** A directory.
- **Output:** The name of the directory.
- **Purity:** Pure
- **Example:**

```
directory_name(directory_fromPath("/home/user")) // returns "user"
```

### Parent

- **Signature:** `directory_parent(a: Directory): Directory`
- **Input:** A directory.
- **Output:** The parent directory.
- **Purity:** Pure
- **Example:**

```
directory_parent(directory_fromPath("/home/user")) // returns "/home" directory
```
