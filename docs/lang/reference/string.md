---
title: String
tags: [reference, strings]
sources: [lib/compiler/library/string/]
---

# String

**TLDR**: Functions for creating, accessing, manipulating, searching, and inspecting text strings including case conversion, padding, splitting, and pattern matching.

Number of functions: 44

## Construction

### Constructor

- **Syntax:** `"text": String`
- **Input:** Text surrounded by single or double quotes
- **Output:** A string
- **Purity:** Pure
- **Example:**

```
"hello world" // returns "hello world"
```

### Indexing

- **Syntax:** `String[Number]: String`
- **Input:** A string and an index
- **Output:** The character at the specified index position
- **Purity:** Pure
- **Example:**

```
"hello"[0] // returns "h"
```

## Access

### At

- **Signature:** `str.at(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** The character at the specified index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str.at("hello", 1) // returns "e"
```

### First

- **Signature:** `str.first(a: String): String`
- **Input:** One string
- **Output:** The first character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str.first("hello") // returns "h"
```

### Last

- **Signature:** `str.last(a: String): String`
- **Input:** One string
- **Output:** The last character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str.last("hello") // returns "o"
```

### Substring

- **Signature:** `str.substring(a: String, b: Number, c: Number): String`
- **Input:** A string, a start index, and an end index
- **Output:** The extracted portion of the string
- **Constraints:** Throws an error if the start index is negative, if the end index is less than the start index, or if the start or end index is out of bounds
- **Purity:** Pure
- **Example:**

```
str.substring("hello", 1, 4) // returns "ell"
```

### Init

