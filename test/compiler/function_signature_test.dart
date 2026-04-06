import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionSignature', () {
    test('arity returns parameter count', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(sig.arity, equals(2));
    });

    test('arity is zero for parameterless function', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      expect(sig.arity, equals(0));
    });

    test('equality compares name and parameter names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      expect(sig1, equals(sig2));
    });

    test('inequality when names differ', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'sub',
        parameters: [Parameter.number('a')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('inequality when parameter names differ', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('y')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('inequality when parameter counts differ', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('a')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('toString formats correctly', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'test.func',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );
      expect(sig.toString(), equals('test.func(x, y)'));
    });

    test('toString with no parameters', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      expect(sig.toString(), equals('noop()'));
    });

    test('hashCode is consistent with equality', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });
  });
}
