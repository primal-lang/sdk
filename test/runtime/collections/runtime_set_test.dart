import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Set', () {
    test('set.new 1', () {
      final Runtime runtime = getRuntime('main = set.new([])');
      checkResult(runtime, {});
    });

    test('set.new 2', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2])');
      checkResult(runtime, {1, 2});
    });

    test('set.new 3', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2, 1])');
      checkResult(runtime, {1, 2});
    });

    test('set.add 1', () {
      final Runtime runtime = getRuntime('main = set.add(set.new([]), 1)');
      checkResult(runtime, {1});
    });

    test('set.add 2', () {
      final Runtime runtime = getRuntime('main = set.add(set.new([1, 2]), 3)');
      checkResult(runtime, {1, 2, 3});
    });

    test('set.add 3', () {
      final Runtime runtime = getRuntime('main = set.add(set.new([1, 2]), 2)');
      checkResult(runtime, {1, 2});
    });

    test('set.remove 1', () {
      final Runtime runtime = getRuntime('main = set.remove(set.new([]), 1)');
      checkResult(runtime, {});
    });

    test('set.remove 2', () {
      final Runtime runtime = getRuntime(
        'main = set.remove(set.new([1, 2]), 3)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.remove 3', () {
      final Runtime runtime = getRuntime(
        'main = set.remove(set.new([1, 2]), 2)',
      );
      checkResult(runtime, {1});
    });

    test('set.contains 1', () {
      final Runtime runtime = getRuntime(
        'main = set.contains(set.new([1, 2, 3]), 2)',
      );
      checkResult(runtime, true);
    });

    test('set.contains 2', () {
      final Runtime runtime = getRuntime(
        'main = set.contains(set.new([1, 2]), 3)',
      );
      checkResult(runtime, false);
    });

    test('set.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = set.isEmpty(set.new([]))');
      checkResult(runtime, true);
    });

    test('set.isEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = set.isEmpty(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = set.isNotEmpty(set.new([]))');
      checkResult(runtime, false);
    });

    test('set.isNotEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = set.isNotEmpty(set.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set.length 1', () {
      final Runtime runtime = getRuntime('main = set.length(set.new([]))');
      checkResult(runtime, 0);
    });

    test('set.length 2', () {
      final Runtime runtime = getRuntime(
        'main = set.length(set.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('set.union 1', () {
      final Runtime runtime = getRuntime(
        'main = set.union(set.new([]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.union 2', () {
      final Runtime runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.union 3', () {
      final Runtime runtime = getRuntime(
        'main = set.union(set.new([1]), set.new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.union 4', () {
      final Runtime runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.intersection 1', () {
      final Runtime runtime = getRuntime(
        'main = set.intersection(set.new([]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection 2', () {
      final Runtime runtime = getRuntime(
        'main = set.intersection(set.new([1]), set.new([2]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection 3', () {
      final Runtime runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), set.new([2, 3]))',
      );
      checkResult(runtime, {2});
    });

    test('set.intersection 4', () {
      final Runtime runtime = getRuntime(
        'main = set.intersection(set.new([2, 3]), set.new([1, 2]))',
      );
      checkResult(runtime, {2});
    });

    test('set.variable', () {
      final Runtime runtime = getRuntime('''
foo(values) = [set.add(values, 1)]

main = foo(set.new([2, 3]))
''');
      checkResult(runtime, [
        {2, 3, 1},
      ]);
    });
  });

  group('Set Type Errors', () {
    test('set.contains throws for non-set first arg', () {
      final Runtime runtime = getRuntime('main = set.contains([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for non-set first arg', () {
      final Runtime runtime = getRuntime('main = set.add([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for non-set first arg', () {
      final Runtime runtime = getRuntime('main = set.remove([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for non-set arg', () {
      final Runtime runtime = getRuntime('main = set.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for non-set first arg', () {
      final Runtime runtime = getRuntime(
        'main = set.union([1, 2], set.new([3]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
