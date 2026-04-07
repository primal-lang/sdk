@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:test/test.dart';

void main() {
  group('Bindings', () {
    test('get existing key returns term', () {
      const Bindings bindings = Bindings({'x': NumberTerm(42)});
      final Term result = bindings.get('x');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('get missing key throws NotFoundInScopeError', () {
      const Bindings bindings = Bindings({'x': NumberTerm(42)});
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
        'a': NumberTerm(1),
        'b': StringTerm('two'),
        'c': BooleanTerm(true),
      });
      expect((bindings.get('a') as NumberTerm).value, 1);
      expect((bindings.get('b') as StringTerm).value, 'two');
      expect((bindings.get('c') as BooleanTerm).value, true);
    });
  });

  group('Bindings.from()', () {
    test('creates from parameters and arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.number('x')],
        arguments: [const NumberTerm(10)],
      );
      final Term result = bindings.get('x');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 10);
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
          const NumberTerm(1),
          const StringTerm('hello'),
          const BooleanTerm(true),
        ],
      );
      expect((bindings.get('a') as NumberTerm).value, 1);
      expect((bindings.get('b') as StringTerm).value, 'hello');
      expect((bindings.get('c') as BooleanTerm).value, true);
    });

    test('parameter names map correctly to arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [
          const Parameter.number('first'),
          const Parameter.number('second'),
        ],
        arguments: [const NumberTerm(100), const NumberTerm(200)],
      );
      expect((bindings.get('first') as NumberTerm).value, 100);
      expect((bindings.get('second') as NumberTerm).value, 200);
    });

    test('fewer arguments than parameters throws RangeError', () {
      expect(
        () => Bindings.from(
          parameters: [
            const Parameter.number('a'),
            const Parameter.number('b'),
          ],
          arguments: [const NumberTerm(1)],
        ),
        throwsRangeError,
      );
    });

    test('more arguments than parameters ignores extra arguments', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.number('a')],
        arguments: [
          const NumberTerm(1),
          const NumberTerm(2),
          const NumberTerm(3),
        ],
      );
      expect(bindings.data.length, 1);
      expect((bindings.get('a') as NumberTerm).value, 1);
    });

    test('duplicate parameter names use last value', () {
      final Bindings bindings = Bindings.from(
        parameters: [
          const Parameter.number('x'),
          const Parameter.number('x'),
        ],
        arguments: [const NumberTerm(1), const NumberTerm(2)],
      );
      expect(bindings.data.length, 1);
      expect((bindings.get('x') as NumberTerm).value, 2);
    });
  });

  group('Bindings data field', () {
    test('data field returns the underlying map', () {
      const Bindings bindings = Bindings({
        'a': NumberTerm(1),
        'b': StringTerm('two'),
      });
      expect(bindings.data, isA<Map<String, Term>>());
      expect(bindings.data.length, 2);
      expect(bindings.data.containsKey('a'), true);
      expect(bindings.data.containsKey('b'), true);
    });

    test('data field for empty bindings returns empty map', () {
      const Bindings bindings = Bindings({});
      expect(bindings.data, isEmpty);
    });
  });

  group('Bindings with various term types', () {
    test('works with ListTerm', () {
      const Bindings bindings = Bindings({
        'list': ListTerm([NumberTerm(1), NumberTerm(2)]),
      });
      final Term result = bindings.get('list');
      expect(result, isA<ListTerm>());
      expect((result as ListTerm).value.length, 2);
    });

    test('works with MapTerm', () {
      const Bindings bindings = Bindings({
        'map': MapTerm({StringTerm('key'): NumberTerm(42)}),
      });
      final Term result = bindings.get('map');
      expect(result, isA<MapTerm>());
    });

    test('works with SetTerm', () {
      const Bindings bindings = Bindings({
        'set': SetTerm({NumberTerm(1), NumberTerm(2)}),
      });
      final Term result = bindings.get('set');
      expect(result, isA<SetTerm>());
    });

    test('works with mixed term types', () {
      const Bindings bindings = Bindings({
        'number': NumberTerm(42),
        'string': StringTerm('hello'),
        'boolean': BooleanTerm(true),
        'list': ListTerm([NumberTerm(1)]),
      });
      expect(bindings.get('number'), isA<NumberTerm>());
      expect(bindings.get('string'), isA<StringTerm>());
      expect(bindings.get('boolean'), isA<BooleanTerm>());
      expect(bindings.get('list'), isA<ListTerm>());
    });
  });

  group('Bindings.from() with various parameter types', () {
    test('works with list parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.list('items')],
        arguments: [
          const ListTerm([NumberTerm(1), NumberTerm(2)]),
        ],
      );
      final Term result = bindings.get('items');
      expect(result, isA<ListTerm>());
    });

    test('works with map parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.map('data')],
        arguments: [
          const MapTerm({StringTerm('key'): NumberTerm(1)}),
        ],
      );
      final Term result = bindings.get('data');
      expect(result, isA<MapTerm>());
    });

    test('works with any parameter type', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.any('value')],
        arguments: [const NumberTerm(42)],
      );
      final Term result = bindings.get('value');
      expect(result, isA<NumberTerm>());
    });

    test('works with function parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.function('callback')],
        arguments: [const BooleanTerm(true)],
      );
      final Term result = bindings.get('callback');
      expect(result, isA<BooleanTerm>());
    });
  });
}
