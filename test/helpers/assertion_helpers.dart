import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:test/test.dart';

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
    expect(actual.value.length, equals(expected.value.length));

    for (int i = 0; i < actual.value.length; i++) {
      checkExpressions(actual.value[i], expected.value[i]);
    }
  } else if ((actual is MapExpression) && (expected is MapExpression)) {
    expect(actual.value.toString(), equals(expected.value.toString()));
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
    expect(actual.callee.toString(), equals(expected.callee.toString()));
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
      expect(actualParameters[j], equals(expectedParameters[j]));
    }

    checkExpressions(actual[i].expression!, expected[i].expression!);
  }
}

void checkResult(Runtime runtime, Object result) {
  expect(runtime.executeMain(), result.toString());
}

/// Like [checkResult] but also asserts the runtime node type matches [T].
///
/// This catches cases where toString() representations collide across types
/// (e.g. NumberNode(1) vs StringNode("1")).
void checkTypedResult<T extends Node>(Runtime runtime, Object result) {
  final expression = runtime.mainExpression([]);
  final node = expression.toNode().evaluate();
  expect(
    node,
    isA<T>(),
    reason: 'Expected node type $T but got ${node.runtimeType}',
  );
  expect(runtime.executeMain(), result.toString());
}

void checkDates(Runtime runtime, DateTime result) {
  expect(
    runtime.executeMain().substring(0, 14),
    equals('"${result.toIso8601String().substring(0, 13)}'),
  );
}
