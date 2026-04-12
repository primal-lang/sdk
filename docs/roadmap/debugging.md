### Debug / Trace Expressions

Expression-returning debug helpers that print or validate values without changing program behavior. This is a particularly good fit for Primal because everything is an expression and the CLI already has a `--debug` mode.

**Proposed Syntax:**

```primal
x() = debug.trace(expensiveComputation())
y() = debug.trace("after filter", list.filter(data, isValid))

safeHead(xs) =
  debug.assert(
    list.isNotEmpty(xs),
    list.first(xs),
    "expected a non-empty list"
  )

measured() = debug.timed("loadUsers", loadUsers())
debug.type(measured())                    // "List", "Number", "Function", ...

traceStep(x) = debug.trace("step", x)
result() = list.map([1, 2, 3], traceStep)

debug.traceWhen(isVerbose, "payload", payload)
```

**Use Cases:**

- Debugging during development
- Performance profiling
- Understanding recursion
- Validating assumptions

**Implementation Notes:**

- The MVP should be library functions rather than decorators, breakpoints, or statement-like forms.
- `debug.trace` must evaluate its value exactly once and return it unchanged.
- `debug.assert` should throw a regular runtime error so it composes naturally with `try`.
- `debug.timed` can piggyback on the existing CLI debug mode but should also work as a normal runtime function.
- Rich call-stack tracing can come later once the runtime carries more source-location metadata through evaluation.

### Function Introspection

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Expose metadata about function values. Primal already has first-class functions, but once a function is passed around there is very little users can ask about it. Introspection would make higher-order code, debugging, and tooling much nicer.

**Proposed Syntax:**

```primal
f() = num.add

function.name(f())                        // "num.add"
function.arity(f())                       // 2
function.parameters(f())                  // ["a", "b"]
function.isNative(f())                    // true
function.signature(f())                   // "num.add(a: Number, b: Number)"

greet(name) = "Hello, " + name

function.name(greet)                      // "greet"
function.arity(greet)                     // 1
function.parameters(greet)                // ["name"]
function.isNative(greet)                  // false

list.map([num.add, num.sub, greet], function.name)
```

**Use Cases:**

- REPL tooling
- Debug output
- Higher-order libraries
- Documentation generation
- Better error messages around callables

**Implementation Notes:**

- `FunctionTerm` already stores `name` and `parameters`, so most of this proposal is exposing existing runtime metadata.
- `function.signature` can reuse the formatting already present in `FunctionTerm.toString()`.
- Later extensions could add documentation text, source location, or namespace data.
- This is a very high-leverage addition for relatively little implementation work.
