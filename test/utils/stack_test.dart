@Tags(['unit'])
library;

import 'package:primal/utils/stack.dart';
import 'package:test/test.dart';

void main() {
  group('Stack', () {
    group('constructor', () {
      test('empty stack has length 0', () {
        final Stack<int> stack = Stack();
        expect(stack.length, 0);
      });

      test(
        'constructor with initial list creates stack with those elements',
        () {
          final Stack<int> stack = Stack([1, 2, 3]);
          expect(stack.length, 3);
          expect(stack.peek, 3);
        },
      );

      test('constructor with empty list creates empty stack', () {
        final Stack<int> stack = Stack([]);
        expect(stack.length, 0);
        expect(stack.isEmpty, true);
      });

      test(
        'constructor with single element list creates single element stack',
        () {
          final Stack<int> stack = Stack([42]);
          expect(stack.length, 1);
          expect(stack.peek, 42);
        },
      );
    });

    group('isEmpty', () {
      test('empty stack isEmpty is true', () {
        final Stack<int> stack = Stack();
        expect(stack.isEmpty, true);
      });

      test('non-empty stack isEmpty is false', () {
        final Stack<int> stack = Stack<int>().push(1);
        expect(stack.isEmpty, false);
      });

      test('isEmpty is true after popping last element', () {
        final Stack<int> stack = Stack<int>().push(1);
        final (int _, Stack<int> emptyStack) = stack.pop();
        expect(emptyStack.isEmpty, true);
      });

      test('isEmpty is false after popping non-last element', () {
        final Stack<int> stack = Stack<int>().push(1).push(2);
        final (int _, Stack<int> remainingStack) = stack.pop();
        expect(remainingStack.isEmpty, false);
      });
    });

    group('isNotEmpty', () {
      test('empty stack isNotEmpty is false', () {
        final Stack<int> stack = Stack();
        expect(stack.isNotEmpty, false);
      });

      test('isNotEmpty is true after push', () {
        final Stack<int> stack = Stack<int>().push(1);
        expect(stack.isNotEmpty, true);
      });

      test('isNotEmpty is false after popping last element', () {
        final Stack<int> stack = Stack<int>().push(1);
        final (int _, Stack<int> emptyStack) = stack.pop();
        expect(emptyStack.isNotEmpty, false);
      });

      test('isNotEmpty is true after popping non-last element', () {
        final Stack<int> stack = Stack<int>().push(1).push(2);
        final (int _, Stack<int> remainingStack) = stack.pop();
        expect(remainingStack.isNotEmpty, true);
      });
    });

    group('length', () {
      test('length is 0 for empty stack', () {
        final Stack<int> stack = Stack();
        expect(stack.length, 0);
      });

      test('length increases by 1 after each push', () {
        final Stack<int> stack1 = Stack<int>().push(1);
        expect(stack1.length, 1);

        final Stack<int> stack2 = stack1.push(2);
        expect(stack2.length, 2);

        final Stack<int> stack3 = stack2.push(3);
        expect(stack3.length, 3);
      });

      test('length decreases by 1 after each pop', () {
        final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
        expect(stack.length, 3);

        final (int _, Stack<int> stack2) = stack.pop();
        expect(stack2.length, 2);

        final (int _, Stack<int> stack1) = stack2.pop();
        expect(stack1.length, 1);

        final (int _, Stack<int> stack0) = stack1.pop();
        expect(stack0.length, 0);
      });

      test('length matches initial list length', () {
        final Stack<int> stack = Stack([1, 2, 3, 4, 5]);
        expect(stack.length, 5);
      });
    });

    group('push', () {
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

      test('push onto non-empty stack adds to top', () {
        final Stack<int> stack = Stack([1, 2]);
        final Stack<int> result = stack.push(3);
        expect(result.peek, 3);
        expect(result.length, 3);
      });

      test('push null value for nullable type', () {
        final Stack<int?> stack = Stack<int?>().push(null);
        expect(stack.length, 1);
        expect(stack.peek, null);
      });

      test('push after pop works correctly', () {
        final Stack<int> stack = Stack<int>().push(1).push(2);
        final (int _, Stack<int> poppedStack) = stack.pop();
        final Stack<int> result = poppedStack.push(3);
        expect(result.peek, 3);
        expect(result.length, 2);
      });

      test('chained push operations create correct stack', () {
        final Stack<int> stack = Stack<int>()
            .push(1)
            .push(2)
            .push(3)
            .push(4)
            .push(5);
        expect(stack.length, 5);
        expect(stack.peek, 5);
      });
    });

    group('pop', () {
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

      test('pop on empty stack throws StateError', () {
        final Stack<int> stack = Stack();
        expect(stack.pop, throwsStateError);
      });

      test('pop on empty stack throws error with descriptive message', () {
        final Stack<int> stack = Stack();
        expect(
          stack.pop,
          throwsA(
            isA<StateError>().having(
              (StateError error) => error.message,
              'message',
              'Cannot pop from an empty stack',
            ),
          ),
        );
      });

      test('pop single element stack returns that element and empty stack', () {
        final Stack<int> stack = Stack<int>().push(42);
        final (int value, Stack<int> newStack) = stack.pop();
        expect(value, 42);
        expect(newStack.isEmpty, true);
        expect(newStack.length, 0);
      });

      test('pop all elements returns them in LIFO order', () {
        final Stack<int> stack = Stack<int>().push(1).push(2).push(3);

        final (int value1, Stack<int> stack1) = stack.pop();
        expect(value1, 3);

        final (int value2, Stack<int> stack2) = stack1.pop();
        expect(value2, 2);

        final (int value3, Stack<int> stack3) = stack2.pop();
        expect(value3, 1);

        expect(stack3.isEmpty, true);
      });

      test('pop returns null for nullable type with null value', () {
        final Stack<int?> stack = Stack<int?>().push(1).push(null).push(3);
        final (int? value1, Stack<int?> stack1) = stack.pop();
        expect(value1, 3);

        final (int? value2, Stack<int?> stack2) = stack1.pop();
        expect(value2, null);

        final (int? value3, Stack<int?> _) = stack2.pop();
        expect(value3, 1);
      });

      test('multiple pops from same stack return same result', () {
        final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
        final (int value1, Stack<int> newStack1) = stack.pop();
        final (int value2, Stack<int> newStack2) = stack.pop();
        expect(value1, value2);
        expect(newStack1.length, newStack2.length);
        expect(newStack1.peek, newStack2.peek);
      });

      test('pop from stack created with initial list', () {
        final Stack<int> stack = Stack([1, 2, 3]);
        final (int value, Stack<int> newStack) = stack.pop();
        expect(value, 3);
        expect(newStack.length, 2);
        expect(newStack.peek, 2);
      });
    });

    group('peek', () {
      test('peek returns last element without removing', () {
        final Stack<int> stack = Stack<int>().push(1).push(2);
        expect(stack.peek, 2);
        expect(stack.length, 2);
      });

      test('peek on empty stack throws StateError', () {
        final Stack<int> stack = Stack();
        expect(() => stack.peek, throwsStateError);
      });

      test('peek on empty stack throws error with descriptive message', () {
        final Stack<int> stack = Stack();
        expect(
          () => stack.peek,
          throwsA(
            isA<StateError>().having(
              (StateError error) => error.message,
              'message',
              'Cannot peek an empty stack',
            ),
          ),
        );
      });

      test('peek returns same value on consecutive calls', () {
        final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
        expect(stack.peek, 3);
        expect(stack.peek, 3);
        expect(stack.peek, 3);
        expect(stack.length, 3);
      });

      test('peek on single element stack returns that element', () {
        final Stack<int> stack = Stack<int>().push(42);
        expect(stack.peek, 42);
      });

      test('peek returns null for nullable type with null on top', () {
        final Stack<int?> stack = Stack<int?>().push(1).push(null);
        expect(stack.peek, null);
      });

      test('peek does not modify stack', () {
        final Stack<int> stack = Stack<int>().push(1).push(2);
        final int peekValue = stack.peek;
        expect(peekValue, 2);
        expect(stack.length, 2);
        expect(stack.peek, 2);
      });

      test('peek on stack created with initial list returns last element', () {
        final Stack<int> stack = Stack([10, 20, 30]);
        expect(stack.peek, 30);
      });
    });

    group('immutability', () {
      test('original stack unchanged after push', () {
        final Stack<int> original = Stack<int>().push(1);
        final Stack<int> afterPush = original.push(2);
        expect(original.length, 1);
        expect(original.peek, 1);
        expect(afterPush.length, 2);
        expect(afterPush.peek, 2);
      });

      test('original stack unchanged after pop', () {
        final Stack<int> original = Stack<int>().push(1).push(2);
        final (int _, Stack<int> afterPop) = original.pop();
        expect(original.length, 2);
        expect(original.peek, 2);
        expect(afterPop.length, 1);
        expect(afterPop.peek, 1);
      });

      test('multiple branches from same stack are independent', () {
        final Stack<int> base = Stack<int>().push(1);
        final Stack<int> branch1 = base.push(2);
        final Stack<int> branch2 = base.push(3);

        expect(base.length, 1);
        expect(base.peek, 1);

        expect(branch1.length, 2);
        expect(branch1.peek, 2);

        expect(branch2.length, 2);
        expect(branch2.peek, 3);
      });

      test('pop branches are independent', () {
        final Stack<int> stack = Stack<int>().push(1).push(2).push(3);
        final (int value1, Stack<int> popped1) = stack.pop();
        final (int value2, Stack<int> popped2) = stack.pop();

        expect(value1, 3);
        expect(value2, 3);
        expect(popped1.peek, popped2.peek);
        expect(stack.length, 3);
      });
    });

    group('type safety', () {
      test('stack works with String type', () {
        final Stack<String> stack = Stack<String>().push('a').push('b');
        expect(stack.peek, 'b');
        expect(stack.length, 2);
      });

      test('stack works with double type', () {
        final Stack<double> stack = Stack<double>()
            .push(1.5)
            .push(2.5)
            .push(3.5);
        expect(stack.peek, 3.5);
        expect(stack.length, 3);
      });

      test('stack works with bool type', () {
        final Stack<bool> stack = Stack<bool>().push(true).push(false);
        expect(stack.peek, false);
        expect(stack.length, 2);
      });

      test('stack works with nullable type', () {
        final Stack<String?> stack = Stack<String?>()
            .push('hello')
            .push(null)
            .push('world');
        expect(stack.peek, 'world');
        expect(stack.length, 3);

        final (String? value, Stack<String?> remaining) = stack.pop();
        expect(value, 'world');
        expect(remaining.peek, null);
      });

      test('stack works with List type', () {
        final Stack<List<int>> stack = Stack<List<int>>().push([1, 2]).push([
          3,
          4,
          5,
        ]);
        expect(stack.peek, [3, 4, 5]);
        expect(stack.length, 2);
      });

      test('stack works with Map type', () {
        final Stack<Map<String, int>> stack = Stack<Map<String, int>>()
            .push({'a': 1})
            .push({'b': 2, 'c': 3});
        expect(stack.peek, {'b': 2, 'c': 3});
        expect(stack.length, 2);
      });

      test('stack works with custom object type', () {
        final Stack<_TestObject> stack = Stack<_TestObject>()
            .push(_TestObject('first', 1))
            .push(_TestObject('second', 2));
        expect(stack.peek.name, 'second');
        expect(stack.peek.value, 2);
        expect(stack.length, 2);
      });
    });

    group('edge cases', () {
      test('large number of elements', () {
        Stack<int> stack = Stack<int>();
        for (int index = 0; index < 1000; index++) {
          stack = stack.push(index);
        }
        expect(stack.length, 1000);
        expect(stack.peek, 999);

        final (int lastValue, Stack<int> afterPop) = stack.pop();
        expect(lastValue, 999);
        expect(afterPop.length, 999);
        expect(afterPop.peek, 998);
      });

      test('push same value multiple times', () {
        final Stack<int> stack = Stack<int>().push(42).push(42).push(42);
        expect(stack.length, 3);
        expect(stack.peek, 42);

        final (int value1, Stack<int> stack1) = stack.pop();
        final (int value2, Stack<int> stack2) = stack1.pop();
        final (int value3, Stack<int> _) = stack2.pop();

        expect(value1, 42);
        expect(value2, 42);
        expect(value3, 42);
      });

      test('empty string as element', () {
        final Stack<String> stack = Stack<String>().push('').push('a');
        final (String value1, Stack<String> remaining) = stack.pop();
        expect(value1, 'a');
        expect(remaining.peek, '');
      });

      test('zero as element', () {
        final Stack<int> stack = Stack<int>().push(0).push(1);
        final (int value1, Stack<int> remaining) = stack.pop();
        expect(value1, 1);
        expect(remaining.peek, 0);
      });

      test('negative numbers as elements', () {
        final Stack<int> stack = Stack<int>().push(-1).push(-2).push(-3);
        expect(stack.peek, -3);
        expect(stack.length, 3);
      });

      test('alternating push and pop operations', () {
        Stack<int> stack = Stack<int>();

        stack = stack.push(1);
        expect(stack.peek, 1);

        stack = stack.push(2);
        expect(stack.peek, 2);

        final (int poppedValue, Stack<int> afterPop) = stack.pop();
        stack = afterPop;
        expect(poppedValue, 2);
        expect(stack.peek, 1);

        stack = stack.push(3);
        expect(stack.peek, 3);
        expect(stack.length, 2);
      });

      test('pop then push restores length but different top', () {
        final Stack<int> original = Stack<int>().push(1).push(2).push(3);
        final (int _, Stack<int> afterPop) = original.pop();
        final Stack<int> afterPush = afterPop.push(99);

        expect(afterPush.length, 3);
        expect(afterPush.peek, 99);
        expect(original.peek, 3);
      });
    });

    group('combined operations', () {
      test('complex sequence of operations', () {
        Stack<int> stack = Stack<int>();

        stack = stack.push(1);
        stack = stack.push(2);
        stack = stack.push(3);
        expect(stack.length, 3);

        final (int value1, Stack<int> stack1) = stack.pop();
        expect(value1, 3);
        stack = stack1;

        stack = stack.push(4);
        stack = stack.push(5);
        expect(stack.length, 4);
        expect(stack.peek, 5);

        final (int value2, Stack<int> stack2) = stack.pop();
        expect(value2, 5);

        final (int value3, Stack<int> stack3) = stack2.pop();
        expect(value3, 4);

        final (int value4, Stack<int> stack4) = stack3.pop();
        expect(value4, 2);

        final (int value5, Stack<int> stack5) = stack4.pop();
        expect(value5, 1);

        expect(stack5.isEmpty, true);
      });

      test('building stack from constructor and pushing more', () {
        final Stack<int> initial = Stack([1, 2, 3]);
        final Stack<int> extended = initial.push(4).push(5);

        expect(initial.length, 3);
        expect(initial.peek, 3);

        expect(extended.length, 5);
        expect(extended.peek, 5);
      });
    });
  });
}

class _TestObject {
  final String name;
  final int value;

  _TestObject(this.name, this.value);
}
