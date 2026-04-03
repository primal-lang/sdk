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
  });
}
