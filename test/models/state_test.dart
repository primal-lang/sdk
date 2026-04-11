@Tags(['unit'])
library;

import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    group('constructor', () {
      test('creates state with iterator and output', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'output');
        expect(state.iterator, same(iterator));
        expect(state.output, equals('output'));
      });

      test('creates state with empty iterator', () {
        final ListIterator<int> iterator = ListIterator([]);
        final State<int, String> state = State(iterator, 'empty');
        expect(state.iterator, same(iterator));
        expect(state.output, equals('empty'));
      });

      test('creates state with null output', () {
        final ListIterator<int> iterator = ListIterator([1]);
        final State<int, String?> state = State(iterator, null);
        expect(state.iterator, same(iterator));
        expect(state.output, isNull);
      });

      test('creates state with single-element iterator', () {
        final ListIterator<int> iterator = ListIterator([42]);
        final State<int, int> state = State(iterator, 0);
        expect(state.iterator, same(iterator));
        expect(state.output, equals(0));
      });
    });

    group('output', () {
      test('returns the output value', () {
        final ListIterator<String> iterator = ListIterator(['a', 'b']);
        final State<String, int> state = State(iterator, 100);
        expect(state.output, equals(100));
      });

      test('returns complex output type', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final List<String> outputList = ['x', 'y', 'z'];
        final State<int, List<String>> state = State(iterator, outputList);
        expect(state.output, same(outputList));
      });
    });

    group('iterator', () {
      test('returns the iterator instance', () {
        final ListIterator<double> iterator = ListIterator([1.0, 2.0]);
        final State<double, String> state = State(iterator, 'test');
        expect(state.iterator, same(iterator));
      });

      test('iterator state is preserved', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        iterator.next; // advance to index 1
        final State<int, String> state = State(iterator, 'test');
        expect(state.iterator.peek, equals(2));
      });
    });

    group('process', () {
      test('default process returns itself', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'output');
        final State<dynamic, dynamic> result = state.process(42);
        expect(result, same(state));
      });

      test('process with different input types returns itself', () {
        final ListIterator<String> iterator = ListIterator(['a', 'b']);
        final State<String, int> state = State(iterator, 10);
        final State<dynamic, dynamic> result = state.process('test');
        expect(result, same(state));
      });

      test('process does not modify iterator', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'output');
        state.process(99);
        expect(iterator.peek, equals(1));
      });

      test('process does not modify output', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'original');
        state.process(99);
        expect(state.output, equals('original'));
      });
    });

    group('next', () {
      test('advances iterator and returns result of process', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'output');
        final State<dynamic, dynamic> result = state.next;
        expect(result, same(state));
        expect(iterator.peek, equals(2));
      });

      test('next consumes first element from iterator', () {
        final ListIterator<int> iterator = ListIterator([10, 20, 30]);
        final State<int, String> state = State(iterator, 'test');
        state.next;
        expect(iterator.peek, equals(20));
      });

      test('next on single-element iterator advances to end', () {
        final ListIterator<int> iterator = ListIterator([42]);
        final State<int, String> state = State(iterator, 'single');
        state.next;
        expect(iterator.hasNext, isFalse);
        expect(iterator.isAtEnd, isTrue);
      });

      test('multiple next calls advance through iterator', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, String> state = State(iterator, 'output');
        state.next;
        expect(iterator.peek, equals(2));
        state.next;
        expect(iterator.peek, equals(3));
        state.next;
        expect(iterator.hasNext, isFalse);
      });

      test('next on empty iterator throws UnexpectedEndOfFileError', () {
        final ListIterator<int> iterator = ListIterator([]);
        final State<int, String> state = State(iterator, 'empty');
        expect(() => state.next, throwsA(isA<UnexpectedEndOfFileError>()));
      });

      test('next at end of iterator throws UnexpectedEndOfFileError', () {
        final ListIterator<int> iterator = ListIterator([1]);
        final State<int, String> state = State(iterator, 'output');
        state.next; // consume the only element
        expect(() => state.next, throwsA(isA<UnexpectedEndOfFileError>()));
      });
    });

    group('generic types', () {
      test('works with complex input type', () {
        final ListIterator<List<int>> iterator = ListIterator([
          [1, 2],
          [3, 4],
        ]);
        final State<List<int>, String> state = State(iterator, 'complex');
        expect(state.output, equals('complex'));
        state.next;
        expect(iterator.peek, equals([3, 4]));
      });

      test('works with complex output type', () {
        final ListIterator<int> iterator = ListIterator([1, 2]);
        final Map<String, int> outputMap = {'a': 1, 'b': 2};
        final State<int, Map<String, int>> state = State(iterator, outputMap);
        expect(state.output, same(outputMap));
      });

      test('works with void output type', () {
        final ListIterator<int> iterator = ListIterator([1, 2, 3]);
        final State<int, void> state = State(iterator, null);
        expect(state.iterator, same(iterator));
      });
    });
  });
}
