---
title: String
tags:
  - reference
  - strings
sources:
  - lib/compiler/library/string/
---

# String

**TLDR**: Functions for creating, accessing, manipulating, searching, and inspecting text strings including case conversion, padding, splitting, and pattern matching.

Number of functions: 42

## Construction

### Constructor

- **Syntax:** `"Lorem ipsum dolor sit amet": String`
- **Input:** A text surrounded by single or double quotes
- **Output:** A string containing the text
- **Purity:** Pure
- **Example:**

```
"Hello, world!"
```

### Indexing

- **Syntax:** `String[Number]: String`
- **Input:** A string and a number representing the index
- **Output:** The character at the specified index
- **Purity:** Pure
- **Example:**

```
"hello"[0] // returns "h"
```

## Access

### At

- **Signature:** `str.at(a: String, b: Number): String`
- **Input:** A string and a number representing the index
- **Output:** The character at the specified index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str.at("hello", 1) // returns "e"
```

### First

- **Signature:** `str.first(a: String): String`
- **Input:** A string
- **Output:** The first character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str.first("hello") // returns "h"
```

### Last

- **Signature:** `str.last(a: String): String`
- **Input:** A string
- **Output:** The last character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str.last("hello") // returns "o"
```

### Substring

- **Signature:** `str.substring(a: String, b: Number, c: Number): String`
- **Input:** A string and two numbers representing the start and end indices
- **Output:** The substring from the start index to the end index
- **Constraints:** Throws an error if the start index is negative, if the end index is less than the start index, or if the start or end index is out of bounds
- **Purity:** Pure
- **Example:**

```
str.substring("hello", 1, 4) // returns "ell"
```

### Init

- **Signature:** `str.init(a: String): String`
- **Input:** A string
- **Output:** A new string without its last character
- **Purity:** Pure
- **Example:**

```
str.init("hello") // returns "hell"
```

### Rest

- **Signature:** `str.rest(a: String): String`
- **Input:** A string
- **Output:** A new string without its first character
- **Purity:** Pure
- **Example:**

```
str.rest("hello") // returns "ello"
```

### Take

- **Signature:** `str.take(a: String, b: Number): String`
- **Input:** A string and a number representing the number of characters
- **Output:** The first n characters of the string
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
str.take("hello", 3) // returns "hel"
```

### Drop

- **Signature:** `str.drop(a: String, b: Number): String`
- **Input:** A string and a number representing the number of characters
- **Output:** A new string without the first n characters
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
- **Output:** The concatenation of the two strings
- **Purity:** Pure
- **Example:**

```
str.concat("hello", " world") // returns "hello world"
```

### Replace

- **Signature:** `str.replace(a: String, b: String, c: String): String`
- **Input:** A string and two substrings
- **Output:** A new string with all occurrences of the first substring replaced by the second substring
- **Purity:** Pure
- **Example:**

```
str.replace("hello world", "world", "there") // returns "hello there"
```

### Uppercase

- **Signature:** `str.uppercase(a: String): String`
- **Input:** A string
- **Output:** A new string converted to uppercase
- **Purity:** Pure
- **Example:**

```
str.uppercase("hello") // returns "HELLO"
```

### Lowercase

- **Signature:** `str.lowercase(a: String): String`
- **Input:** A string
- **Output:** A new string converted to lowercase
- **Purity:** Pure
- **Example:**

```
str.lowercase("HELLO") // returns "hello"
```

### Trim

- **Signature:** `str.trim(a: String): String`
- **Input:** A string
- **Output:** A new string with leading and trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trim("  hello  ") // returns "hello"
```

### Trim Left

- **Signature:** `str.trimLeft(a: String): String`
- **Input:** A string
- **Output:** A new string with leading whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trimLeft("  hello") // returns "hello"
```

### Trim Right

