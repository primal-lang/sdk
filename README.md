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
* Show row and column if compilation fails
* Allow strings with double quote, single quote, accents, etc
* Support arrays
* Support maps
* Higher order functions
* Types (all start with uppercase)
* Curryfication
* x:xs