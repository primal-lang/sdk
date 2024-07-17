import 'dart:io';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/expression_parser.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';
import 'package:dry/utils/list_iterator.dart';
import 'package:test/test.dart';

List<Token> getTokens(String source) {
  final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
  final List<Character> characters = inputAnalyzer.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

  return lexicalAnalyzer.analyze();
}

void checkTokens(List<Token> actual, List<Token> expected) {
  expect(actual.length, equals(expected.length + 1));

  for (int i = 0; i < expected.length; i++) {
    expect(actual[i].type, equals(expected[i].type));
    expect(actual[i].value, equals(expected[i].value));
    expect(actual[i].location.row, equals(expected[i].location.row));
    expect(actual[i].location.column, equals(expected[i].location.column));
  }
}

Expression getExpression(String source) {
  final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
  final List<Character> characters = inputAnalyzer.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
  final List<Token> tokens = lexicalAnalyzer.analyze();
  final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

  return parser.expression;
}

void checkExpressions(Expression actual, Expression expected) {
  expect(actual.toString(), equals(expected.toString()));
  expect(actual.type, equals(expected.type));

  if ((actual is LiteralExpression) && (expected is LiteralExpression)) {
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

String loadFile(String path) {
  final File file = File('./test/resources/$path');

  return file.readAsStringSync();
}
