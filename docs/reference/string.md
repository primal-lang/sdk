# String

## Construction

### Constructor
- **Syntax:** `"text": String`
- **Input:** Text surrounded by single or double quotes
- **Output:** A string

### Indexing
- **Syntax:** `String[Number]: String`
- **Input:** A string and an index
- **Output:** The character at the specified index position

## Access

### At
- **Signature:** `str.at(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** The character at the specified index

### First
- **Signature:** `str.first(a: String): String`
- **Input:** One string
- **Output:** The first character of the string

### Last
- **Signature:** `str.last(a: String): String`
- **Input:** One string
- **Output:** The last character of the string

### Substring
- **Signature:** `str.substring(a: String, b: Number, c: Number): String`
- **Input:** A string, a start index, and an end index
- **Output:** The extracted portion of the string

### Init
- **Signature:** `str.init(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the last character

### Rest
- **Signature:** `str.rest(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the first character

### Take
- **Signature:** `str.take(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** The first n characters from the string

### Drop
- **Signature:** `str.drop(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** A new string omitting the first n characters

## Manipulation

### Concat
- **Signature:** `str.concat(a: String, b: String): String`
- **Input:** Two strings
- **Output:** The two strings combined together

### Replace
- **Signature:** `str.replace(a: String, b: String, c: String): String`
- **Input:** A string, a target substring, and a replacement substring
- **Output:** A new string with all instances of the target replaced

### Uppercase
- **Signature:** `str.uppercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to uppercase letters

### Lowercase
- **Signature:** `str.lowercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to lowercase letters

### Trim
- **Signature:** `str.trim(a: String): String`
- **Input:** One string
- **Output:** A new string with leading and trailing whitespace removed

### Remove At
- **Signature:** `str.removeAt(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** A new string with the character at the specified index removed

### Reverse
- **Signature:** `str.reverse(a: String): String`
- **Input:** One string
- **Output:** A new string with characters in reverse order

### Pad Left
- **Signature:** `str.padLeft(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the left to reach minimum length

### Pad Right
- **Signature:** `str.padRight(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the right to reach minimum length

### Split
- **Signature:** `str.split(a: String, b: String): List`
- **Input:** A string and a separator string
- **Output:** A list of substrings divided by the separator

## Search

### Contains
- **Signature:** `str.contains(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string includes the second, false otherwise

### Starts With
- **Signature:** `str.startsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string begins with the second, false otherwise

### Ends With
- **Signature:** `str.endsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string ends with the second, false otherwise

### Match
- **Signature:** `str.match(a: String, b: String): Boolean`
- **Input:** A string and a regex pattern
- **Output:** True if the string matches the pattern, false otherwise

### Index Of
- **Signature:** `str.indexOf(a: String, b: Any): Number`
- **Input:** A string and a value
- **Output:** The position of the first occurrence, or -1 if not found

## Properties

### Length
- **Signature:** `str.length(a: String): Number`
- **Input:** One string
- **Output:** The number of characters in the string

### Is Empty
- **Signature:** `str.isEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains no characters, false otherwise

### Is Not Empty
- **Signature:** `str.isNotEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains at least one character, false otherwise

### Bytes
- **Signature:** `str.bytes(a: String): List`
- **Input:** One string
- **Output:** A list containing the byte values of the string

## Comparison

### Compare
- **Signature:** `str.compare(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** 1 if the first string is greater, -1 if smaller, 0 if equal
