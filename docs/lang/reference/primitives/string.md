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

- **Signature:** `str_at(a: String, b: Number): String`
- **Input:** A string and a number representing the index
- **Output:** The character at the specified index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str_at("hello", 1) // returns "e"
```

### First

- **Signature:** `str_first(a: String): String`
- **Input:** A string
- **Output:** The first character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str_first("hello") // returns "h"
```

### Last

- **Signature:** `str_last(a: String): String`
- **Input:** A string
- **Output:** The last character of the string
- **Constraints:** Throws an error if the string is empty
- **Purity:** Pure
- **Example:**

```
str_last("hello") // returns "o"
```

### Substring

- **Signature:** `str_substring(a: String, b: Number, c: Number): String`
- **Input:** A string and two numbers representing the start and end indices
- **Output:** The substring from the start index to the end index
- **Constraints:** Throws an error if the start index is negative, if the end index is less than the start index, or if the start or end index is out of bounds
- **Purity:** Pure
- **Example:**

```
str_substring("hello", 1, 4) // returns "ell"
```

### Init

- **Signature:** `str_init(a: String): String`
- **Input:** A string
- **Output:** A new string without its last character
- **Purity:** Pure
- **Example:**

```
str_init("hello") // returns "hell"
```

### Rest

- **Signature:** `str_rest(a: String): String`
- **Input:** A string
- **Output:** A new string without its first character
- **Purity:** Pure
- **Example:**

```
str_rest("hello") // returns "ello"
```

### Take

- **Signature:** `str_take(a: String, b: Number): String`
- **Input:** A string and a number representing the number of characters
- **Output:** The first n characters of the string
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
str_take("hello", 3) // returns "hel"
```

### Drop

- **Signature:** `str_drop(a: String, b: Number): String`
- **Input:** A string and a number representing the number of characters
- **Output:** A new string without the first n characters
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
str_drop("hello", 2) // returns "llo"
```

## Manipulation

### Concat

- **Signature:** `str_concat(a: String, b: String): String`
- **Input:** Two strings
- **Output:** The concatenation of the two strings
- **Purity:** Pure
- **Example:**

```
str_concat("hello", " world") // returns "hello world"
```

### Replace

- **Signature:** `str_replace(a: String, b: String, c: String): String`
- **Input:** A string, a regex pattern, and a replacement string
- **Output:** A new string with all matches of the regex pattern replaced by the replacement string
- **Constraints:** Throws an error if the pattern is not a valid regex
- **Purity:** Pure
- **Example:**

```
str_replace("hello world", "world", "there") // returns "hello there"
```

### Uppercase

- **Signature:** `str_uppercase(a: String): String`
- **Input:** A string
- **Output:** A new string converted to uppercase
- **Purity:** Pure
- **Example:**

```
str_uppercase("hello") // returns "HELLO"
```

### Lowercase

- **Signature:** `str_lowercase(a: String): String`
- **Input:** A string
- **Output:** A new string converted to lowercase
- **Purity:** Pure
- **Example:**

```
str_lowercase("HELLO") // returns "hello"
```

### Trim

