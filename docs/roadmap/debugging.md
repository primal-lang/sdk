### Debug / Trace Expressions

Expression-returning debug helpers that print or validate values without changing program behavior. This is a particularly good fit for Primal because everything is an expression and the CLI already has a `--debug` mode.

**Proposed Syntax:**

```primal
debug.type([1, 2, 3]) // prints in the console "List" and returns [1, 2,3]
```

```primal
debug.trace(foo()) // What could it print in the console?
```

```primal
debug.timed(bar()) // What could it print in the console?
```

**Implementation Notes:**

- `debug.type` must return the type as a string
- `debug.trace` must evaluate its value exactly once and return it unchanged.
- `debug.timed` can piggyback on the existing CLI debug mode but should also work as a normal runtime function.

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
addNumbers(a, b) = a + b

function.name(addNumbers)                        // "addNumbers"
function.arity(addNumbers)                       // 2
function.parameters(addNumbers)                  // ["a", "b"]
function.signature(addNumbers)                   // "addNumbers(a, b)"

greet(name) = "Hello, " + name

function.name(greet)                      // "greet"
function.arity(greet)                     // 1
function.parameters(greet)                // ["name"]
function.signature(greet)                 // "greet(name)"
```

**Implementation Notes:**

- `FunctionTerm` already stores `name` and `parameters`, so most of this proposal is exposing existing runtime metadata.
- `function.signature` can reuse the formatting already present in `FunctionTerm.toString()`.
- Later extensions could add documentation text, source location, or namespace data.
- This is a very high-leverage addition for relatively little implementation work.
