# Directory

Note: Directory functions are not available on the web platform.

## Creation

### From Path
- **Signature:** `directory.fromPath(a: String): Directory`
- **Input:** One string path
- **Output:** A directory object pointing to the given path

### Create
- **Signature:** `directory.create(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if successful, false otherwise

## Operations

### Exists
- **Signature:** `directory.exists(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if the directory exists, false otherwise

### Delete
- **Signature:** `directory.delete(a: Directory): Boolean`
- **Input:** One directory
- **Output:** True if successful, false otherwise

### Copy
- **Signature:** `directory.copy(a: Directory, b: Directory): Boolean`
- **Input:** Two directories
- **Output:** True if successful, false otherwise

### Move
- **Signature:** `directory.move(a: Directory, b: Directory): Boolean`
- **Input:** Two directories
- **Output:** True if successful, false otherwise

### Rename
- **Signature:** `directory.rename(a: Directory, b: String): Boolean`
- **Input:** A directory and a string
- **Output:** True if successful, false otherwise

### List
- **Signature:** `directory.list(a: Directory): List`
- **Input:** One directory
- **Output:** A list of all files and directories within the directory

## Properties

### Path
- **Signature:** `directory.path(a: Directory): String`
- **Input:** One directory
- **Output:** The directory's path as a string

### Name
- **Signature:** `directory.name(a: Directory): String`
- **Input:** One directory
- **Output:** The directory's name as a string

### Parent
- **Signature:** `directory.parent(a: Directory): Directory`
- **Input:** One directory
- **Output:** The parent directory