- **Signature:** `str_trim(a: String): String`
- **Input:** A string
- **Output:** A new string with leading and trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str_trim("  hello  ") // returns "hello"
```

### Trim Left

- **Signature:** `str_trimLeft(a: String): String`
- **Input:** A string
- **Output:** A new string with leading whitespace removed
- **Purity:** Pure
- **Example:**

```
str_trimLeft("  hello") // returns "hello"
```

### Trim Right

- **Signature:** `str_trimRight(a: String): String`
- **Input:** A string
- **Output:** A new string with trailing whitespace removed
- **Purity:** Pure
- **Example:**

```
str_trimRight("hello  ") // returns "hello"
```

### Capitalize

- **Signature:** `str_capitalize(a: String): String`
- **Input:** A string
- **Output:** A new string with the first character capitalized
- **Purity:** Pure
- **Example:**

```
str_capitalize("hello") // returns "Hello"
```

### Repeat

- **Signature:** `str_repeat(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** The string repeated n times
- **Constraints:** Throws an error if the count is negative
- **Purity:** Pure
- **Example:**

```
str_repeat("ab", 3) // returns "ababab"
```

### Remove At

- **Signature:** `str_removeAt(a: String, b: Number): String`
- **Input:** A string and a number representing the index
- **Output:** A new string with the character at the specified index removed
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
str_removeAt("hello", 1) // returns "hllo"
```

### Reverse

- **Signature:** `str_reverse(a: String): String`
- **Input:** A string
- **Output:** A new string with its characters in reverse order
- **Purity:** Pure
- **Example:**

```
str_reverse("hello") // returns "olleh"
```

### Pad Left

- **Signature:** `str_padLeft(a: String, b: Number, c: String): String`
- **Input:** A string, a number representing the minimum length, and a string to pad with
- **Output:** A new string padded on the left with the specified padding
- **Purity:** Pure
- **Example:**

```
str_padLeft("42", 5, "0") // returns "00042"
```

### Pad Right

- **Signature:** `str_padRight(a: String, b: Number, c: String): String`
- **Input:** A string, a number representing the minimum length, and a string to pad with
- **Output:** A new string padded on the right with the specified padding
- **Purity:** Pure
- **Example:**

```
str_padRight("hi", 5, ".") // returns "hi..."
```

### Split

- **Signature:** `str_split(a: String, b: String): List`
- **Input:** A string and a separator string
- **Output:** A list of the string's substrings separated by the separator
- **Purity:** Pure
- **Example:**

```
str_split("a,b,c", ",") // returns ["a", "b", "c"]
```

### Lines

- **Signature:** `str_lines(a: String): List`
- **Input:** A string
- **Output:** A list of lines in the string
- **Purity:** Pure
- **Example:**

```
str_lines("a\nb\nc") // returns ["a", "b", "c"]
```

## Search

### Contains

- **Signature:** `str_contains(a: String, b: String): Boolean`
- **Input:** Two strings.
- **Output:** True if the first string contains the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str_contains("hello world", "world") // returns true
```

### Starts With

- **Signature:** `str_startsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string starts with the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str_startsWith("hello", "hel") // returns true
```

### Ends With

- **Signature:** `str_endsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string ends with the second string. False otherwise.
- **Purity:** Pure
- **Example:**

```
str_endsWith("hello", "llo") // returns true
```

### Match

- **Signature:** `str_match(a: String, b: String): Boolean`
- **Input:** A string and a regex pattern
- **Output:** True if the string matches the regex pattern. False otherwise.
- **Constraints:** Throws an error if the pattern is not a valid regex
- **Purity:** Pure
- **Example:**

```
str_match("hello123", "[a-z]+[0-9]+") // returns true
```

### Index Of

- **Signature:** `str_indexOf(a: String, b: String): Number`
- **Input:** Two strings.
- **Output:** The index of the first occurrence of the second string in the first string, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str_indexOf("hello", "l") // returns 2
```

### Last Index Of

- **Signature:** `str_lastIndexOf(a: String, b: String): Number`
- **Input:** A string and a substring
- **Output:** The index of the last occurrence of the substring, or -1 if not found
- **Purity:** Pure
- **Example:**

```
str_lastIndexOf("hello", "l") // returns 3
```

### Count

- **Signature:** `str_count(a: String, b: String): Number`
- **Input:** A string and a substring
- **Output:** The number of occurrences of the substring in the string. If the substring is empty, returns the length of the string plus one (the number of positions where an empty string can be found).
- **Purity:** Pure
- **Example:**

```
str_count("banana", "a") // returns 3
```

## Properties

### Length

- **Signature:** `str_length(a: String): Number`
- **Input:** A string
- **Output:** The length of the string
- **Purity:** Pure
- **Example:**

```
str_length("hello") // returns 5
```

### Is Empty

- **Signature:** `str_isEmpty(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is empty. False otherwise.
- **Purity:** Pure
- **Example:**

```
str_isEmpty("") // returns true
```

### Is Not Empty

- **Signature:** `str_isNotEmpty(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is not empty. False otherwise.
- **Purity:** Pure
- **Example:**

```
str_isNotEmpty("hello") // returns true
```

### Is Blank

- **Signature:** `str_isBlank(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is empty or contains only whitespace, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isBlank("   ") // returns true
```

### Is Uppercase

- **Signature:** `str_isUppercase(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is all uppercase, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isUppercase("HELLO") // returns true
```

### Is Lowercase

- **Signature:** `str_isLowercase(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string is all lowercase, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isLowercase("hello") // returns true
```

### Is Alpha

- **Signature:** `str_isAlpha(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only letters, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isAlpha("hello") // returns true
```

### Is Numeric

- **Signature:** `str_isNumeric(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only digits, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isNumeric("12345") // returns true
```

### Is Alpha Numeric

- **Signature:** `str_isAlphaNumeric(a: String): Boolean`
- **Input:** A string
- **Output:** True if the string contains only letters and digits, false otherwise.
- **Purity:** Pure
- **Example:**

```
str_isAlphaNumeric("hello123") // returns true
```

### Bytes

- **Signature:** `str_bytes(a: String): List`
- **Input:** A string
- **Output:** A list of the string's bytes
- **Purity:** Pure
- **Example:**

```
str_bytes("AB") // returns [65, 66]
```

### From Bytes

- **Signature:** `str_fromBytes(a: List): String`
- **Input:** A list of bytes
- **Output:** A string created from the byte list
- **Purity:** Pure
- **Example:**

```
str_fromBytes([72, 105]) // returns "Hi"
```

## Comparison

### Compare

- **Signature:** `str_compare(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** 1 if the first string is bigger than the second. -1 if it is the smaller. 0 if they are equal.
- **Purity:** Pure
- **Example:**

```
str_compare("apple", "banana") // returns -1
```
