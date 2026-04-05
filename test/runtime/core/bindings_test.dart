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
  });
}
