@Tags(['unit'])
library;

import 'package:primal/utils/stack.dart';
import 'package:test/test.dart';

void main() {
  group('Stack', () {
    test('empty stack has length 0', () {
      final Stack<int> stack = Stack();
      expect(stack.length, 0);
    });

    test('empty stack isEmpty is true', () {
      final Stack<int> stack = Stack();
      expect(stack.isEmpty, true);
    });

    test('empty stack isNotEmpty is false', () {
      final Stack<int> stack = Stack();
      expect(stack.isNotEmpty, false);
    });

    test('push returns new stack with element added', () {
      final Stack<int> stack = Stack();
      final Stack<int> result = stack.push(42);
      expect(result.length, 1);
      expect(result.peek, 42);
    });

    test('push does not modify original stack', () {
      final Stack<int> stack = Stack();
      stack.push(42);
      expect(stack.length, 0);
    });

    test('push multiple elements maintains LIFO order', () {
      final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
      expect(stack.peek, 3);
      expect(stack.length, 3);
    });

    test('pop returns last pushed element and new stack', () {
      final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
      final (int value, Stack<int> newStack) = stack.pop();
      expect(value, 3);
      expect(newStack.length, 2);
      expect(newStack.peek, 2);
    });

    test('pop does not modify original stack', () {
      final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
      stack.pop();
      expect(stack.length, 3);
      expect(stack.peek, 3);
    });

    test('peek returns last element without removing', () {
      final Stack<int> stack = Stack<int>().push(1).push(2);
      expect(stack.peek, 2);
      expect(stack.length, 2);
    });

    test('peek on empty stack throws StateError', () {
      final Stack<int> stack = Stack();
      expect(() => stack.peek, throwsStateError);
    });

    test('pop on empty stack throws StateError', () {
      final Stack<int> stack = Stack();
      expect(stack.pop, throwsStateError);
    });

    test('isNotEmpty is true after push', () {
      final Stack<int> stack = Stack<int>().push(1);
      expect(stack.isNotEmpty, true);
    });

    test('stack works with string type', () {
      final Stack<String> stack = Stack<String>().push('a').push('b');
      expect(stack.peek, 'b');
      expect(stack.length, 2);
    });
  });
}
