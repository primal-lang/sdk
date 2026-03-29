import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('Type Mismatch Errors', () {
    test('number plus boolean', () {
      final Runtime runtime = getRuntime('main = 5 + true');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('string minus string', () {
      final Runtime runtime = getRuntime('main = "hello" - "world"');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('string times number', () {
      final Runtime runtime = getRuntime('main = "hello" * 3');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.abs with string', () {
      final Runtime runtime = getRuntime('main = num.abs("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.length with number', () {
      final Runtime runtime = getRuntime('main = str.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.length with number', () {
      final Runtime runtime = getRuntime('main = list.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('boolean greater than', () {
      final Runtime runtime = getRuntime('main = true > false');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
