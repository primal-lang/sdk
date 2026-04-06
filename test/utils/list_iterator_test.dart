@Tags(['unit'])
library;

import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';

void main() {
  group('ListIterator - empty list', () {
    test('hasNext is false', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(iterator.hasNext, false);
    });

    test('isAtEnd is true', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(iterator.isAtEnd, true);
    });

    test('peek returns null', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(iterator.peek, null);
    });

    test('next throws UnexpectedEndOfFileError', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(
        () => iterator.next,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('previous returns null', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(iterator.previous, null);
    });

    test('last throws UnexpectedEndOfFileError', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(
        () => iterator.last,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('back() returns false on empty list', () {
      final ListIterator<int> iterator = ListIterator([]);
      final bool result = iterator.back();
      expect(result, false);
    });

    test('advance() on empty list keeps isAtEnd true', () {
      final ListIterator<int> iterator = ListIterator([]);
      iterator.advance();
      expect(iterator.isAtEnd, true);
      expect(iterator.hasNext, false);
    });

    test('hasNext and isAtEnd are consistent for empty list', () {
      final ListIterator<int> iterator = ListIterator([]);
      expect(iterator.hasNext, false);
      expect(iterator.isAtEnd, true);
      expect(iterator.hasNext, !iterator.isAtEnd);
    });
  });

  group('ListIterator - single element', () {
    test('hasNext is true initially', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.hasNext, true);
    });

    test('isAtEnd is false initially', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.isAtEnd, false);
    });

    test('peek returns element without advancing', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.peek, 42);
      expect(iterator.peek, 42);
      expect(iterator.hasNext, true);
    });

    test('next returns element then hasNext is false', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.next, 42);
      expect(iterator.hasNext, false);
    });

    test('next then next throws', () {
      final ListIterator<int> iterator = ListIterator([42]);
      iterator.next;
      expect(
        () => iterator.next,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('last returns the element', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.last, 42);
    });

    test('last does not affect iterator position', () {
      final ListIterator<int> iterator = ListIterator([42]);
      final int lastValue = iterator.last;
      expect(lastValue, 42);
      expect(iterator.hasNext, true);
      expect(iterator.peek, 42);
    });

    test('previous returns the element after consuming it', () {
      final ListIterator<int> iterator = ListIterator([42]);
      iterator.next;
      expect(iterator.previous, 42);
    });

    test('peek returns null at end after consuming element', () {
      final ListIterator<int> iterator = ListIterator([42]);
      iterator.next;
      expect(iterator.peek, null);
    });

    test('back() returns true after advancing past element', () {
      final ListIterator<int> iterator = ListIterator([42]);
      iterator.advance();
      final bool result = iterator.back();
      expect(result, true);
      expect(iterator.peek, 42);
    });

    test('back() returns false at initial position', () {
      final ListIterator<int> iterator = ListIterator([42]);
      final bool result = iterator.back();
      expect(result, false);
    });

    test('hasNext and isAtEnd are opposites for single element', () {
      final ListIterator<int> iterator = ListIterator([42]);
      expect(iterator.hasNext, true);
      expect(iterator.isAtEnd, false);
      expect(iterator.hasNext, !iterator.isAtEnd);
      iterator.next;
      expect(iterator.hasNext, false);
      expect(iterator.isAtEnd, true);
      expect(iterator.hasNext, !iterator.isAtEnd);
    });
  });

  group('ListIterator - multiple elements', () {
    test('sequential next() returns all elements in order', () {
      final ListIterator<String> iterator = ListIterator(['a', 'b', 'c']);
      expect(iterator.next, 'a');
      expect(iterator.next, 'b');
      expect(iterator.next, 'c');
      expect(iterator.hasNext, false);
    });

    test('last returns last element', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      expect(iterator.last, 3);
    });

    test('last returns same value regardless of iterator position', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      expect(iterator.last, 3);
      iterator.next;
      expect(iterator.last, 3);
      iterator.next;
      expect(iterator.last, 3);
      iterator.next;
      expect(iterator.last, 3);
    });

    test('previous on first element returns null', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      expect(iterator.previous, null);
    });

    test('previous after next returns previous element', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.next;
      expect(iterator.previous, 1);
    });

    test('previous tracks correctly through iteration', () {
      final ListIterator<int> iterator = ListIterator([10, 20, 30]);
      iterator.next;
      iterator.next;
      expect(iterator.previous, 20);
    });

    test('previous at end of list returns last element', () {
      final ListIterator<int> iterator = ListIterator([10, 20, 30]);
      iterator.next;
      iterator.next;
      iterator.next;
      expect(iterator.previous, 30);
    });

    test('peek does not affect previous', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.next;
      final int? peekedValue = iterator.peek;
      expect(peekedValue, 2);
      expect(iterator.previous, 1);
    });

    test('hasNext and isAtEnd remain consistent through iteration', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      for (int i = 0; i < 3; i++) {
        expect(iterator.hasNext, !iterator.isAtEnd);
        iterator.next;
      }
      expect(iterator.hasNext, !iterator.isAtEnd);
    });
  });

  group('ListIterator - advance and back', () {
    test('advance() moves forward without returning', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      expect(iterator.peek, 2);
    });

    test('multiple advance() calls', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      expect(iterator.peek, 3);
    });

    test('back() moves backward', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      iterator.back();
      expect(iterator.peek, 2);
    });

    test('back() after advance() allows re-reading', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      final int? first = iterator.peek;
      iterator.advance();
      iterator.back();
      expect(iterator.peek, first);
    });

    test('advance then next returns correct element', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      expect(iterator.next, 2);
    });

    test('back() at index zero does not go negative', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.back();
      expect(iterator.peek, 1);
      expect(iterator.hasNext, true);
    });

    test('advance() at end does not go past bounds', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      iterator.advance();
      expect(iterator.isAtEnd, true);
      iterator.advance();
      expect(iterator.isAtEnd, true);
      expect(iterator.peek, null);
    });

    test('back() returns true when successful', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      final bool result = iterator.back();
      expect(result, true);
    });

    test('back() returns false when at start', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      final bool result = iterator.back();
      expect(result, false);
    });

    test('multiple back() calls return correct values', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      iterator.advance();

      final bool firstBack = iterator.back();
      expect(firstBack, true);
      expect(iterator.peek, 3);

      final bool secondBack = iterator.back();
      expect(secondBack, true);
      expect(iterator.peek, 2);

      final bool thirdBack = iterator.back();
      expect(thirdBack, true);
      expect(iterator.peek, 1);

      final bool fourthBack = iterator.back();
      expect(fourthBack, false);
      expect(iterator.peek, 1);
    });

    test('back() after next() allows re-reading element', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      final int firstValue = iterator.next;
      expect(firstValue, 1);
      iterator.back();
      expect(iterator.peek, 1);
      expect(iterator.next, 1);
    });

    test('advance() and back() do not affect previous', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      expect(iterator.previous, 1);
      iterator.back();
      expect(iterator.previous, null);
    });
  });

  group('ListIterator - full iteration', () {
    test('iterate through entire list collecting elements', () {
      final ListIterator<int> iterator = ListIterator([10, 20, 30, 40]);
      final List<int> collected = [];
      while (iterator.hasNext) {
        collected.add(iterator.next);
      }
      expect(collected, [10, 20, 30, 40]);
      expect(iterator.isAtEnd, true);
    });

    test('isAtEnd transitions correctly', () {
      final ListIterator<int> iterator = ListIterator([1, 2]);
      expect(iterator.isAtEnd, false);
      iterator.next;
      expect(iterator.isAtEnd, false);
      iterator.next;
      expect(iterator.isAtEnd, true);
    });

    test('can iterate backward after forward iteration', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      while (iterator.hasNext) {
        iterator.advance();
      }
      expect(iterator.isAtEnd, true);

      final List<int> reversed = [];
      while (iterator.back()) {
        reversed.add(iterator.peek!);
      }
      expect(reversed, [3, 2, 1]);
    });

    test('iterate with peek before next', () {
      final ListIterator<String> iterator = ListIterator(['x', 'y', 'z']);
      final List<String> peeked = [];
      final List<String> consumed = [];
      while (iterator.hasNext) {
        peeked.add(iterator.peek!);
        consumed.add(iterator.next);
      }
      expect(peeked, consumed);
      expect(peeked, ['x', 'y', 'z']);
    });
  });

  group('ListIterator - mixed operations', () {
    test('alternating advance and back maintains position', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3, 4, 5]);
      iterator.advance();
      iterator.advance();
      expect(iterator.peek, 3);
      iterator.back();
      expect(iterator.peek, 2);
      iterator.advance();
      expect(iterator.peek, 3);
      iterator.back();
      expect(iterator.peek, 2);
    });

    test('next then back then peek returns same element', () {
      final ListIterator<int> iterator = ListIterator([100, 200, 300]);
      final int consumedValue = iterator.next;
      iterator.back();
      final int? peekedValue = iterator.peek;
      expect(consumedValue, peekedValue);
    });

    test('advance to middle then iterate remaining', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3, 4, 5]);
      iterator.advance();
      iterator.advance();

      final List<int> remaining = [];
      while (iterator.hasNext) {
        remaining.add(iterator.next);
      }
      expect(remaining, [3, 4, 5]);
    });

    test('complex sequence of operations', () {
      final ListIterator<int> iterator = ListIterator([10, 20, 30, 40, 50]);

      expect(iterator.peek, 10);
      expect(iterator.next, 10);
      expect(iterator.previous, 10);

      iterator.advance();
      expect(iterator.peek, 30);
      expect(iterator.previous, 20);

      iterator.back();
      expect(iterator.peek, 20);
      expect(iterator.next, 20);

      iterator.advance();
      iterator.advance();
      expect(iterator.peek, 50);
      expect(iterator.previous, 40);
      expect(iterator.last, 50);

      iterator.next;
      expect(iterator.isAtEnd, true);
      expect(iterator.previous, 50);
    });

    test('last can be called at any point during iteration', () {
      final ListIterator<String> iterator = ListIterator([
        'first',
        'middle',
        'last',
      ]);

      expect(iterator.last, 'last');
      expect(iterator.peek, 'first');

      iterator.next;
      expect(iterator.last, 'last');
      expect(iterator.peek, 'middle');

      iterator.next;
      iterator.next;
      expect(iterator.last, 'last');
      expect(iterator.isAtEnd, true);
    });
  });

  group('ListIterator - generic types', () {
    test('works with String type', () {
      final ListIterator<String> iterator = ListIterator(['hello', 'world']);
      expect(iterator.next, 'hello');
      expect(iterator.next, 'world');
    });

    test('works with double type', () {
      final ListIterator<double> iterator = ListIterator([1.5, 2.5, 3.5]);
      expect(iterator.next, 1.5);
      expect(iterator.peek, 2.5);
      expect(iterator.last, 3.5);
    });

    test('works with bool type', () {
      final ListIterator<bool> iterator = ListIterator([true, false, true]);
      expect(iterator.next, true);
      expect(iterator.next, false);
      expect(iterator.next, true);
    });

    test('works with nullable type containing nulls', () {
      final ListIterator<int?> iterator = ListIterator([1, null, 3]);
      expect(iterator.next, 1);
      expect(iterator.next, null);
      expect(iterator.next, 3);
    });

    test('works with List type', () {
      final ListIterator<List<int>> iterator = ListIterator([
        [1, 2],
        [3, 4],
      ]);
      expect(iterator.next, [1, 2]);
      expect(iterator.next, [3, 4]);
    });

    test('works with Map type', () {
      final ListIterator<Map<String, int>> iterator = ListIterator([
        {'a': 1},
        {'b': 2},
      ]);
      expect(iterator.next, {'a': 1});
      expect(iterator.next, {'b': 2});
    });

    test('works with custom object type', () {
      final _TestObject objectOne = _TestObject('one', 1);
      final _TestObject objectTwo = _TestObject('two', 2);
      final ListIterator<_TestObject> iterator = ListIterator([
        objectOne,
        objectTwo,
      ]);

      final _TestObject first = iterator.next;
      expect(first.name, 'one');
      expect(first.value, 1);

      final _TestObject second = iterator.next;
      expect(second.name, 'two');
      expect(second.value, 2);
    });
  });

  group('ListIterator - edge cases', () {
    test('peek returns null distinguishable from null element', () {
      final ListIterator<int?> iteratorWithNull = ListIterator<int?>([null]);
      expect(iteratorWithNull.hasNext, true);
      expect(iteratorWithNull.peek, null);
      iteratorWithNull.next;
      expect(iteratorWithNull.hasNext, false);
      expect(iteratorWithNull.peek, null);
    });

    test('previous returns null distinguishable from null element', () {
      final ListIterator<int?> iterator = ListIterator<int?>([null, 1]);
      iterator.next;
      expect(iterator.previous, null);
      iterator.next;
      expect(iterator.previous, 1);
    });

    test('large list iteration', () {
      final List<int> largeList = List.generate(1000, (int index) => index);
      final ListIterator<int> iterator = ListIterator(largeList);

      int count = 0;
      while (iterator.hasNext) {
        expect(iterator.next, count);
        count++;
      }
      expect(count, 1000);
      expect(iterator.isAtEnd, true);
    });

    test('back at start multiple times stays at start', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      expect(iterator.back(), false);
      expect(iterator.back(), false);
      expect(iterator.back(), false);
      expect(iterator.peek, 1);
      expect(iterator.hasNext, true);
    });

    test('advance at end multiple times stays at end', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      iterator.advance();
      expect(iterator.isAtEnd, true);
      iterator.advance();
      iterator.advance();
      expect(iterator.isAtEnd, true);
      expect(iterator.peek, null);
      expect(iterator.hasNext, false);
    });

    test('back then advance returns to same position', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.advance();
      iterator.advance();
      final int? positionBefore = iterator.peek;
      iterator.back();
      iterator.advance();
      expect(iterator.peek, positionBefore);
    });

    test('consuming all then backing up allows re-iteration', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);

      final List<int> firstPass = [];
      while (iterator.hasNext) {
        firstPass.add(iterator.next);
      }

      while (iterator.back()) {
        // Back to start
      }

      final List<int> secondPass = [];
      while (iterator.hasNext) {
        secondPass.add(iterator.next);
      }

      expect(firstPass, secondPass);
      expect(firstPass, [1, 2, 3]);
    });
  });

  group('ListIterator - boundary conditions', () {
    test('two element list - all operations', () {
      final ListIterator<int> iterator = ListIterator([1, 2]);

      expect(iterator.peek, 1);
      expect(iterator.previous, null);
      expect(iterator.hasNext, true);
      expect(iterator.isAtEnd, false);
      expect(iterator.last, 2);

      expect(iterator.next, 1);
      expect(iterator.peek, 2);
      expect(iterator.previous, 1);
      expect(iterator.hasNext, true);
      expect(iterator.isAtEnd, false);

      expect(iterator.next, 2);
      expect(iterator.peek, null);
      expect(iterator.previous, 2);
      expect(iterator.hasNext, false);
      expect(iterator.isAtEnd, true);

      expect(iterator.back(), true);
      expect(iterator.peek, 2);
      expect(iterator.hasNext, true);

      expect(iterator.back(), true);
      expect(iterator.peek, 1);

      expect(iterator.back(), false);
      expect(iterator.peek, 1);
    });

    test('iterator state after exception', () {
      final ListIterator<int> iterator = ListIterator([1]);
      iterator.next;

      try {
        iterator.next;
      } on UnexpectedEndOfFileError {
        // Expected exception
      }

      expect(iterator.isAtEnd, true);
      expect(iterator.hasNext, false);
      expect(iterator.peek, null);
      expect(iterator.previous, 1);
      expect(iterator.back(), true);
      expect(iterator.peek, 1);
    });

    test('peek multiple times does not change state', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);

      for (int i = 0; i < 10; i++) {
        expect(iterator.peek, 1);
      }

      expect(iterator.hasNext, true);
      expect(iterator.previous, null);
    });

    test('last multiple times does not change state', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);

      for (int i = 0; i < 10; i++) {
        expect(iterator.last, 3);
      }

      expect(iterator.hasNext, true);
      expect(iterator.peek, 1);
      expect(iterator.previous, null);
    });

    test('previous multiple times returns same value', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      iterator.next;

      for (int i = 0; i < 10; i++) {
        expect(iterator.previous, 1);
      }

      expect(iterator.peek, 2);
    });
  });
}

class _TestObject {
  final String name;
  final int value;

  _TestObject(this.name, this.value);
}
