# File

Note: File functions are not available on the web platform.

## Creation

### From Path
- **Signature:** `file.fromPath(a: String): File`
- **Input:** One string path
- **Output:** A file object pointing to the given path

### Create
- **Signature:** `file.create(a: File): Boolean`
- **Input:** One file
- **Output:** True if successful, false otherwise

## Read and Write

### Read
- **Signature:** `file.read(a: File): String`
- **Input:** One file
- **Output:** The contents of the file as a string

### Write
- **Signature:** `file.write(a: File, b: String): Boolean`
- **Input:** A file and a string
- **Output:** True if successful, false otherwise

## Operations

### Exists
- **Signature:** `file.exists(a: File): Boolean`
- **Input:** One file
- **Output:** True if the file exists, false otherwise

### Delete
- **Signature:** `file.delete(a: File): Boolean`
- **Input:** One file
- **Output:** True if successful, false otherwise

### Copy
- **Signature:** `file.copy(a: File, b: File): Boolean`
- **Input:** Two files
- **Output:** True if successful, false otherwise

### Move
- **Signature:** `file.move(a: File, b: File): Boolean`
- **Input:** Two files
- **Output:** True if successful, false otherwise

### Rename
- **Signature:** `file.rename(a: File, b: String): Boolean`
- **Input:** A file and a string
- **Output:** True if successful, false otherwise

## Properties

### Length
- **Signature:** `file.length(a: File): Number`
- **Input:** One file
- **Output:** The file's length in bytes

### Path
- **Signature:** `file.path(a: File): String`
- **Input:** One file
- **Output:** The file's path as a string

### Name
- **Signature:** `file.name(a: File): String`
- **Input:** One file
- **Output:** The file's name as a string

### Extension
- **Signature:** `file.extension(a: File): String`
- **Input:** One file
- **Output:** The file's extension as a string

### Parent
- **Signature:** `file.parent(a: File): Directory`
- **Input:** One file
- **Output:** The file's parent directory
