---
title: File
tags: [reference, io]
sources: [lib/compiler/library/file/]
---

# File

**TLDR**: Functions for creating, reading, writing, and manipulating files on the filesystem including copy, move, delete, and property access.

Number of functions: 16

Note: File functions are not available on the web platform.

## Creation

### From Path

- **Signature:** `file.fromPath(a: String): File`
- **Input:** One string path
- **Output:** A file object pointing to the given path
- **Purity:** Pure
- **Example:**

```
file.fromPath("/home/user/data.txt") // returns a file object
```

### Create

- **Signature:** `file.create(a: File): Boolean`
- **Input:** One file
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.create(file.fromPath("new.txt")) // returns true
```

## Read and Write

### Read

- **Signature:** `file.read(a: File): String`
- **Input:** One file
- **Output:** The contents of the file as a string
- **Purity:** Impure
- **Example:**

```
file.read(file.fromPath("data.txt")) // returns the file contents
```

### Write

- **Signature:** `file.write(a: File, b: String): Boolean`
- **Input:** A file and a string
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.write(file.fromPath("data.txt"), "hello") // returns true
```

### Append

- **Signature:** `file.append(a: File, b: String): Boolean`
- **Input:** A file and a string
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Description:** Appends the string to the end of the file. Creates the file if it doesn't exist.
- **Example:**

```
file.append(file.fromPath("log.txt"), "new entry\n") // returns true
```

## Operations

### Exists

- **Signature:** `file.exists(a: File): Boolean`
- **Input:** One file
- **Output:** True if the file exists, false otherwise
- **Purity:** Impure
- **Example:**

```
file.exists(file.fromPath("data.txt")) // returns true
```

### Delete

- **Signature:** `file.delete(a: File): Boolean`
- **Input:** One file
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.delete(file.fromPath("old.txt")) // returns true
```

### Copy

- **Signature:** `file.copy(a: File, b: File): Boolean`
- **Input:** Two files
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.copy(file.fromPath("a.txt"), file.fromPath("b.txt")) // returns true
```

### Move

- **Signature:** `file.move(a: File, b: File): Boolean`
- **Input:** Two files
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.move(file.fromPath("old.txt"), file.fromPath("new.txt")) // returns true
```

### Rename

- **Signature:** `file.rename(a: File, b: String): Boolean`
- **Input:** A file and a string
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
file.rename(file.fromPath("old.txt"), "new.txt") // returns true
```

## Properties

### Length

- **Signature:** `file.length(a: File): Number`
- **Input:** One file
- **Output:** The file's length in bytes
- **Purity:** Impure
- **Example:**

```
file.length(file.fromPath("data.txt")) // returns 1024
```

### Path

- **Signature:** `file.path(a: File): String`
- **Input:** One file
- **Output:** The file's path as a string
- **Purity:** Pure
- **Example:**

```
file.path(file.fromPath("/home/user/data.txt")) // returns "/home/user/data.txt"
```

### Name

- **Signature:** `file.name(a: File): String`
- **Input:** One file
- **Output:** The file's name as a string
- **Purity:** Pure
- **Example:**

```
file.name(file.fromPath("/home/user/data.txt")) // returns "data.txt"
```

### Extension

- **Signature:** `file.extension(a: File): String`
- **Input:** One file
- **Output:** The file's extension as a string
- **Purity:** Pure
- **Example:**

```
file.extension(file.fromPath("data.txt")) // returns "txt"
```

### Parent

- **Signature:** `file.parent(a: File): Directory`
- **Input:** One file
- **Output:** The file's parent directory
- **Purity:** Pure
- **Example:**

```
file.parent(file.fromPath("/home/user/data.txt")) // returns the "/home/user" directory
```

### Last Modified

- **Signature:** `file.lastModified(a: File): Timestamp`
- **Input:** One file
- **Output:** The last modified time of the file as a timestamp
- **Purity:** Impure
- **Example:**

```
file.lastModified(file.fromPath("data.txt")) // returns the last modified timestamp
```
