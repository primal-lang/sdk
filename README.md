# Dry
Purely functional programming language that emphasizes functions and immutability. It doesn't have statements, only declarations.

* Store list of character and then convert it to string to create a token
* Store toke location
* Create processors with inputs and outputs
* Integer and Decimal states for numbers in lexical

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
* allow strings with double quote, single quote, accents, etc
* support arrays
* support maps
* higher order functions
* types (all start with uppercase)
* curryfication
* x:xs