# String

## Construction

### Constructor

- **Syntax:** `"text": String`
- **Input:** Text surrounded by single or double quotes
- **Output:** A string
- **Example:**

```
"hello world" // returns "hello world"
```

### Indexing

- **Syntax:** `String[Number]: String`
- **Input:** A string and an index
- **Output:** The character at the specified index position
- **Example:**

```
"hello"[0] // returns "h"
```

## Access

### At

- **Signature:** `str.at(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** The character at the specified index
- **Example:**

```
str.at("hello", 1) // returns "e"
```

### First

- **Signature:** `str.first(a: String): String`
- **Input:** One string
- **Output:** The first character of the string
- **Example:**

```
str.first("hello") // returns "h"
```

### Last

- **Signature:** `str.last(a: String): String`
- **Input:** One string
- **Output:** The last character of the string
- **Example:**

```
str.last("hello") // returns "o"
```

### Substring

- **Signature:** `str.substring(a: String, b: Number, c: Number): String`
- **Input:** A string, a start index, and an end index
- **Output:** The extracted portion of the string
- **Example:**

```
str.substring("hello", 1, 4) // returns "ell"
```

### Init

- **Signature:** `str.init(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the last character
- **Example:**

```
str.init("hello") // returns "hell"
```

### Rest

- **Signature:** `str.rest(a: String): String`
- **Input:** One string
- **Output:** A new string excluding the first character
- **Example:**

```
str.rest("hello") // returns "ello"
```

### Take

- **Signature:** `str.take(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** The first n characters from the string
- **Example:**

```
str.take("hello", 3) // returns "hel"
```

### Drop

- **Signature:** `str.drop(a: String, b: Number): String`
- **Input:** A string and a number
- **Output:** A new string omitting the first n characters
- **Example:**

```
str.drop("hello", 2) // returns "llo"
```

## Manipulation

### Concat

- **Signature:** `str.concat(a: String, b: String): String`
- **Input:** Two strings
- **Output:** The two strings combined together
- **Example:**

```
str.concat("hello", " world") // returns "hello world"
```

### Replace

- **Signature:** `str.replace(a: String, b: String, c: String): String`
- **Input:** A string, a target substring, and a replacement substring
- **Output:** A new string with all instances of the target replaced
- **Example:**

```
str.replace("hello world", "world", "there") // returns "hello there"
```

### Uppercase

- **Signature:** `str.uppercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to uppercase letters
- **Example:**

```
str.uppercase("hello") // returns "HELLO"
```

### Lowercase

- **Signature:** `str.lowercase(a: String): String`
- **Input:** One string
- **Output:** A new string converted to lowercase letters
- **Example:**

```
str.lowercase("HELLO") // returns "hello"
```

### Trim

- **Signature:** `str.trim(a: String): String`
- **Input:** One string
- **Output:** A new string with leading and trailing whitespace removed
- **Example:**

```
str.trim("  hello  ") // returns "hello"
```

### Remove At

- **Signature:** `str.removeAt(a: String, b: Number): String`
- **Input:** A string and an index
- **Output:** A new string with the character at the specified index removed
- **Example:**

```
str.removeAt("hello", 1) // returns "hllo"
```

### Reverse

- **Signature:** `str.reverse(a: String): String`
- **Input:** One string
- **Output:** A new string with characters in reverse order
- **Example:**

```
str.reverse("hello") // returns "olleh"
```

### Pad Left

- **Signature:** `str.padLeft(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the left to reach minimum length
- **Example:**

```
str.padLeft("42", 5, "0") // returns "00042"
```

### Pad Right

- **Signature:** `str.padRight(a: String, b: Number, c: String): String`
- **Input:** A string, a minimum length, and a padding string
- **Output:** A new string padded on the right to reach minimum length
- **Example:**

```
str.padRight("hi", 5, ".") // returns "hi..."
```

### Split

- **Signature:** `str.split(a: String, b: String): List`
- **Input:** A string and a separator string
- **Output:** A list of substrings divided by the separator
- **Example:**

```
str.split("a,b,c", ",") // returns ["a", "b", "c"]
```

## Search

### Contains

- **Signature:** `str.contains(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string includes the second, false otherwise
- **Example:**

```
str.contains("hello world", "world") // returns true
```

### Starts With

- **Signature:** `str.startsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string begins with the second, false otherwise
- **Example:**

```
str.startsWith("hello", "hel") // returns true
```

### Ends With

- **Signature:** `str.endsWith(a: String, b: String): Boolean`
- **Input:** Two strings
- **Output:** True if the first string ends with the second, false otherwise
- **Example:**

```
str.endsWith("hello", "llo") // returns true
```

### Match

- **Signature:** `str.match(a: String, b: String): Boolean`
- **Input:** A string and a regex pattern
- **Output:** True if the string matches the pattern, false otherwise
- **Example:**

```
str.match("hello123", "[a-z]+[0-9]+") // returns true
```

### Index Of

- **Signature:** `str.indexOf(a: String, b: Any): Number`
- **Input:** A string and a value
- **Output:** The position of the first occurrence, or -1 if not found
- **Example:**

```
str.indexOf("hello", "l") // returns 2
```

## Properties

### Length

- **Signature:** `str.length(a: String): Number`
- **Input:** One string
- **Output:** The number of characters in the string
- **Example:**

```
str.length("hello") // returns 5
```

### Is Empty

- **Signature:** `str.isEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains no characters, false otherwise
- **Example:**

```
str.isEmpty("") // returns true
```

### Is Not Empty

- **Signature:** `str.isNotEmpty(a: String): Boolean`
- **Input:** One string
- **Output:** True if the string contains at least one character, false otherwise
- **Example:**

```
str.isNotEmpty("hello") // returns true
```

### Bytes

- **Signature:** `str.bytes(a: String): List`
- **Input:** One string
- **Output:** A list containing the byte values of the string
- **Example:**

```
str.bytes("AB") // returns [65, 66]
```

## Comparison

### Compare

- **Signature:** `str.compare(a: String, b: String): Number`
- **Input:** Two strings
- **Output:** 1 if the first string is greater, -1 if smaller, 0 if equal
- **Example:**

```
str.compare("apple", "banana") // returns -1
```
