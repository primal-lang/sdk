@Tags(['runtime'])
library;

import 'dart:io';

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

    test('works with set parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.set('items')],
        arguments: [
          const SetTerm({NumberTerm(1), NumberTerm(2)}),
        ],
      );
      final Term result = bindings.get('items');
      expect(result, isA<SetTerm>());
    });

    test('works with vector parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.vector('items')],
        arguments: [
          const VectorTerm([NumberTerm(1), NumberTerm(2)]),
        ],
      );
      final Term result = bindings.get('items');
      expect(result, isA<VectorTerm>());
    });

    test('works with stack parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.stack('items')],
        arguments: [
          const StackTerm([NumberTerm(1), NumberTerm(2)]),
        ],
      );
      final Term result = bindings.get('items');
      expect(result, isA<StackTerm>());
    });

    test('works with queue parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.queue('items')],
        arguments: [
          const QueueTerm([NumberTerm(1), NumberTerm(2)]),
        ],
      );
      final Term result = bindings.get('items');
      expect(result, isA<QueueTerm>());
    });

    test('works with timestamp parameter', () {
      final DateTime timestamp = DateTime(2024, 1, 15, 10, 30);
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.timestamp('time')],
        arguments: [TimestampTerm(timestamp)],
      );
      final Term result = bindings.get('time');
      expect(result, isA<TimestampTerm>());
      expect((result as TimestampTerm).value, timestamp);
    });

    test('works with file parameter', () {
      final File file = File('/tmp/test.txt');
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.file('path')],
        arguments: [FileTerm(file)],
      );
      final Term result = bindings.get('path');
      expect(result, isA<FileTerm>());
    });

    test('works with directory parameter', () {
      final Directory directory = Directory('/tmp');
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.directory('path')],
        arguments: [DirectoryTerm(directory)],
      );
      final Term result = bindings.get('path');
      expect(result, isA<DirectoryTerm>());
    });

    test('works with ordered parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.ordered('value')],
        arguments: [const NumberTerm(42)],
      );
      final Term result = bindings.get('value');
      expect(result, isA<NumberTerm>());
    });

    test('works with equatable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.equatable('value')],
        arguments: [const StringTerm('hello')],
      );
      final Term result = bindings.get('value');
      expect(result, isA<StringTerm>());
    });

    test('works with hashable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.hashable('value')],
        arguments: [const NumberTerm(42)],
      );
      final Term result = bindings.get('value');
      expect(result, isA<NumberTerm>());
    });

    test('works with indexable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.indexable('value')],
        arguments: [
          const ListTerm([NumberTerm(1)]),
        ],
      );
      final Term result = bindings.get('value');
      expect(result, isA<ListTerm>());
    });

    test('works with collection parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.collection('value')],
        arguments: [
          const ListTerm([NumberTerm(1)]),
        ],
      );
      final Term result = bindings.get('value');
      expect(result, isA<ListTerm>());
    });

    test('works with iterable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.iterable('value')],
        arguments: [
          const ListTerm([NumberTerm(1)]),
        ],
      );
      final Term result = bindings.get('value');
      expect(result, isA<ListTerm>());
    });

    test('works with addable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.addable('value')],
        arguments: [const NumberTerm(5)],
      );
      final Term result = bindings.get('value');
      expect(result, isA<NumberTerm>());
    });

    test('works with subtractable parameter', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.subtractable('value')],
        arguments: [const NumberTerm(10)],
      );
      final Term result = bindings.get('value');
      expect(result, isA<NumberTerm>());
    });
  });

  group('Bindings with additional term types', () {
    test('works with VectorTerm', () {
      const Bindings bindings = Bindings({
        'vector': VectorTerm([NumberTerm(1), NumberTerm(2), NumberTerm(3)]),
      });
      final Term result = bindings.get('vector');
      expect(result, isA<VectorTerm>());
      expect((result as VectorTerm).value.length, 3);
    });

    test('works with StackTerm', () {
      const Bindings bindings = Bindings({
        'stack': StackTerm([NumberTerm(1), NumberTerm(2)]),
      });
      final Term result = bindings.get('stack');
      expect(result, isA<StackTerm>());
      expect((result as StackTerm).value.length, 2);
    });

    test('works with QueueTerm', () {
      const Bindings bindings = Bindings({
        'queue': QueueTerm([NumberTerm(1), NumberTerm(2)]),
      });
      final Term result = bindings.get('queue');
      expect(result, isA<QueueTerm>());
      expect((result as QueueTerm).value.length, 2);
    });

    test('works with TimestampTerm', () {
      final DateTime timestamp = DateTime(2024, 1, 15, 10, 30, 45);
      final Bindings bindings = Bindings({
        'timestamp': TimestampTerm(timestamp),
      });
      final Term result = bindings.get('timestamp');
      expect(result, isA<TimestampTerm>());
      expect((result as TimestampTerm).value, timestamp);
    });

    test('works with FileTerm', () {
      final File file = File('/tmp/test.txt');
      final Bindings bindings = Bindings({
        'file': FileTerm(file),
      });
      final Term result = bindings.get('file');
      expect(result, isA<FileTerm>());
      expect((result as FileTerm).value.path, '/tmp/test.txt');
    });

    test('works with DirectoryTerm', () {
      final Directory directory = Directory('/tmp');
      final Bindings bindings = Bindings({
        'directory': DirectoryTerm(directory),
      });
      final Term result = bindings.get('directory');
      expect(result, isA<DirectoryTerm>());
      expect((result as DirectoryTerm).value.path, '/tmp');
    });

    test('works with BoundVariableTerm', () {
      const Bindings bindings = Bindings({
        'boundVariable': BoundVariableTerm('x'),
      });
      final Term result = bindings.get('boundVariable');
      expect(result, isA<BoundVariableTerm>());
      expect((result as BoundVariableTerm).name, 'x');
    });

    test('works with nested ListTerm', () {
      const Bindings bindings = Bindings({
        'nested': ListTerm([
          ListTerm([NumberTerm(1), NumberTerm(2)]),
          ListTerm([NumberTerm(3), NumberTerm(4)]),
        ]),
      });
      final Term result = bindings.get('nested');
      expect(result, isA<ListTerm>());
      final ListTerm listTerm = result as ListTerm;
      expect(listTerm.value.length, 2);
      expect(listTerm.value[0], isA<ListTerm>());
    });

    test('works with nested MapTerm', () {
      const Bindings bindings = Bindings({
        'nested': MapTerm({
          StringTerm('outer'): MapTerm({
            StringTerm('inner'): NumberTerm(42),
          }),
        }),
      });
      final Term result = bindings.get('nested');
      expect(result, isA<MapTerm>());
    });

    test('works with empty ListTerm', () {
      const Bindings bindings = Bindings({
        'emptyList': ListTerm([]),
      });
      final Term result = bindings.get('emptyList');
      expect(result, isA<ListTerm>());
      expect((result as ListTerm).value, isEmpty);
    });

    test('works with empty SetTerm', () {
      const Bindings bindings = Bindings({
        'emptySet': SetTerm({}),
      });
      final Term result = bindings.get('emptySet');
      expect(result, isA<SetTerm>());
      expect((result as SetTerm).value, isEmpty);
    });

    test('works with empty MapTerm', () {
      const Bindings bindings = Bindings({
        'emptyMap': MapTerm({}),
      });
      final Term result = bindings.get('emptyMap');
      expect(result, isA<MapTerm>());
      expect((result as MapTerm).value, isEmpty);
    });
  });

  group('Bindings edge cases for key names', () {
    test('works with empty string key', () {
      const Bindings bindings = Bindings({
        '': NumberTerm(42),
      });
      final Term result = bindings.get('');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('works with whitespace key', () {
      const Bindings bindings = Bindings({
        '   ': NumberTerm(42),
      });
      final Term result = bindings.get('   ');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('works with unicode key', () {
      const Bindings bindings = Bindings({
        '\u03B1\u03B2\u03B3': NumberTerm(42),
      });
      final Term result = bindings.get('\u03B1\u03B2\u03B3');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('works with emoji key', () {
      const Bindings bindings = Bindings({
        '\u{1F600}': NumberTerm(42),
      });
      final Term result = bindings.get('\u{1F600}');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('works with very long key name', () {
      final String longKey = 'a' * 1000;
      final Bindings bindings = Bindings({
        longKey: const NumberTerm(42),
      });
      final Term result = bindings.get(longKey);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('distinguishes similar keys correctly', () {
      const Bindings bindings = Bindings({
        'abc': NumberTerm(1),
        'ABC': NumberTerm(2),
        'Abc': NumberTerm(3),
      });
      expect((bindings.get('abc') as NumberTerm).value, 1);
      expect((bindings.get('ABC') as NumberTerm).value, 2);
      expect((bindings.get('Abc') as NumberTerm).value, 3);
    });

    test('works with special characters in key', () {
      const Bindings bindings = Bindings({
        'key-with-dashes': NumberTerm(1),
        'key_with_underscores': NumberTerm(2),
        'key.with.dots': NumberTerm(3),
        'key/with/slashes': NumberTerm(4),
      });
      expect((bindings.get('key-with-dashes') as NumberTerm).value, 1);
      expect((bindings.get('key_with_underscores') as NumberTerm).value, 2);
      expect((bindings.get('key.with.dots') as NumberTerm).value, 3);
      expect((bindings.get('key/with/slashes') as NumberTerm).value, 4);
    });

    test('works with newline in key', () {
      const Bindings bindings = Bindings({
        'key\nwith\nnewlines': NumberTerm(42),
      });
      final Term result = bindings.get('key\nwith\nnewlines');
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });
  });

  group('Bindings stress tests', () {
    test('handles large number of bindings', () {
      final Map<String, Term> data = {};
      for (int index = 0; index < 10000; index++) {
        data['key$index'] = NumberTerm(index);
      }
      final Bindings bindings = Bindings(data);
      expect(bindings.data.length, 10000);
      expect((bindings.get('key0') as NumberTerm).value, 0);
      expect((bindings.get('key9999') as NumberTerm).value, 9999);
      expect((bindings.get('key5000') as NumberTerm).value, 5000);
    });

    test('Bindings.from handles large number of parameters', () {
      final List<Parameter> parameters = [];
      final List<Term> arguments = [];
      for (int index = 0; index < 1000; index++) {
        parameters.add(Parameter.number('param$index'));
        arguments.add(NumberTerm(index));
      }
      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: arguments,
      );
      expect(bindings.data.length, 1000);
      expect((bindings.get('param0') as NumberTerm).value, 0);
      expect((bindings.get('param999') as NumberTerm).value, 999);
    });
  });

  group('Bindings error handling', () {
    test('NotFoundInScopeError contains variable name', () {
      const Bindings bindings = Bindings({'x': NumberTerm(42)});
      try {
        bindings.get('nonexistent');
        fail('Expected NotFoundInScopeError to be thrown');
      } on NotFoundInScopeError catch (error) {
        expect(error.toString(), contains('nonexistent'));
      }
    });

    test('NotFoundInScopeError for key similar to existing key', () {
      const Bindings bindings = Bindings({'myVariable': NumberTerm(42)});
      expect(
        () => bindings.get('myvariable'),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('NotFoundInScopeError for key with extra whitespace', () {
      const Bindings bindings = Bindings({'key': NumberTerm(42)});
      expect(
        () => bindings.get(' key'),
        throwsA(isA<NotFoundInScopeError>()),
      );
      expect(
        () => bindings.get('key '),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });
  });

  group('Bindings value edge cases', () {
    test('works with zero number', () {
      const Bindings bindings = Bindings({'zero': NumberTerm(0)});
      final Term result = bindings.get('zero');
      expect((result as NumberTerm).value, 0);
    });

    test('works with negative number', () {
      const Bindings bindings = Bindings({'negative': NumberTerm(-42)});
      final Term result = bindings.get('negative');
      expect((result as NumberTerm).value, -42);
    });

    test('works with decimal number', () {
      const Bindings bindings = Bindings({'decimal': NumberTerm(3.14159)});
      final Term result = bindings.get('decimal');
      expect((result as NumberTerm).value, 3.14159);
    });

    test('works with very large number', () {
      const Bindings bindings = Bindings({
        'large': NumberTerm(9007199254740991),
      });
      final Term result = bindings.get('large');
      expect((result as NumberTerm).value, 9007199254740991);
    });

    test('works with very small number', () {
      const Bindings bindings = Bindings({
        'small': NumberTerm(0.0000000001),
      });
      final Term result = bindings.get('small');
      expect((result as NumberTerm).value, 0.0000000001);
    });

    test('works with empty string value', () {
      const Bindings bindings = Bindings({'empty': StringTerm('')});
      final Term result = bindings.get('empty');
      expect((result as StringTerm).value, '');
    });

    test('works with false boolean', () {
      const Bindings bindings = Bindings({'bool': BooleanTerm(false)});
      final Term result = bindings.get('bool');
      expect((result as BooleanTerm).value, false);
    });

    test('works with special float values', () {
      const Bindings bindings = Bindings({
        'infinity': NumberTerm(double.infinity),
        'negInfinity': NumberTerm(double.negativeInfinity),
      });
      expect(
        (bindings.get('infinity') as NumberTerm).value,
        double.infinity,
      );
      expect(
        (bindings.get('negInfinity') as NumberTerm).value,
        double.negativeInfinity,
      );
    });

    test('works with NaN', () {
      const Bindings bindings = Bindings({'nan': NumberTerm(double.nan)});
      final Term result = bindings.get('nan');
      expect((result as NumberTerm).value.isNaN, true);
    });
  });

  group('Bindings.from() edge cases', () {
    test('single parameter and argument', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.number('x')],
        arguments: [const NumberTerm(42)],
      );
      expect(bindings.data.length, 1);
      expect((bindings.get('x') as NumberTerm).value, 42);
    });

    test('preserves argument order with many parameters', () {
      final Bindings bindings = Bindings.from(
        parameters: [
          const Parameter.number('first'),
          const Parameter.string('second'),
          const Parameter.boolean('third'),
          const Parameter.list('fourth'),
          const Parameter.map('fifth'),
        ],
        arguments: [
          const NumberTerm(1),
          const StringTerm('two'),
          const BooleanTerm(true),
          const ListTerm([NumberTerm(4)]),
          const MapTerm({StringTerm('key'): NumberTerm(5)}),
        ],
      );
      expect((bindings.get('first') as NumberTerm).value, 1);
      expect((bindings.get('second') as StringTerm).value, 'two');
      expect((bindings.get('third') as BooleanTerm).value, true);
      expect((bindings.get('fourth') as ListTerm).value.length, 1);
      expect((bindings.get('fifth') as MapTerm).value.length, 1);
    });

    test('parameter with reserved-like name', () {
      final Bindings bindings = Bindings.from(
        parameters: [const Parameter.number('if')],
        arguments: [const NumberTerm(42)],
      );
      expect((bindings.get('if') as NumberTerm).value, 42);
    });

    test('all parameters with same type', () {
      final Bindings bindings = Bindings.from(
        parameters: [
          const Parameter.number('a'),
          const Parameter.number('b'),
          const Parameter.number('c'),
        ],
        arguments: [
          const NumberTerm(1),
          const NumberTerm(2),
          const NumberTerm(3),
        ],
      );
      expect((bindings.get('a') as NumberTerm).value, 1);
      expect((bindings.get('b') as NumberTerm).value, 2);
      expect((bindings.get('c') as NumberTerm).value, 3);
    });
  });
}
