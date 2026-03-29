import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('Vector', () {
    test('vector.new 1', () {
      final Runtime runtime = getRuntime('main = vector.new([])');
      checkResult(runtime, []);
    });

    test('vector.new 2', () {
      final Runtime runtime = getRuntime('main = vector.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('vector.magnitude 1', () {
      final Runtime runtime = getRuntime(
        'main = vector.magnitude(vector.new([]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector.magnitude 2', () {
      final Runtime runtime = getRuntime(
        'main = vector.magnitude(vector.new([1, 2, 3]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(3.7416573867739413, 0.001),
      );
    });

    test('vector.normalize 1', () {
      final Runtime runtime = getRuntime(
        'main = vector.normalize(vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.normalize 2', () {
      final Runtime runtime = getRuntime(
        'main = vector.normalize(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [
        0.2672612419124244,
        0.5345224838248488,
        0.8017837257372732,
      ]);
    });

    test('vector.add 1', () {
      final Runtime runtime = getRuntime(
        'main = vector.add(vector.new([]), vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.add 2', () {
      final Runtime runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), vector.new([3, 4]))',
      );
      checkResult(runtime, [4, 6]);
    });

    test('vector.add 3', () {
      final Runtime runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), vector.new([4, 5, 6]))',
      );
      expect(runtime.executeMain, throwsA(isA<IterablesWithDifferentLengthError>()));
    });

    test('vector.sub 1', () {
      final Runtime runtime = getRuntime(
        'main = vector.sub(vector.new([]), vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.sub 2', () {
      final Runtime runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), vector.new([3, 4]))',
      );
      checkResult(runtime, [-2, -2]);
    });

    test('vector.sub 3', () {
      final Runtime runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), vector.new([4, 5, 6]))',
      );
      expect(runtime.executeMain, throwsA(isA<IterablesWithDifferentLengthError>()));
    });

    test('vector.angle 1', () {
      final Runtime runtime = getRuntime(
        'main = vector.angle(vector.new([]), vector.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('vector.angle 2', () {
      final Runtime runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), vector.new([3, 4]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.17985349979247847, 0.000001),
      );
    });

    test('vector.angle 3', () {
      final Runtime runtime = getRuntime(
        'main = vector.angle(vector.new([3, 4, 0]), vector.new([4, 3, 0]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.28379410920832, 0.0001),
      );
    });
  });
}
