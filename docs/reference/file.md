# File

Note: File functions are not available on the web platform.

## file.fromPath

`file.fromPath(a: String): File`

Returns a file object pointing to the given path.

## file.exists

`file.exists(a: File): Boolean`

Returns true if the file exists, false otherwise.

## file.read

`file.read(a: File): String`

Returns the contents of the file as a string.

## file.write

`file.write(a: File, b: String): Boolean`

Writes the string content to the file. Returns true if successful, false otherwise.

## file.create

`file.create(a: File): Boolean`

Creates the file. Returns true if successful, false otherwise.

## file.delete

`file.delete(a: File): Boolean`

Deletes the file. Returns true if successful, false otherwise.

## file.copy

`file.copy(a: File, b: File): Boolean`

Copies the first file to the second file's location. Returns true if successful, false otherwise.

## file.move

`file.move(a: File, b: File): Boolean`

Moves the first file to the second file's location. Returns true if successful, false otherwise.

## file.rename

`file.rename(a: File, b: String): Boolean`

Renames the file. Returns true if successful, false otherwise.

## file.length

`file.length(a: File): Number`

Returns the file's length in bytes.

## file.path

`file.path(a: File): String`

Returns the file's path as a string.

## file.name

`file.name(a: File): String`

Returns the file's name as a string.

## file.extension

`file.extension(a: File): String`

Returns the file's extension as a string.

## file.parent

`file.parent(a: File): Directory`

Returns the file's parent directory.
