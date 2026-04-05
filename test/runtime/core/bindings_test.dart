@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:test/test.dart';

void main() {
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
        parameters: [const Parameter.number('x')],
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
          const Parameter.number('a'),
          const Parameter.string('b'),
          const Parameter.boolean('c'),
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
        parameters: [
          const Parameter.number('first'),
          const Parameter.number('second'),
        ],
        arguments: [const NumberNode(100), const NumberNode(200)],
      );
      expect((bindings.get('first') as NumberNode).value, 100);
      expect((bindings.get('second') as NumberNode).value, 200);
    });
  });
}
