@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Vector', () {
    test('vector.new creates empty vector from empty list', () {
      final RuntimeFacade runtime = getRuntime('main = vector.new([])');
      checkResult(runtime, []);
    });

    test('vector.new creates vector from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main = vector.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('vector.magnitude returns zero for empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector.magnitude computes length of non-empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([1, 2, 3]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(3.7416573867739413, 0.001),
      );
    });

    test('vector.normalize returns empty vector for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.normalize throws for zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([0, 0, 0]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test('vector.normalize returns unit vector for non-empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [
        0.2672612419124244,
        0.5345224838248488,
        0.8017837257372732,
      ]);
    });

    test('vector.add of two empty vectors returns empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([]), vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.add sums corresponding components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), vector.new([3, 4]))',
      );
      checkResult(runtime, [4, 6]);
    });

    test('vector.add throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), vector.new([4, 5, 6]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.sub of two empty vectors returns empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([]), vector.new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector.sub subtracts corresponding components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), vector.new([3, 4]))',
      );
      checkResult(runtime, [-2, -2]);
    });

    test('vector.sub throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), vector.new([4, 5, 6]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.angle throws for empty vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([]), vector.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('vector.angle throws for zero-magnitude vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([0, 0, 0]), vector.new([1, 2, 3]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector.angle computes angle between 2D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), vector.new([3, 4]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.17985349979247847, 0.000001),
      );
    });

    test('vector.angle computes angle between 3D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([3, 4, 0]), vector.new([4, 3, 0]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.28379410920832, 0.0001),
      );
    });

    test('vector.angle returns 0 for parallel vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0]), vector.new([1, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector.angle returns pi for anti-parallel vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0]), vector.new([-1, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    test('vector.angle returns pi/2 for perpendicular vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0]), vector.new([0, 1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector.angle throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), vector.new([3, 4, 5]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.angle computes angle between single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1]), vector.new([1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector.new creates single-element vector', () {
      final RuntimeFacade runtime = getRuntime('main = vector.new([42])');
      checkResult(runtime, [42]);
    });

    test('vector.new throws for list containing non-number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, "two", 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude computes length of single-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([5]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector.normalize returns unit vector for single-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([5]))',
      );
      checkResult(runtime, [1.0]);
    });

    test('vector.add sums single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([3]), vector.new([7]))',
      );
      checkResult(runtime, [10]);
    });

    test('vector.sub subtracts single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([10]), vector.new([4]))',
      );
      checkResult(runtime, [6]);
    });

    test('vector.magnitude returns magnitude for 2D vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([3, 4]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector.normalize handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([-3, -4]))',
      );
      checkResult(runtime, [-0.6, -0.8]);
    });

    test('vector.add handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([-1, -2]), vector.new([-3, -4]))',
      );
      checkResult(runtime, [-4, -6]);
    });

    test('vector.sub handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([-1, -2]), vector.new([-3, -4]))',
      );
      checkResult(runtime, [2, 2]);
    });

    test('vector.new handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('vector.add handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1.5, 2.5]), vector.new([0.5, 0.5]))',
      );
      checkResult(runtime, [2.0, 3.0]);
    });

    test('vector.sub handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([2.5, 3.5]), vector.new([0.5, 1.5]))',
      );
      checkResult(runtime, [2.0, 2.0]);
    });

    test('vector.angle handles second vector with zero magnitude', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2, 3]), vector.new([0, 0, 0]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector.new throws for boolean in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, true, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });
}
