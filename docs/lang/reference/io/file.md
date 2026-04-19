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

Number of functions: 15

> **Note:** File functions are not implemented on the web platform.

## Creation

### From Path

- **Signature:** `file.fromPath(a: String): File`
- **Input:** A string.
- **Output:** A file pointing to the given path.
- **Purity:** Pure
- **Example:**

```
file.fromPath("/home/user/data.txt") // returns a file object
```

### Create

- **Signature:** `file.create(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file was created, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.create(file.fromPath("new.txt")) // returns true if successful
```

## Read and Write

### Read

- **Signature:** `file.read(a: File): String`
- **Input:** A file.
- **Output:** The content of the file as a string.
- **Purity:** Impure
- **Example:**

```
file.read(file.fromPath("data.txt")) // returns the file contents
```

### Write

- **Signature:** `file.write(a: File, b: String): Boolean`
- **Input:** A file and a content.
- **Output:** True if the file was written with the content, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.write(file.fromPath("data.txt"), "hello") // returns true if successful
```

### Append

- **Signature:** `file.append(a: File, b: String): Boolean`
- **Input:** A file and content to append.
- **Output:** True if the content was appended, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.append(file.fromPath("log.txt"), "new line") // returns true if successful
```

## Operations

### Exists

- **Signature:** `file.exists(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file exists, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.exists(file.fromPath("data.txt")) // returns true if it exists
```

### Delete

- **Signature:** `file.delete(a: File): Boolean`
- **Input:** A file.
- **Output:** True if the file was deleted, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.delete(file.fromPath("old.txt")) // returns true if successful
```

### Copy

- **Signature:** `file.copy(a: File, b: File): Boolean`
- **Input:** Two files.
- **Output:** True if the file was copied, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.copy(file.fromPath("a.txt"), file.fromPath("b.txt")) // returns true if successful
```

### Move

- **Signature:** `file.move(a: File, b: File): Boolean`
- **Input:** Two files.
- **Output:** True if the file was moved, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.move(file.fromPath("old.txt"), file.fromPath("new.txt")) // returns true if successful
```

### Rename

- **Signature:** `file.rename(a: File, b: String): Boolean`
- **Input:** A file and the new name.
- **Output:** True if the file was renamed, false otherwise.
- **Purity:** Impure
- **Example:**

```
file.rename(file.fromPath("old.txt"), "new.txt") // returns true if successful
```

## Properties

### Length

- **Signature:** `file.length(a: File): Number`
- **Input:** A file.
- **Output:** The length of the file in bytes.
- **Purity:** Impure
- **Example:**

```
file.length(file.fromPath("data.txt")) // returns the file size in bytes
```

### Path

- **Signature:** `file.path(a: File): String`
- **Input:** A file.
- **Output:** The path of the file as a string.
- **Purity:** Pure
- **Example:**

```
file.path(file.fromPath("/home/user/data.txt")) // returns "/home/user/data.txt"
```

### Name

- **Signature:** `file.name(a: File): String`
- **Input:** A file.
- **Output:** The name of the file as a string.
- **Purity:** Pure
- **Example:**

```
file.name(file.fromPath("/home/user/data.txt")) // returns "data.txt"
```

### Extension

- **Signature:** `file.extension(a: File): String`
- **Input:** A file.
- **Output:** The extension of the file as a string.
- **Purity:** Pure
- **Example:**

```
file.extension(file.fromPath("data.txt")) // returns "txt"
```

### Parent

- **Signature:** `file.parent(a: File): Directory`
- **Input:** A file.
- **Output:** The parent directory of the file.
- **Purity:** Pure
- **Example:**

```
file.parent(file.fromPath("/home/user/data.txt")) // returns the "/home/user" directory
```

### Last Modified

- **Signature:** `file.lastModified(a: File): Timestamp`
- **Input:** A file.
- **Output:** The timestamp of when the file was last modified.
- **Purity:** Impure
- **Example:**

```
file.lastModified(file.fromPath("data.txt")) // returns the modification timestamp
```
