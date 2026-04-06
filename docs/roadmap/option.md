The language currently uses exceptions for many missing-value cases, such as indexing failures. `Option` would provide a safer, more explicit path for ordinary absence.

## Example

Add explicit values for present or absent results:

```primal
safeHead(xs) =
  if (list.isEmpty(xs)) none else some(list.first(xs))

value = maybe.unwrapOr(safeHead([]), 0)
```

**Design notes:**

- A minimal representation could be atoms/tags plus payload, but a dedicated runtime type is cleaner.
- The standard library would need helpers such as `maybe.map`, `maybe.flatMap`, `maybe.unwrapOr`, and `maybe.isSome`.
- This becomes especially valuable if safe indexing/lookups are added.
- It also reduces overuse of `try(a, b)` for non-exceptional control flow.

## Comparison: Errors vs Option

Errors:

- Pros
  - The function can express better the problem that occurred (i.e. throw different type of errors), whereas a negative option is always the same
  - The function has a clearer return type
  - If the compiler supports it, it can force the caller to handle the error (or assume the caller of the caller will handle it)
  - Errors can be wrapper into other errors
- Cons
  - To be powerful, the language should allow the user to declare errors:

  ```primal
  error MyError = (a: Integer, b: String)
  ```

  - It's more difficult to make the language pure

Option:

- Pros
  - The function return type indicates the function can fail
  - It allows the language to be functional pure
- Cons
  - It forces the programmer to deal and check the result of a function that returns an option

Use Option when:

- The absence of a value is an expected and common scenario
- You need to compose functions in a functional way

Throw an Error when:

- The error represents an exceptional case that should not normally occur
- You need to provide rich error context or logging, and where the control flow needs to break on error

Two types of errors:

- Programmatic errors: the programmer screwed up
  - It's a bug in the code that can be fixed
- Runtime errors: the real world isn't perfect
  - Can’t be programmatically prevented

If Option is implemented, choose between:

- Maybe: just / nothing

```primal
division(a, b) = if(b != 0, just(a / b), nothing())

process(a) = if(isJust(a), getJust(a), false)
process(a) = if(isNothing(a), true, false)
```

- Result: success / failure

```primal
division(a, b) = if(b != 0, success(a / b), failure())

process(a) = if(isSuccess(a), getSuccess(a), false)
process(a) = if(isFailure(a), true, false)
```

```primal
result.success(a: Any): Result
```

```primal
result.failure(a: Any): Result
```

```primal
result.isSuccess(a: Result): Boolean
```

```primal
result.isFailure(a: Result): Boolean
```

```primal
result.get(a: Result): Any
```
