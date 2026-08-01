---
title: Enums
tags:
  - roadmap
  - types
sources: []
---

# Enums

**TLDR**: Enums define types with a fixed set of named variants using pipe syntax (`Color = Red | Green | Blue`), providing type-safe alternatives to ad-hoc strings with typo protection and self-documenting code.

Simple enums define a type that can be exactly one of a fixed set of named variants. They provide better data modeling than ad-hoc strings or maps by offering typo protection and self-documenting code.

## Syntax

```primal
EnumName = Variant1 | Variant2 | Variant3
```

## Examples

```primal
Color = Red | Green | Blue

Direction = North | South | East | West

Status = Pending | Approved | Rejected
```

## Usage

### Construction

Variants are accessed via the enum name:

```primal
favorite() = Color.Blue
heading() = Direction.North
```

### Comparison

Variants can be compared for equality:

```primal
isRed(c) = c == Color.Red
```

### With Conditionals

Use `is` to check a specific variant:

```primal
isPrimary(c) = if (c is Color.Red) true
               else if (c is Color.Blue) true
               else false
```

## Core Functions

| Function            | Description                          | Example                                                        |
| ------------------- | ------------------------------------ | -------------------------------------------------------------- |
| `enum_name(value)`  | Returns the variant name as a string | `enum_name(Color.Red)` => `"Red"`                              |
| `enum_values(type)` | Returns a list of all variants       | `enum_values(Color)` => `[Color.Red, Color.Green, Color.Blue]` |
| `enum_type(value)`  | Returns the enum type                | `enum_type(Color.Red)` => `Color`                              |

## Runtime Type

Simple enum values have the type `Enum` at runtime. The `type_of` function returns `"Enum"` for any enum value.

```primal
type_of(Color.Red)  // => "Enum"
```