- **Signature:** `str.init(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the last character
- **Purity:** Pure
- **Example:**

```
str.init("hello") // returns "hell"
```

### Rest

- **Signature:** `str.rest(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the first character
- **Purity:** Pure
- **Example:**

```
str.rest("hello") // returns "ello"
```

### Take

- **Signature:** `str.take(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** The first n characters from the string
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
str.take("hello", 3) // returns "hel"
```

### Drop

- **Signature:** `str.drop(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** A new string omitting the first n characters
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
str.drop("hello", 2) // returns "llo"
```

## Manipulation

### Concat

- **Signature:** `str.concat(a: String, b: String): String`
- **Input:** Two strings
- **Output:** The two strings combined together
- **Purity:** Pure
- **Example:**

```
str.concat("hello", " world") // returns "hello world"
```

### Replace

- **Signature:** `str.replace(a: String, b: String, c: String): String`
- **Input:** A string, a regex pattern, and a replacement string
- **Output:** A new string with all matches of the pattern replaced
- **Purity:** Pure
- **Example:**

```
str.replace("hello world", "world", "there") // returns "hello there"
```

### Uppercase

- **Signature:** `str.uppercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to uppercase letters
- **Purity:** Pure
- **Example:**

```
str.uppercase("hello") // returns "HELLO"
```

### Lowercase

- **Signature:** `str.lowercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to lowercase letters
- **Purity:** Pure
- **Example:**

```
str.lowercase("HELLO") // returns "hello"
```

### Trim

- **Signature:** `str.trim(a: String): String`
- **Input:** One string
- **Output:** A new string with leading and trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trim("  hello  ") // returns "hello"
```

### Trim Left

- **Signature:** `str.trimLeft(a: String): String`
- **Input:** One string
- **Output:** A new string with leading whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trimLeft("  hello  ") // returns "hello  "
```

### Trim Right

- **Signature:** `str.trimRight(a: String): String`
- **Input:** One string
- **Output:** A new string with trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trimRight("  hello  ") // returns "  hello"
```

### Capitalize

- **Signature:** `str.capitalize(a: String): String`
- **Input:** One string
- **Output:** A new string with the first character converted to uppercase
- **Purity:** Pure
- **Example:**

```
str.capitalize("hello") // returns "Hello"
```

### Repeat

- **Signature:** `str.repeat(a: String, b: Number): String`
- **Input:** A string and a repeat count
- **Output:** A new string with the input repeated n times
- **Constraints:** Throws an error if the count is negative
- **Purity:** Pure
- **Example:**

```
str.repeat("ab", 3) // returns "ababab"
```

### Remove At

- **Signature:** `str.removeAt(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** A new string with the character at the specified index removed
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str.removeAt("hello", 1) // returns "hllo"
```

### Reverse

- **Signature:** `str.reverse(a: String): String`
- **Input:** One string
- **Output:** A new string with characters in reverse order
- **Purity:** Pure
- **Example:**

```
str.reverse("hello") // returns "olleh"
```

### Pad Left

- **Signature:** `str.padLeft(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the left to reach minimum length
- **Purity:** Pure
- **Example:**

```
str.padLeft("42", 5, "0") // returns "00042"
```

### Pad Right

- **Signature:** `str.padRight(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the right to reach minimum length
- **Purity:** Pure
- **Example:**

```
str.padRight("hi", 5, ".") // returns "hi..."
```

### Split

- **Signature:** `str.split(a: String, b: String): List`
- **Input:** A string and a separator string
- **Output:** A list of substrings divided by the separator. If the separator is empty, splits into individual characters.
- **Purity:** Pure
- **Example:**

```
str.split("a,b,c", ",") // returns ["a", "b", "c"]
str.split("hello", "") // returns ["h", "e", "l", "l", "o"]
```

### Lines

- **Signature:** `str.lines(a: String): List`
- **Input:** One string
- **Output:** A list of substrings split by line breaks (\n, \r\n, or \r)
- **Purity:** Pure
- **Example:**

```
str.lines("a\nb\nc") // returns ["a", "b", "c"]
```

## Search

### Contains

- **Signature:** `str.contains(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string includes the second, false otherwise
- **Purity:** Pure
- **Example:**

```
str.contains("hello world", "world") // returns true
```

### Starts With

- **Signature:** `str.startsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string begins with the second, false otherwise
- **Purity:** Pure
- **Example:**

```
str.startsWith("hello", "hel") // returns true
```

### Ends With

- **Signature:** `str.endsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string ends with the second, false otherwise
- **Purity:** Pure
- **Example:**

```
str.endsWith("hello", "llo") // returns true
```

### Match

- **Signature:** `str.match(a: String, b: String): Boolean`
- **Input:** A string and a regex pattern
- **Output:** True if the string matches the pattern, false otherwise
- **Constraints:** Throws an error if the pattern is not a valid regex
- **Purity:** Pure
- **Example:**

```
str.match("hello123", "[a-z]+[0-9]+") // returns true
```

### Index Of

- **Signature:** `str.indexOf(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** The position of the first occurrence of the second string, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str.indexOf("hello", "l") // returns 2
```

### Last Index Of

- **Signature:** `str.lastIndexOf(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** The position of the last occurrence of the second string, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str.lastIndexOf("hello", "l") // returns 3
```

### Count

- **Signature:** `str.count(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** The number of non-overlapping occurrences of the second string in the first
- **Purity:** Pure
- **Example:**

```
str.count("banana", "a") // returns 3
```

## Properties

### Length

- **Signature:** `str.length(a: String): Number`
- **Input:** One string
- **Output:** The number of characters in the string
- **Purity:** Pure
- **Example:**

```
str.length("hello") // returns 5
```

### Is Empty

- **Signature:** `str.isEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains no characters, false otherwise
- **Purity:** Pure
- **Example:**

```
str.isEmpty("") // returns true
```

### Is Not Empty

- **Signature:** `str.isNotEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains at least one character, false otherwise
- **Purity:** Pure
- **Example:**

```
str.isNotEmpty("hello") // returns true
```

### Is Blank

- **Signature:** `str.isBlank(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string is empty or contains only whitespace, false otherwise
- **Purity:** Pure
- **Example:**

```
str.isBlank("   ") // returns true
str.isBlank("hello") // returns false
```

### Is Uppercase

- **Signature:** `str.isUppercase(a: String): Boolean`
- **Input:** One string
- **Output:** True if all letters in the string are uppercase, false otherwise. Returns false if the string contains no letters.
- **Purity:** Pure
- **Example:**

```
str.isUppercase("HELLO") // returns true
str.isUppercase("Hello") // returns false
```

### Is Lowercase

- **Signature:** `str.isLowercase(a: String): Boolean`
- **Input:** One string
- **Output:** True if all letters in the string are lowercase, false otherwise. Returns false if the string contains no letters.
- **Purity:** Pure
- **Example:**

```
str.isLowercase("hello") // returns true
str.isLowercase("Hello") // returns false
```

### Is Alpha

- **Signature:** `str.isAlpha(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains only letters (a-z, A-Z), false otherwise. Returns false for empty strings.
- **Purity:** Pure
- **Example:**

```
str.isAlpha("hello") // returns true
str.isAlpha("hello123") // returns false
```

### Is Numeric

- **Signature:** `str.isNumeric(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains only digits (0-9), false otherwise. Returns false for empty strings.
- **Purity:** Pure
- **Example:**

```
str.isNumeric("12345") // returns true
str.isNumeric("123.45") // returns false
```

### Is Alpha Numeric

- **Signature:** `str.isAlphaNumeric(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains only letters and digits, false otherwise. Returns false for empty strings.
- **Purity:** Pure
- **Example:**

```
str.isAlphaNumeric("hello123") // returns true
str.isAlphaNumeric("hello-123") // returns false
```

### Bytes

- **Signature:** `str.bytes(a: String): List`
- **Input:** One string
- **Output:** A list containing the UTF-8 byte values of the string
- **Purity:** Pure
- **Example:**

```
str.bytes("AB") // returns [65, 66]
```

### From Bytes

- **Signature:** `str.fromBytes(a: List): String`
- **Input:** A list of numbers representing UTF-8 byte values
- **Output:** A string decoded from the byte values
- **Purity:** Pure
- **Example:**

```
str.fromBytes([65, 66]) // returns "AB"
```

## Comparison

### Compare

- **Signature:** `str.compare(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** 1 if the first string is greater, -1 if smaller, 0 if equal
- **Purity:** Pure
- **Example:**

```
str.compare("apple", "banana") // returns -1
```
