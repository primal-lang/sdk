---
title: Environment
tags:
  - reference
  - system
sources:
  - lib/compiler/library/environment/
---

# Environment

**TLDR**: Functions for reading environment variables and checking whether they exist in the system.

Number of functions: 2

## Functions

### Get

- **Signature:** `env.get(a: String): String`
- **Input:** A string representing the name of the variable.
- **Output:** The value of the variable. If the variable does not exist, an empty string is returned.
- **Purity:** Impure
- **Example:**

```
env.get("HOME") // returns "/home/user"
```

> **Note:** This function is not implemented on the web platform.

### Has

- **Signature:** `env.has(a: String): Boolean`
- **Input:** A string representing the name of the variable.
- **Output:** True if the variable exists, false otherwise.
- **Purity:** Impure
- **Example:**

```
env.has("HOME") // returns true
```

> **Note:** This function is not implemented on the web platform.
