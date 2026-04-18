---
title: Immutability
tags: [design, immutability]
sources: []
---

# Immutability

**TLDR**: All values in Primal are immutable. Once created, a value cannot be changed. Operations that appear to modify data instead return new values, leaving the original unchanged.

## Why Immutability?

In many programming languages, you can change the contents of a variable after it is created. This is called mutation. While mutation can seem convenient, it often leads to subtle bugs that are hard to track down.

Primal takes a different approach: all values are immutable. When you perform an operation on a value, you get a new value back. The original value remains exactly as it was.

## Simpler Reasoning

Immutability makes programs easier to understand. When you see a value bound to a name, you know that name will always refer to the same value throughout its scope. There are no surprises from code elsewhere changing what you are working with.

Consider this example:

```
numbers() = [1, 2, 3]

main() =
    let original = numbers() in
    let modified = list.insertEnd(original, 4) in
    list.length(original) // returns 3, not 4
```

The `original` list still has 3 elements after we create `modified`. The `list.insertEnd` function did not change `original`; it created a brand new list with 4 elements.

## List Operations Return New Lists

All list operations follow this pattern. Functions that seem like they would modify a list instead return a new list:

```
// Adding elements
list.insertStart([2, 3], 1)     // returns [1, 2, 3]
list.insertEnd([1, 2], 3)       // returns [1, 2, 3]
list.concat([1, 2], [3, 4])     // returns [1, 2, 3, 4]

// Removing elements
list.remove([1, 2, 3, 2], 2)    // returns [1, 3]
list.removeAt([1, 2, 3], 1)     // returns [1, 3]

// Modifying elements
list.set([1, 2, 3], 1, 99)      // returns [1, 99, 3]
list.reverse([1, 2, 3])         // returns [3, 2, 1]
```

In each case, the original list passed to the function is unchanged.

## Map Operations Return New Maps

The same principle applies to maps:

```
// Creating and "modifying" a map
let users = {"alice": 1, "bob": 2} in
let updated = map.set(users, "charlie", 3) in
map.length(users)    // returns 2
map.length(updated)  // returns 3
```

The `users` map still has 2 entries. The `updated` map is a new map with 3 entries.

## Why This Matters

Immutability provides several practical benefits:

**No Shared State Bugs**: In languages with mutable data, passing a list to a function means that function might change your list. In Primal, you can safely pass data anywhere without worrying about unexpected modifications.

**Easier Debugging**: When something goes wrong, you can trace through your code knowing that values do not change unexpectedly. Each value is exactly what it was when created.

**Referential Transparency**: A function called with the same arguments will always return the same result. This makes functions predictable and easier to test.

## Working with Immutability

The key mental shift is thinking in terms of transformations rather than modifications. Instead of "change this list," think "create a new list based on this one."

Here is a common pattern using `let` expressions to chain transformations:

```
processNumbers(numbers) =
    let doubled = list.map(numbers, double) in
    let filtered = list.filter(doubled, isPositive) in
    let sorted = list.sort(filtered, num.compare) in
    sorted
```

Each step creates a new value based on the previous one. The original `numbers` list is never modified.

## Practical Implications

When writing Primal programs:

- Always capture the return value of operations that "modify" data
- Use `let` expressions to chain transformations
- Trust that passing data to functions will not cause side effects on that data
- Think of data flow as a series of transformations, not a sequence of mutations
