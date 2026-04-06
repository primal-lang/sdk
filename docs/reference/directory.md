# Directory

Note: Directory functions are not available on the web platform.

## Creation

### From Path

- **Signature:** `directory.fromPath(a: String): Directory`
- **Input:** One string path
- **Output:** A directory object pointing to the given path
- **Purity:** Pure
- **Example:**

```
directory.fromPath("/home/user") // returns a directory object
```

### Create

- **Signature:** `directory.create(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.create(directory.fromPath("/home/user/new")) // returns true
```

## Operations

### Exists

- **Signature:** `directory.exists(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if the directory exists, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.exists(directory.fromPath("/home/user")) // returns true
```

### Delete

- **Signature:** `directory.delete(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.delete(directory.fromPath("/home/user/old")) // returns true
```

### Copy

- **Signature:** `directory.copy(a: Directory, b: Directory): Boolean`
- **Input:** Two directories
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.copy(directory.fromPath("src"), directory.fromPath("backup")) // returns true
```

### Move

- **Signature:** `directory.move(a: Directory, b: Directory): Boolean`
- **Input:** Two directories
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.move(directory.fromPath("old"), directory.fromPath("new")) // returns true
```

### Rename

- **Signature:** `directory.rename(a: Directory, b: String): Boolean`
- **Input:** A directory and a string
- **Output:** True if successful, false otherwise
- **Purity:** Impure
- **Example:**

```
directory.rename(directory.fromPath("old"), "new") // returns true
```

### List

- **Signature:** `directory.list(a: Directory): List`
- **Input:** One directory
- **Output:** A list of all files and directories within the directory
- **Purity:** Impure
- **Example:**

```
directory.list(directory.fromPath("/home/user")) // returns [file1, file2, dir1, ...]
```

## Properties

### Path

- **Signature:** `directory.path(a: Directory): String`
- **Input:** One directory
- **Output:** The directory's path as a string
- **Purity:** Pure
- **Example:**

```
directory.path(directory.fromPath("/home/user")) // returns "/home/user"
```

### Name

- **Signature:** `directory.name(a: Directory): String`
- **Input:** One directory
- **Output:** The directory's name as a string
- **Purity:** Pure
- **Example:**

```
directory.name(directory.fromPath("/home/user")) // returns "user"
```

### Parent

- **Signature:** `directory.parent(a: Directory): Directory`
- **Input:** One directory
- **Output:** The parent directory
- **Purity:** Pure
- **Example:**

```
directory.parent(directory.fromPath("/home/user")) // returns the "/home" directory
```
