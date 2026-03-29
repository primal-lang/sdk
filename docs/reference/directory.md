# Directory

Note: Directory functions are not available on the web platform.

## directory.fromPath

`directory.fromPath(a: String): Directory`

Returns a directory object pointing to the given path.

## directory.exists

`directory.exists(a: Directory): Boolean`

Returns true if the directory exists, false otherwise.

## directory.create

`directory.create(a: Directory): Boolean`

Creates the directory. Returns true if successful, false otherwise.

## directory.delete

`directory.delete(a: Directory): Boolean`

Deletes the directory. Returns true if successful, false otherwise.

## directory.copy

`directory.copy(a: Directory, b: Directory): Boolean`

Copies the directory to a new location. Returns true if successful, false otherwise.

## directory.move

`directory.move(a: Directory, b: Directory): Boolean`

Moves the directory to a new location. Returns true if successful, false otherwise.

## directory.rename

`directory.rename(a: Directory, b: String): Boolean`

Renames the directory. Returns true if successful, false otherwise.

## directory.path

`directory.path(a: Directory): String`

Returns the directory's path as a string.

## directory.name

`directory.name(a: Directory): String`

Returns the directory's name as a string.

## directory.parent

`directory.parent(a: Directory): Directory`

Returns the parent directory.

## directory.list

`directory.list(a: Directory): List`

Returns a list of all files and directories within the directory.
