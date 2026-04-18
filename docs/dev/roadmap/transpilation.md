---
title: Transpilation
tags:
  - roadmap
  - tooling
sources: []
---

# Transpilation

**TLDR**: Compile Primal code to other languages (JavaScript, Dart, Python, Ruby, Lua) via CLI flags like `primal --compile=javascript script.prm`, enabling Primal programs to run in different runtime environments.

# Javascript

```javascript
const factorial = (n) => (n == 0 ? 1 : n * factorial(n - 1));
```

# Dart

```dart
factorial(n) => n == 0 ? 1 : n * factorial(n - 1);
```

# Python

```python
def factorial(n): return 1 if n == 0 else n * factorial(n-1)
```

# Ruby

```ruby
def factorial(n)
  return 1 if n == 0
  return n * factorial(n - 1)
end
```

# Lua

```lua
function factorial(n)
    return n == 0 and 1 or n * factorial(n - 1)
end
```

# CLI

```bash
primal --compile=javascript script.prm
```

Update the CLI help to include the new flags for the supported languages.