- **Signature:** `str.trimRight(a: String): String`
- **Input:** A string
- **Output:** A new string with trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str.trimRight("hello  ") // returns "hello"
```

### Capitalize

- **Signature:** `str.capitalize(a: String): String`
- **Input:** A string
- **Output:** A new string with the first character capitalized
- **Purity:** Pure
- **Example:**

```
str.capitalize("hello") // returns "Hello"
```

### Repeat

- **Signature:** `str.repeat(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** The string repeated n times
- **Constraints:** Throws an error if the count is negative
- **Purity:** Pure
- **Example:**

```
str.repeat("ab", 3) // returns "ababab"
```

### Remove At

- **Signature:** `str.removeAt(a: String, b: Number): String`
- **Input:** A string and a number representing the index
- **Output:** A new string with the character at the specified index removed
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str.removeAt("hello", 1) // returns "hllo"
```

### Reverse

- **Signature:** `str.reverse(a: String): String`
- **Input:** A string
- **Output:** A new string with its characters in reverse order
- **Purity:** Pure
- **Example:**

```
str.reverse("hello") // returns "olleh"
```

### Pad Left

- **Signature:** `str.padLeft(a: String, b: Number, c: String): String`
- **Input:** A string, a number representing the minimum length, and a string to pad with
- **Output:** A new string padded on the left with the specified padding
- **Purity:** Pure
- **Example:**

```
str.padLeft("42", 5, "0") // returns "00042"
```

### Pad Right

- **Signature:** `str.padRight(a: String, b: Number, c: String): String`
- **Input:** A string, a number representing the minimum length, and a string to pad with
- **Output:** A new string padded on the right with the specified padding
- **Purity:** Pure
- **Example:**

```
str.padRight("hi", 5, ".") // returns "hi..."
```

### Split

- **Signature:** `str.split(a: String, b: String): List`
- **Input:** A string and a separator string
- **Output:** A list of the string's substrings separated by the separator
- **Purity:** Pure
- **Example:**

```
str.split("a,b,c", ",") // returns ["a", "b", "c"]
```

### Lines

- **Signature:** `str.lines(a: String): List`
- **Input:** A string
- **Output:** A list of lines in the string
- **Purity:** Pure
- **Example:**

```
str.lines("a\nb\nc") // returns ["a", "b", "c"]
```

## Search

### Contains

- **Signature:** `str.contains(a: String, b: String): Boolean`
- **Input:** Two strings.
- **Output:** True if the first string contains the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str.contains("hello world", "world") // returns true
```

### Starts With

- **Signature:** `str.startsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string starts with the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str.startsWith("hello", "hel") // returns true
```

### Ends With

- **Signature:** `str.endsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string ends with the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str.endsWith("hello", "llo") // returns true
```

### Match

- **Signature:** `str.match(a: String, b: String): Boolean`
- **Input:** A string and a regex pattern
- **Output:** True if the string matches the regex pattern. False otherwise.
- **Constraints:** Throws an error if the pattern is not a valid regex
- **Purity:** Pure
- **Example:**

```
str.match("hello123", "[a-z]+[0-9]+") // returns true
```

### Index Of

- **Signature:** `str.indexOf(a: String, b: String): Number`
- **Input:** Two strings.
- **Output:** The index of the first occurrence of the second string in the first string, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str.indexOf("hello", "l") // returns 2
```

### Last Index Of

- **Signature:** `str.lastIndexOf(a: String, b: String): Number`
- **Input:** A string and a substring
- **Output:** The index of the last occurrence of the substring, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str.lastIndexOf("hello", "l") // returns 3
```

### Count

- **Signature:** `str.count(a: String, b: String): Number`
- **Input:** A string and a substring
- **Output:** The number of occurrences of the substring in the string
- **Purity:** Pure
- **Example:**

```
str.count("banana", "a") // returns 3
```

## Properties

### Length

- **Signature:** `str.length(a: String): Number`
- **Input:** A string
- **Output:** The length of the string
- **Purity:** Pure
- **Example:**

```
str.length("hello") // returns 5
```

### Is Empty

- **Signature:** `str.isEmpty(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is empty. False otherwise.
- **Purity:** Pure
- **Example:**

```
str.isEmpty("") // returns true
```

### Is Not Empty

- **Signature:** `str.isNotEmpty(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is not empty. False otherwise.
- **Purity:** Pure
- **Example:**

```
str.isNotEmpty("hello") // returns true
```

### Is Blank

- **Signature:** `str.isBlank(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is empty or contains only whitespace, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isBlank("   ") // returns true
```

### Is Uppercase

- **Signature:** `str.isUppercase(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is all uppercase, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isUppercase("HELLO") // returns true
```

### Is Lowercase

- **Signature:** `str.isLowercase(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is all lowercase, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isLowercase("hello") // returns true
```

### Is Alpha

- **Signature:** `str.isAlpha(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only letters, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isAlpha("hello") // returns true
```

### Is Numeric

- **Signature:** `str.isNumeric(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only digits, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isNumeric("12345") // returns true
```

### Is Alpha Numeric

- **Signature:** `str.isAlphaNumeric(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only letters and digits, false otherwise.
- **Purity:** Pure
- **Example:**

```
str.isAlphaNumeric("hello123") // returns true
```

### Bytes

- **Signature:** `str.bytes(a: String): List`
- **Input:** A string
- **Output:** A list of the string's bytes
- **Purity:** Pure
- **Example:**

```
str.bytes("AB") // returns [65, 66]
```

### From Bytes

- **Signature:** `str.fromBytes(a: List): String`
- **Input:** A list of bytes
- **Output:** A string created from the byte list
- **Purity:** Pure
- **Example:**

```
str.fromBytes([72, 105]) // returns "Hi"
```

## Comparison

### Compare

- **Signature:** `str.compare(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** 1 if the first string is bigger than the second. -1 if it is the smaller. 0 if they are equal.
- **Purity:** Pure
- **Example:**

```
str.compare("apple", "banana") // returns -1
```
