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

    test('equality with identical instance returns true', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: [Parameter.number('x')],
      );
      expect(sig == sig, isTrue);
    });

    test('equality with non-FunctionSignature returns false', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: [Parameter.number('x')],
      );
      // Use dynamic to test the equality operator with different types
      expect(sig == ('func(x)' as dynamic), isFalse);
      expect(sig == (42 as dynamic), isFalse);
      expect(sig == (null as dynamic), isFalse);
    });

    test('hashCode differs for different signatures', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'sub',
        parameters: [Parameter.number('a')],
      );
      const FunctionSignature sig3 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('b')],
      );
      expect(sig1.hashCode, isNot(equals(sig2.hashCode)));
      expect(sig1.hashCode, isNot(equals(sig3.hashCode)));
    });

    test('arity is one for single parameter function', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'identity',
        parameters: [Parameter.any('value')],
      );
      expect(sig.arity, equals(1));
    });

    test('toString with single parameter', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'identity',
        parameters: [Parameter.any('value')],
      );
      expect(sig.toString(), equals('identity(value)'));
    });

    test('toString with namespaced function name', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'math.add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(sig.toString(), equals('math.add(a, b)'));
    });

    test('equality with empty parameters', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      expect(sig1, equals(sig2));
    });

    test('hashCode for empty parameters', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'noop',
        parameters: [],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });

    test('inequality when parameter name differs in middle of list', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('x'),
          Parameter.any('c'),
        ],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('inequality when last parameter name differs', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('z'),
        ],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('equality ignores parameter types', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.number('x'),
          Parameter.string('y'),
          Parameter.boolean('z'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('x'),
          Parameter.any('y'),
          Parameter.any('z'),
        ],
      );
      expect(sig1, equals(sig2));
    });

    test('toString with many parameters', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'multiParam',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
          Parameter.any('d'),
        ],
      );
      expect(sig.toString(), equals('multiParam(a, b, c, d)'));
    });

    test('function name with underscore', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'my_function',
        parameters: [Parameter.any('arg')],
      );
      expect(sig.toString(), equals('my_function(arg)'));
    });

    test('parameter name with underscore', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('my_param')],
      );
      expect(sig.toString(), equals('func(my_param)'));
    });

    test('equality with empty name', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: '',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: '',
        parameters: [Parameter.any('x')],
      );
      expect(sig1, equals(sig2));
    });

    test('toString with empty name', () {
      const FunctionSignature sig = FunctionSignature(
        name: '',
        parameters: [Parameter.any('x')],
      );
      expect(sig.toString(), equals('(x)'));
    });

    test('inequality between empty name and non-empty name', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: '',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [],
      );
      expect(sig1, isNot(equals(sig2)));
    });
  });
}
