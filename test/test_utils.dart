import 'dart:io';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';
import 'package:test/test.dart';

List<Token> getTokens(String source) {
  final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
  final List<Character> characters = inputAnalyzer.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

  return lexicalAnalyzer.analyze();
}

void checkLocations(Location actual, Location expected) {
  expect(actual.row, equals(expected.row));
  expect(actual.column, equals(expected.column));
}

void checkTokens(List<Token> actual, List<Token> expected) {
  expect(actual.length, equals(expected.length));

  for (int i = 0; i < expected.length; i++) {
    expect(actual[i].runtimeType, equals(expected[i].runtimeType));
    expect(actual[i].value, equals(expected[i].value));
    checkLocations(actual[i].location, expected[i].location);
  }
}

void checkExpressions(Expression actual, Expression expected) {
  expect(actual.toString(), equals(expected.toString()));
  expect(actual.runtimeType, equals(expected.runtimeType));
  checkLocations(actual.location, expected.location);

  if ((actual is LiteralExpression) && (expected is LiteralExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is SymbolExpression) && (expected is SymbolExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is SymbolExpression) && (expected is LiteralExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is LiteralExpression) && (expected is SymbolExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is FunctionCallExpression) &&
      (expected is FunctionCallExpression)) {
    expect(actual.name, equals(expected.name));
    expect(actual.arguments.length, equals(expected.arguments.length));

    for (int i = 0; i < actual.arguments.length; i++) {
      checkExpressions(actual.arguments[i], expected.arguments[i]);
    }
  } else {
    fail('Expression types do not match');
  }
}

List<FunctionDefinition> getFunctions(String source) {
  final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
  final List<Character> characters = inputAnalyzer.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
  final List<Token> tokens = lexicalAnalyzer.analyze();
  final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);

  return syntacticAnalyzer.analyze();
}

void checkFunctions(
  List<FunctionDefinition> actual,
  List<FunctionDefinition> expected,
) {
  expect(actual.length, equals(expected.length));

  for (int i = 0; i < actual.length; i++) {
    expect(actual[i].name, equals(expected[i].name));

    final List<String> actualParameters = actual[i].parameters;
    final List<String> expectedParameters = expected[i].parameters;

    expect(actualParameters.length, equals(expectedParameters.length));

    for (int j = 0; j < actualParameters.length; j++) {
      expect(actualParameters[i], equals(expectedParameters[i]));
    }

    checkExpressions(actual[i].expression, expected[i].expression);
  }
}

Token stringToken(String value, [int row = 1, int column = 1]) =>
    StringToken(Lexeme(
      value: value,
      location: Location(row: row, column: column),
    ));

Token numberToken(num value, [int row = 1, int column = 1]) =>
    NumberToken(Lexeme(
      value: value.toString(),
      location: Location(row: row, column: column),
    ));

Token booleanToken(bool value, [int row = 1, int column = 1]) =>
    BooleanToken(Lexeme(
      value: value.toString(),
      location: Location(row: row, column: column),
    ));

Token symbolToken(String value, [int row = 1, int column = 1]) =>
    SymbolToken(Lexeme(
      value: value,
      location: Location(row: row, column: column),
    ));

String loadFile(String path) {
  final File file = File('./test/resources/$path');

  return file.readAsStringSync();
}
