# Dry
Dry is a purely functional programming language that emphasizes functions and immutability. It doesn't have statements, only declarations.

### Tokens
* Number
* String
* Boolean
* Symbol
* Comma
* Open parenthesis
* Close parenthesis
* Equals

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

Internal types
* String
* Boolean
* Number
* Array
* Function

Expression extends Typed, Evaluated

Function "error" and try catch

Functions negative and positive

Features
* types (start with uppercase)
* curryfication
* tuples book = { title, author, pages }
* x:xs