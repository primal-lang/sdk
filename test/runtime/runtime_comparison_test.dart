import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  group('Comparison', () {
    test('comp.eq', () {
      final Runtime runtime = getRuntime('main = comp.eq("hey", "hey")');
      checkResult(runtime, true);
    });

    test('comp.neq', () {
      final Runtime runtime = getRuntime('main = comp.neq(7, 8)');
      checkResult(runtime, true);
    });

    test('comp.gt', () {
      final Runtime runtime = getRuntime('main = comp.gt(10, 4)');
      checkResult(runtime, true);
    });

    test('comp.lt', () {
      final Runtime runtime = getRuntime('main = comp.lt(10, 4)');
      checkResult(runtime, false);
    });

    test('comp.ge', () {
      final Runtime runtime = getRuntime('main = comp.ge(10, 10)');
      checkResult(runtime, true);
    });

    test('comp.le', () {
      final Runtime runtime = getRuntime('main = comp.le(10, 10)');
      checkResult(runtime, true);
    });
  });

  group('Comparison Type Errors', () {
    test('comp.gt throws for mismatched types', () {
      final Runtime runtime = getRuntime('main = comp.gt("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('comp.lt throws for mismatched types', () {
      final Runtime runtime = getRuntime('main = comp.lt("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('comp.ge throws for mismatched types', () {
      final Runtime runtime = getRuntime('main = comp.ge("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('comp.le throws for mismatched types', () {
      final Runtime runtime = getRuntime('main = comp.le("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('comp.gt throws for non-comparable types', () {
      final Runtime runtime = getRuntime('main = comp.gt([1, 2], [3, 4])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
