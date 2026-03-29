# String

## Constructor

`"text": String`

Creates a string from text surrounded by single or double quotes.

## Indexing

`String[Number]: String`

Returns the character at the specified index position.

## str.substring

`str.substring(a: String, b: Number, c: Number): String`

Extracts a portion of the string from start index to end index.

## str.startsWith

`str.startsWith(a: String, b: String): Boolean`

Returns true if the first string begins with the second string.

## str.endsWith

`str.endsWith(a: String, b: String): Boolean`

Returns true if the first string ends with the second string.

## str.replace

`str.replace(a: String, b: String, c: String): String`

Returns a new string with all instances of one substring replaced by another.

## str.uppercase

`str.uppercase(a: String): String`

Returns a new string converted to uppercase letters.

## str.lowercase

`str.lowercase(a: String): String`

Returns a new string converted to lowercase letters.

## str.trim

`str.trim(a: String): String`

Returns a new string with leading and trailing whitespace removed.

## str.match

`str.match(a: String, b: String): Boolean`

Returns true if the string matches a regex pattern.

## str.length

`str.length(a: String): Number`

Returns the number of characters in the string.

## str.concat

`str.concat(a: String, b: String): String`

Combines two strings together.

## str.first

`str.first(a: String): String`

Returns the first character of the string.

## str.last

`str.last(a: String): String`

Returns the last character of the string.

## str.init

`str.init(a: String): String`

Returns a new string excluding the last character.

## str.rest

`str.rest(a: String): String`

Returns a new string excluding the first character.

## str.at

`str.at(a: String, b: Number): String`

Returns the character at the specified index.

## str.isEmpty

`str.isEmpty(a: String): Boolean`

Returns true if the string contains no characters.

## str.isNotEmpty

`str.isNotEmpty(a: String): Boolean`

Returns true if the string contains at least one character.

## str.contains

`str.contains(a: String, b: String): Boolean`

Returns true if the string includes the specified argument.

## str.take

`str.take(a: String, b: Number): String`

Returns the first n characters from the string.

## str.drop

`str.drop(a: String, b: Number): String`

Returns a new string omitting the first n characters.

## str.removeAt

`str.removeAt(a: String, b: Number): String`

Returns a new string with the character at the specified index removed.

## str.reverse

`str.reverse(a: String): String`

Returns a new string with characters in reverse order.

## str.bytes

`str.bytes(a: String): List`

Returns a list containing the byte values of the string.

## str.indexOf

`str.indexOf(a: String, b: Any): Number`

Returns the position of the first occurrence of a value, or -1 if not found.

## str.padLeft

`str.padLeft(a: String, b: Number, c: String): String`

Returns a new string padded on the left to reach minimum length.

## str.padRight

`str.padRight(a: String, b: Number, c: String): String`

Returns a new string padded on the right to reach minimum length.

## str.split

`str.split(a: String, b: String): List`

Returns a list of substrings divided by a separator string.

## str.compare

`str.compare(a: String, b: String): Number`

Returns 1 if first string is greater, -1 if smaller, 0 if equal.
