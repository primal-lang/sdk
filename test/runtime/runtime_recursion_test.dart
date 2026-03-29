import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../utils/test_utils.dart';

void main() {
  group('Try/Catch Advanced', () {
    test('try catches empty list first', () {
      final Runtime runtime = getRuntime('main = try(list.first([]), -1)');
      checkResult(runtime, -1);
    });

    test('try catches missing map key', () {
      final Runtime runtime = getRuntime(
        'main = try(map.at({}, "x"), "default")',
      );
      checkResult(runtime, '"default"');
    });

    test('try catches type mismatch', () {
      final Runtime runtime = getRuntime('main = try(5 + true, 0)');
      checkResult(runtime, 0);
    });

    test('try catches out of bounds', () {
      final Runtime runtime = getRuntime('main = try([1, 2][5], -1)');
      checkResult(runtime, -1);
    });

    test('try returns value when no error', () {
      final Runtime runtime = getRuntime('main = try(1 + 2, 42)');
      checkResult(runtime, 3);
    });
  });

  group('Recursion', () {
    test('direct recursion countdown', () {
      final Runtime runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(5)
''');
      checkResult(runtime, 0);
    });

    test('recursive sum', () {
      final Runtime runtime = getRuntime('''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = sum(5)
''');
      checkResult(runtime, 15);
    });

    test('mutual recursion', () {
      final Runtime runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(4)
''');
      checkResult(runtime, true);
    });

    test('mutual recursion odd', () {
      final Runtime runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isOdd(5)
''');
      checkResult(runtime, true);
    });
  });
}
