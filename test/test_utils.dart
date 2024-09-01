import 'dart:io';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/compiler/scanner/scanner_analyzer.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';
import 'package:test/test.dart';

List<Token> getTokens(String source) {
  final Scanner scanner = Scanner(source);
  final List<Character> characters = scanner.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

  return lexicalAnalyzer.analyze();
}

List<FunctionDefinition> getFunctions(String source) {
  final List<Token> tokens = getTokens(source);
  final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);

  return syntacticAnalyzer.analyze();
}

IntermediateCode getIntermediateCode(String source) {
  final List<FunctionDefinition> functions = getFunctions(source);
  final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

  return semanticAnalyzer.analyze();
}

Runtime getRuntime(String source) {
  final IntermediateCode intermediateCode = getIntermediateCode(source);

  return Runtime(intermediateCode);
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

  if ((actual is ListExpression) && (expected is ListExpression)) {
    expect(actual.elements.length, equals(expected.elements.length));

    for (int i = 0; i < actual.elements.length; i++) {
      checkExpressions(actual.elements[i], expected.elements[i]);
    }
  } else if ((actual is LiteralExpression) && (expected is LiteralExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is IdentifierExpression) &&
      (expected is IdentifierExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is IdentifierExpression) &&
      (expected is LiteralExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is LiteralExpression) &&
      (expected is IdentifierExpression)) {
    expect(actual.value, equals(expected.value));
  } else if ((actual is CallExpression) && (expected is CallExpression)) {
    expect(actual.name, equals(expected.name));
    expect(actual.arguments.length, equals(expected.arguments.length));

    for (int i = 0; i < actual.arguments.length; i++) {
      checkExpressions(actual.arguments[i], expected.arguments[i]);
    }
  } else {
    fail('Expression types do not match');
  }
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

    checkExpressions(actual[i].expression!, expected[i].expression!);
  }
}

void checkResult(Runtime runtime, Object result) {
  expect(runtime.executeMain(), result.toString());
}

StringToken stringToken(String value, int row, int column) =>
    StringToken(Lexeme(
      value: value,
      location: Location(row: row, column: column),
    ));

NumberToken numberToken(num value, int row, int column) => NumberToken(Lexeme(
      value: value.toString(),
      location: Location(row: row, column: column),
    ));

BooleanToken booleanToken(bool value, int row, int column) =>
    BooleanToken(Lexeme(
      value: value.toString(),
      location: Location(row: row, column: column),
    ));

IdentifierToken identifierToken(String value, int row, int column) =>
    IdentifierToken(Lexeme(
      value: value,
      location: Location(row: row, column: column),
    ));

String loadFile(String path) {
  final File file = File('./test/resources/$path');

  return file.readAsStringSync();
}
