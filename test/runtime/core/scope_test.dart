@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:test/test.dart';

void main() {
  group('Scope', () {
    test('empty scope has no data', () {
      const Scope scope = Scope();
      expect(scope.data, isEmpty);
    });

    test('get existing key returns value', () {
      const Scope<int> scope = Scope({'x': 42});
      expect(scope.get('x'), 42);
    });

    test('get missing key throws NotFoundInScopeError', () {
      const Scope<int> scope = Scope({'x': 42});
      expect(
        () => scope.get('y'),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('empty scope get throws NotFoundInScopeError', () {
      const Scope scope = Scope();
      expect(
        () => scope.get('anything'),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('multiple keys', () {
      const Scope<int> scope = Scope({'a': 1, 'b': 2, 'c': 3});
      expect(scope.get('a'), 1);
      expect(scope.get('b'), 2);
      expect(scope.get('c'), 3);
    });

    test('scope with Node values', () {
      const Scope<Node> scope = Scope({'x': NumberNode(10)});
      final Node result = scope.get('x');
      expect(result, isA<NumberNode>());
      expect((result as NumberNode).value, 10);
    });
  });

  group('Scope.from()', () {
    test('creates scope from parameters and arguments', () {
      final Scope<Node> scope = Scope.from(
        functionName: 'f',
        parameters: [Parameter.number('x')],
        arguments: [const NumberNode(5)],
      );
      final Node result = scope.get('x');
      expect(result, isA<NumberNode>());
      expect((result as NumberNode).value, 5);
    });

    test('creates scope with multiple parameters', () {
      final Scope<Node> scope = Scope.from(
        functionName: 'f',
        parameters: [Parameter.number('a'), Parameter.string('b')],
        arguments: [const NumberNode(1), const StringNode('hello')],
      );
      expect((scope.get('a') as NumberNode).value, 1);
      expect((scope.get('b') as StringNode).value, 'hello');
    });

    test('creates scope with empty parameters and arguments', () {
      final Scope<Node> scope = Scope.from(
        functionName: 'f',
        parameters: [],
        arguments: [],
      );
      expect(scope.data, isEmpty);
    });

    test(
      'mismatched parameter/argument counts throws InvalidArgumentCountError',
      () {
        expect(
          () => Scope.from(
            functionName: 'f',
            parameters: [Parameter.number('x'), Parameter.number('y')],
            arguments: [const NumberNode(1)],
          ),
          throwsA(isA<InvalidArgumentCountError>()),
        );
      },
    );

    test('too many arguments throws InvalidArgumentCountError', () {
      expect(
        () => Scope.from(
          functionName: 'f',
          parameters: [Parameter.number('x')],
          arguments: [const NumberNode(1), const NumberNode(2)],
        ),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });
  });

  group('Bindings', () {
    test('get existing key returns node', () {
      const Bindings bindings = Bindings({'x': NumberNode(42)});
      final Node result = bindings.get('x');
      expect(result, isA<NumberNode>());
      expect((result as NumberNode).value, 42);
    });

    test('get missing key throws NotFoundInScopeError', () {
      const Bindings bindings = Bindings({'x': NumberNode(42)});
      expect(
        () => bindings.get('y'),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('empty bindings get throws NotFoundInScopeError', () {
      const Bindings bindings = Bindings({});
      expect(
        () => bindings.get('x'),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('multiple keys', () {
      const Bindings bindings = Bindings({
        'a': NumberNode(1),
        'b': StringNode('two'),
        'c': BooleanNode(true),
      });
      expect((bindings.get('a') as NumberNode).value, 1);
      expect((bindings.get('b') as StringNode).value, 'two');
      expect((bindings.get('c') as BooleanNode).value, true);
    });
  });

  group('Bindings.from()', () {
    test('creates from parameters and arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [Parameter.number('x')],
        arguments: [const NumberNode(10)],
      );
      final Node result = bindings.get('x');
      expect(result, isA<NumberNode>());
      expect((result as NumberNode).value, 10);
    });

    test('with empty parameters and arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [],
        arguments: [],
      );
      expect(bindings.data, isEmpty);
    });

    test('multiple parameters', () {
      final Bindings bindings = Bindings.from(
        parameters: [
          Parameter.number('a'),
          Parameter.string('b'),
          Parameter.boolean('c'),
        ],
        arguments: [
          const NumberNode(1),
          const StringNode('hello'),
          const BooleanNode(true),
        ],
      );
      expect((bindings.get('a') as NumberNode).value, 1);
      expect((bindings.get('b') as StringNode).value, 'hello');
      expect((bindings.get('c') as BooleanNode).value, true);
    });

    test('parameter names map correctly to arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [Parameter.number('first'), Parameter.number('second')],
        arguments: [const NumberNode(100), const NumberNode(200)],
      );
      expect((bindings.get('first') as NumberNode).value, 100);
      expect((bindings.get('second') as NumberNode).value, 200);
    });
  });
}
