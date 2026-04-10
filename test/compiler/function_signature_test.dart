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

    test('equality with empty name and empty parameters', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: '',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: '',
        parameters: [],
      );
      expect(sig1, equals(sig2));
    });

    test('hashCode with empty name', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: '',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: '',
        parameters: [Parameter.any('x')],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });

    test('hashCode with empty name and empty parameters', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: '',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: '',
        parameters: [],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });

    test('inequality when first parameter name differs', () {
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
          Parameter.any('z'),
          Parameter.any('b'),
          Parameter.any('c'),
        ],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('inequality when parameter order differs', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('b'), Parameter.any('a')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('hashCode differs when parameter order differs', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('b'), Parameter.any('a')],
      );
      expect(sig1.hashCode, isNot(equals(sig2.hashCode)));
    });

    test('equality ignores parameter types across all type constructors', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.boolean('a'),
          Parameter.number('b'),
          Parameter.string('c'),
          Parameter.file('d'),
          Parameter.directory('e'),
          Parameter.timestamp('f'),
          Parameter.list('g'),
          Parameter.vector('h'),
          Parameter.set('i'),
          Parameter.stack('j'),
          Parameter.queue('k'),
          Parameter.map('l'),
          Parameter.function('m'),
          Parameter.any('n'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
          Parameter.any('d'),
          Parameter.any('e'),
          Parameter.any('f'),
          Parameter.any('g'),
          Parameter.any('h'),
          Parameter.any('i'),
          Parameter.any('j'),
          Parameter.any('k'),
          Parameter.any('l'),
          Parameter.any('m'),
          Parameter.any('n'),
        ],
      );
      expect(sig1, equals(sig2));
    });

    test('toString with empty name and empty parameters', () {
      const FunctionSignature sig = FunctionSignature(
        name: '',
        parameters: [],
      );
      expect(sig.toString(), equals('()'));
    });

    test('name getter returns constructor value', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'myFunction',
        parameters: [],
      );
      expect(sig.name, equals('myFunction'));
    });

    test('parameters getter returns constructor value', () {
      const List<Parameter> params = [
        Parameter.number('x'),
        Parameter.string('y'),
      ];
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: params,
      );
      expect(sig.parameters, equals(params));
    });

    test('hashCode consistency across multiple calls', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );
      final int hash1 = sig.hashCode;
      final int hash2 = sig.hashCode;
      final int hash3 = sig.hashCode;
      expect(hash1, equals(hash2));
      expect(hash2, equals(hash3));
    });

    test('equality is symmetric', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      expect(sig1 == sig2, isTrue);
      expect(sig2 == sig1, isTrue);
    });

    test('equality is transitive', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig3 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      expect(sig1 == sig2, isTrue);
      expect(sig2 == sig3, isTrue);
      expect(sig1 == sig3, isTrue);
    });

    test('can be used as map key', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );
      final Map<FunctionSignature, int> map = {sig1: 42};
      expect(map[sig2], equals(42));
    });

    test('can be used in set', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x')],
      );
      final Set<FunctionSignature> sigSet = <FunctionSignature>{};
      sigSet.add(sig1);
      sigSet.add(sig2);
      expect(sigSet.length, equals(1));
    });

    test('different signatures in set are distinct', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func1',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func2',
        parameters: [Parameter.any('x')],
      );
      final Set<FunctionSignature> sigSet = {sig1, sig2};
      expect(sigSet.length, equals(2));
    });

    test('equality ignores type class parameter types', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.ordered('a'),
          Parameter.equatable('b'),
          Parameter.hashable('c'),
          Parameter.indexable('d'),
          Parameter.collection('e'),
          Parameter.iterable('f'),
          Parameter.addable('g'),
          Parameter.subtractable('h'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
          Parameter.any('d'),
          Parameter.any('e'),
          Parameter.any('f'),
          Parameter.any('g'),
          Parameter.any('h'),
        ],
      );
      expect(sig1, equals(sig2));
    });

    test('hashCode ignores type class parameter types', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.ordered('x'),
          Parameter.equatable('y'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [
          Parameter.any('x'),
          Parameter.any('y'),
        ],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });

    test('toString with type class parameters', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'compare',
        parameters: [
          Parameter.ordered('left'),
          Parameter.ordered('right'),
        ],
      );
      expect(sig.toString(), equals('compare(left, right)'));
    });

    test('arity with many parameters', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'manyParams',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
          Parameter.any('d'),
          Parameter.any('e'),
          Parameter.any('f'),
          Parameter.any('g'),
          Parameter.any('h'),
          Parameter.any('i'),
          Parameter.any('j'),
        ],
      );
      expect(sig.arity, equals(10));
    });

    test('equality with special characters in function name', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'module.submodule.function',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'module.submodule.function',
        parameters: [Parameter.any('x')],
      );
      expect(sig1, equals(sig2));
    });

    test('inequality with different nested namespaces', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'a.b.c',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'a.b.d',
        parameters: [],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('hashCode with deeply nested namespace', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'a.b.c.d.e',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'a.b.c.d.e',
        parameters: [Parameter.any('x')],
      );
      expect(sig1.hashCode, equals(sig2.hashCode));
    });

    test('toString with deeply nested namespace', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'a.b.c.d.e',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );
      expect(sig.toString(), equals('a.b.c.d.e(x, y)'));
    });

    test('equality with numeric-like parameter names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('p1'), Parameter.any('p2')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('p1'), Parameter.any('p2')],
      );
      expect(sig1, equals(sig2));
    });

    test('inequality with similar numeric-like parameter names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('p1')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('p2')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('equality is reflexive', () {
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );
      expect(sig == sig, isTrue);
    });

    test('can look up signature in map with different parameter types', () {
      const FunctionSignature key = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      const FunctionSignature lookup = FunctionSignature(
        name: 'add',
        parameters: [Parameter.string('a'), Parameter.string('b')],
      );
      final Map<FunctionSignature, String> map = {key: 'found'};
      expect(map[lookup], equals('found'));
    });

    test(
      'signatures with same name but different arity are distinct in set',
      () {
        const FunctionSignature sig1 = FunctionSignature(
          name: 'func',
          parameters: [Parameter.any('a')],
        );
        const FunctionSignature sig2 = FunctionSignature(
          name: 'func',
          parameters: [Parameter.any('a'), Parameter.any('b')],
        );
        final Set<FunctionSignature> sigSet = {sig1, sig2};
        expect(sigSet.length, equals(2));
      },
    );

    test(
      'hashCode differs for signatures with same name but different arity',
      () {
        const FunctionSignature sig1 = FunctionSignature(
          name: 'func',
          parameters: [Parameter.any('a')],
        );
        const FunctionSignature sig2 = FunctionSignature(
          name: 'func',
          parameters: [Parameter.any('a'), Parameter.any('b')],
        );
        expect(sig1.hashCode, isNot(equals(sig2.hashCode)));
      },
    );

    test('equality with case-sensitive function names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'Function',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'function',
        parameters: [],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('equality with case-sensitive parameter names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('Value')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('value')],
      );
      expect(sig1, isNot(equals(sig2)));
    });

    test('hashCode differs for case-different function names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'Function',
        parameters: [],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'function',
        parameters: [],
      );
      expect(sig1.hashCode, isNot(equals(sig2.hashCode)));
    });

    test('hashCode differs for case-different parameter names', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('Value')],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'func',
        parameters: [Parameter.any('value')],
      );
      expect(sig1.hashCode, isNot(equals(sig2.hashCode)));
    });

    test('parameters list is accessible and correct length', () {
      const List<Parameter> params = [
        Parameter.number('a'),
        Parameter.string('b'),
        Parameter.boolean('c'),
      ];
      const FunctionSignature sig = FunctionSignature(
        name: 'func',
        parameters: params,
      );
      expect(sig.parameters.length, equals(3));
      expect(sig.parameters[0].name, equals('a'));
      expect(sig.parameters[1].name, equals('b'));
      expect(sig.parameters[2].name, equals('c'));
    });

    test('equality with all type class parameter constructors mixed', () {
      const FunctionSignature sig1 = FunctionSignature(
        name: 'comprehensive',
        parameters: [
          Parameter.boolean('a'),
          Parameter.number('b'),
          Parameter.string('c'),
          Parameter.file('d'),
          Parameter.directory('e'),
          Parameter.timestamp('f'),
          Parameter.list('g'),
          Parameter.vector('h'),
          Parameter.set('i'),
          Parameter.stack('j'),
          Parameter.queue('k'),
          Parameter.map('l'),
          Parameter.function('m'),
          Parameter.any('n'),
          Parameter.ordered('o'),
          Parameter.equatable('p'),
          Parameter.hashable('q'),
          Parameter.indexable('r'),
          Parameter.collection('s'),
          Parameter.iterable('t'),
          Parameter.addable('u'),
          Parameter.subtractable('v'),
        ],
      );
      const FunctionSignature sig2 = FunctionSignature(
        name: 'comprehensive',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
          Parameter.any('d'),
          Parameter.any('e'),
          Parameter.any('f'),
          Parameter.any('g'),
          Parameter.any('h'),
          Parameter.any('i'),
          Parameter.any('j'),
          Parameter.any('k'),
          Parameter.any('l'),
          Parameter.any('m'),
          Parameter.any('n'),
          Parameter.any('o'),
          Parameter.any('p'),
          Parameter.any('q'),
          Parameter.any('r'),
          Parameter.any('s'),
          Parameter.any('t'),
          Parameter.any('u'),
          Parameter.any('v'),
        ],
      );
      expect(sig1, equals(sig2));
      expect(sig1.hashCode, equals(sig2.hashCode));
    });
  });
}
