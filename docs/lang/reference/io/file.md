---
title: File
tags:
  - reference
  - io
sources:
  - lib/compiler/library/file/
---

# File

**TLDR**: Functions for creating, reading, writing, and manipulating files on the filesystem including copy, move, delete, and property access.

Number of functions: 16

> **Note:** File functions are not implemented on the web platform.

## Creation

### From Path

- **Signature:** `file_fromPath(a: String): File`
- **Input:** A string.
- **Output:** A file pointing to the given path.
- **Purity:** Pure
- **Example:**

```
file_fromPath("/home/user/data.txt") // returns a file object
```

### Create

- **Signature:** `file_create(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file was created, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_create(file_fromPath("new.txt")) // returns true if successful
```

## Read and Write

### Read

- **Signature:** `file_read(a: File): String`
- **Input:** A file.
- **Output:** The content of the file as a string.
- **Purity:** Impure
- **Example:**

```
file_read(file_fromPath("data.txt")) // returns the file contents
```

### Write

- **Signature:** `file_write(a: File, b: String): Boolean`
- **Input:** A file and a content.
- **Output:** True if the file was written with the content, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_write(file_fromPath("data.txt"), "hello") // returns true if successful
```

### Append

- **Signature:** `file_append(a: File, b: String): Boolean`
- **Input:** A file and content to append.
- **Output:** True if the content was appended, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_append(file_fromPath("log.txt"), "new line") // returns true if successful
```

## Operations

### Exists

- **Signature:** `file_exists(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file exists, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_exists(file_fromPath("data.txt")) // returns true if it exists
```

### Delete

- **Signature:** `file_delete(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file was deleted, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_delete(file_fromPath("old.txt")) // returns true if successful
```

### Copy

- **Signature:** `file_copy(a: File, b: File): Boolean`
- **Input:** Two files.
- **Output:** True if the file was copied, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_copy(file_fromPath("a.txt"), file_fromPath("b.txt")) // returns true if successful
```

### Move

- **Signature:** `file_move(a: File, b: File): Boolean`
- **Input:** Two files.
- **Output:** True if the file was moved, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_move(file_fromPath("old.txt"), file_fromPath("new.txt")) // returns true if successful
```

### Rename

- **Signature:** `file_rename(a: File, b: String): Boolean`
- **Input:** A file and the new name.
- **Output:** True if the file was renamed, false otherwise.
- **Purity:** Impure
- **Example:**

```
file_rename(file_fromPath("old.txt"), "new.txt") // returns true if successful
```

## Properties

### Length

- **Signature:** `file_length(a: File): Number`
- **Input:** A file.
- **Output:** The length of the file in bytes.
- **Purity:** Impure
- **Example:**

```
file_length(file_fromPath("data.txt")) // returns the file size in bytes
```

### Path

- **Signature:** `file_path(a: File): String`
- **Input:** A file.
- **Output:** The path of the file as a string.
- **Purity:** Pure
- **Example:**

```
file_path(file_fromPath("/home/user/data.txt")) // returns "/home/user/data.txt"
```

### Name

- **Signature:** `file_name(a: File): String`
- **Input:** A file.
- **Output:** The name of the file as a string.
- **Purity:** Pure
- **Example:**

```
file_name(file_fromPath("/home/user/data.txt")) // returns "data.txt"
```

### Extension

- **Signature:** `file_extension(a: File): String`
- **Input:** A file.
- **Output:** The extension of the file as a string.
- **Purity:** Pure
- **Example:**

```
file_extension(file_fromPath("data.txt")) // returns "txt"
```

### Parent

- **Signature:** `file_parent(a: File): Directory`
- **Input:** A file.
- **Output:** The parent directory of the file.
- **Purity:** Pure
- **Example:**

```
file_parent(file_fromPath("/home/user/data.txt")) // returns the "/home/user" directory
```

### Last Modified

- **Signature:** `file_lastModified(a: File): Timestamp`
- **Input:** A file.
- **Output:** The timestamp of when the file was last modified.
- **Purity:** Impure
- **Example:**

```
file_lastModified(file_fromPath("data.txt")) // returns the modification timestamp
```
