### Javascript

```javascript
const factorial = (n) => (n == 0 ? 1 : n * factorial(n - 1));
```

### Dart

```dart
factorial(n) => n == 0 ? 1 : n * factorial(n - 1);
```

### Python

```python
def factorial(n): return 1 if n == 0 else n * factorial(n-1)
```

### Ruby

```ruby
def factorial(n)
  return 1 if n == 0
  return n * factorial(n - 1)
end
```

### Lua

```lua
function factorial(n)
    return n == 0 and 1 or n * factorial(n - 1)
end
```
