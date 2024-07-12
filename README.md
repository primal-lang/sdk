# Dry
Purely functional programming language that emphasizes functions and immutability. It doesn't have statements, only declarations.

### Literal
Number | String | Boolean

### Symbol
Identifier

### Parameters
Symbol[,Symbol]*

### FunctionCall
Symbol([Parameters]*)

### Expression
Literal | FunctionCall

### Function definition
Symbol=Expression

TODO
* show row and column if compilation fails
* support arrays
* support maps
* higher order functions
* types (all start with uppercase)
* curryfication
* x:xs