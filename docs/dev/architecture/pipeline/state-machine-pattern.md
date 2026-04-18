---
title: State Machine Pattern
tags: [architecture, state-machine]
sources:
  [
    lib/compiler/models/state.dart,
    lib/compiler/lexical/lexical_analyzer.dart,
    lib/compiler/syntactic/syntactic_analyzer.dart,
  ]
---

# State Machine Pattern

**TLDR**: The Primal compiler uses a generic `State<I, O>` abstraction for tokenization and function definition parsing. Each state holds an iterator and accumulated output, transitioning to new states via the `process()` method until a terminal `ResultState` is reached.

## The State Abstraction

The base `State<I, O>` class in `lib/compiler/models/state.dart` defines the state machine contract:

```dart
class State<I, O> {
  final O output;
  final ListIterator<I> iterator;

  const State(this.iterator, this.output);

  State get next => process(iterator.next);

  State process(I input) => this;
}
```

Key components:

- **`I`** - Input element type (e.g., `Character` for lexer, `Token` for parser)
- **`O`** - Output type being accumulated (e.g., `Lexeme`, `FunctionDefinitionBuilder`)
- **`iterator`** - Shared cursor over the input sequence
- **`output`** - Current accumulated result
- **`next`** - Consumes the next input and delegates to `process()`
- **`process(I input)`** - Returns the next state based on the input

## State Machine Loop

Both the lexer and parser use the same loop pattern:

```dart
List<Result> analyze() {
  final List<Result> result = [];
  final ListIterator<Input> iterator = ListIterator(input);
  State state = InitState(iterator);

  while (iterator.hasNext) {
    state = state.next;

    if (state is ResultState) {
      result.add(state.output);
      state = InitState(iterator);
    }
  }

  // Handle end-of-input state
  return result;
}
```

The pattern:

1. Start in `InitState`
2. Call `state.next` to consume input and transition
3. When `ResultState` is reached, collect output and reset to `InitState`
4. Repeat until input exhausted

## Lexical Analyzer States

The lexer in `lib/compiler/lexical/lexical_analyzer.dart` defines states for each token type.

### State Hierarchy

```
State<Character, O>
├── InitState                    # Starting state, dispatches on character type
├── IdentifierState              # Accumulating identifier/keyword
├── IntegerState                 # Accumulating integer digits
├── DecimalInitState             # Just saw '.' after integer
├── DecimalState                 # Accumulating decimal digits
├── ExponentInitState            # Just saw 'e' or 'E'
├── ExponentSignState            # Just saw sign after exponent marker
├── ExponentState                # Accumulating exponent digits
├── StringState                  # Inside string literal
├── StringEscapeState            # Just saw backslash in string
├── StringHexEscapeState         # Accumulating hex escape digits
├── StringUnicodeEscapeState     # Just saw \u
├── StringBracedEscapeState      # Inside \u{...}
├── MinusState                   # Saw '-', could be minus or arrow
├── PlusState                    # Saw '+'
├── EqualsState                  # Saw '=', could be assign or equal
├── GreaterState                 # Saw '>', could be > or >=
├── LessState                    # Saw '<', could be < or <=
├── PipeState                    # Saw '|', could be | or ||
├── AmpersandState               # Saw '&', could be & or &&
├── BangState                    # Saw '!', could be ! or !=
├── ForwardSlashState            # Saw '/', could be divide or comment
├── AsteriskState                # Saw '*'
├── PercentState                 # Saw '%'
├── SingleLineCommentState       # Inside // comment
├── StartMultiLineCommentState   # Inside /* comment
├── ClosingMultiLineCommentState # Saw * inside /* comment
└── ResultState                  # Terminal state with Token output
```

### Example: Number Tokenization

When the lexer encounters a digit in `InitState`:

```dart
class InitState extends State<Character, void> {
  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return IntegerState(iterator, _lexemeOf(input));
    }
    // ... other cases
  }
}
```

The `IntegerState` continues accumulating digits:

