import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';

StringToken stringToken(String value, int row, int column) => StringToken(
  Lexeme(
    value: value,
    location: Location(row: row, column: column),
  ),
);

NumberToken numberToken(num value, int row, int column) => NumberToken(
  Lexeme(
    value: value.toString(),
    location: Location(row: row, column: column),
  ),
);

BooleanToken booleanToken(bool value, int row, int column) => BooleanToken(
  Lexeme(
    value: value.toString(),
    location: Location(row: row, column: column),
  ),
);

IdentifierToken identifierToken(String value, int row, int column) =>
    IdentifierToken(
      Lexeme(
        value: value,
        location: Location(row: row, column: column),
      ),
    );