```dart
class IntegerState extends State<Character, Lexeme> {
  final bool lastWasUnderscore;

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return IntegerState(
        iterator,
        output.add(input.value),
        lastWasUnderscore: false,
      );
    } else if (input.value.isUnderscore) {
      // Underscore separator (e.g., 1_000_000)
      return IntegerState(iterator, output, lastWasUnderscore: true);
    } else if (input.value.isDot) {
      return DecimalInitState(iterator, output.add(input.value));
    } else if (input.value.isExponent) {
      return ExponentInitState(iterator, output.add(input.value));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();  // Put delimiter back for next token
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit, underscore, or dot');
    }
  }
}
```

### Example: Two-Character Operators

The `>=` operator demonstrates lookahead:

```dart
class GreaterState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isEquals) {
      // Saw '>=', emit compound token
      return ResultState(
        iterator,
        GreaterOrEqualToken(output.add(input.value)),
      );
    } else if (input.value.isOperatorDelimiter) {
      // Just '>', put back delimiter and emit
      iterator.back();
      return ResultState(iterator, GreaterThanToken(output));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}
```

## Syntactic Analyzer States

The parser in `lib/compiler/syntactic/syntactic_analyzer.dart` uses states for function definition structure.

### State Hierarchy

```
State<Token, O>
├── InitState                        # Expecting function name
├── FunctionNameState                # Just saw function name
├── FunctionWithParametersState      # Inside parameter list, expecting param or )
├── FunctionWithNewParametersState   # Just saw parameter, expecting , or )
├── FunctionWithNextParametersState  # Just saw comma, expecting next parameter
├── FunctionParametrizedState        # Parameters complete, expecting =
└── ResultState                      # Terminal state with FunctionDefinition
```

### Example: Function Definition Parsing

Parsing `square(n) = n * n`:

```dart
class InitState extends State<Token, void> {
  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionNameState(
        iterator,
        FunctionDefinitionBuilder(name: input.value),
      );
    } else {
      throw InvalidTokenError(input, 'identifier');
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinitionBuilder> {
  @override
  State process(Token input) {
    if (input is OpenParenthesisToken) {
      return FunctionWithParametersState(iterator, output);
    } else {
      throw InvalidTokenError(input, "'(' after function name");
    }
  }
}

class FunctionWithParametersState extends State<Token, FunctionDefinitionBuilder> {
  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionWithNewParametersState(
        iterator,
        output.withParameter(input.value),
      );
    } else if (input is CloseParenthesisToken) {
      return FunctionParametrizedState(iterator, output);
    } else {
      throw InvalidTokenError(input, 'identifier or )');
    }
  }
}
```

### Expression Parsing Handoff

When the state machine reaches `=`, it delegates to the recursive descent expression parser:

```dart
class FunctionParametrizedState extends State<Token, FunctionDefinitionBuilder> {
  @override
  State process(Token input) {
    if (input is AssignToken) {
      final ExpressionParser expressionParser = ExpressionParser(iterator);
      return ResultState(
        iterator,
        output.build(expressionParser.expression()),
      );
    } else {
      throw InvalidTokenError(input, "'='");
    }
  }
}
```

## Iterator Backtracking

The `ListIterator` supports `back()` for lookahead with backtracking. This is essential for:

1. **Delimiter detection** - When an identifier ends at whitespace, the whitespace must be put back
2. **Operator disambiguation** - When `>` is followed by a non-`=` character

```dart
// In IntegerState, when delimiter found
iterator.back();
return ResultState(iterator, NumberToken(output));
```

## Benefits of State Machine Pattern

1. **Explicit state transitions** - Each state class documents valid transitions
2. **Immutable states** - States are `const` constructible, producing new states on transition
3. **Shared iterator** - The `ListIterator` is passed through states, maintaining position
4. **Clear terminal condition** - `ResultState` signals completion
5. **Testable in isolation** - Individual states can be unit tested
6. **Extensible** - New token types require only adding new state classes

## Related Documentation

- [[dev/compiler/lexical]] - Full lexical analyzer details
- [[dev/compiler/syntactic]] - Syntactic analyzer with expression parsing
- [[dev/architecture/pipeline/analyzer-pattern]] - The Analyzer base class pattern
