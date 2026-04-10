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

    test('vector.new throws for non-list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.new throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.new handles mixed integers and floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, 2.5, 3])',
      );
      checkResult(runtime, [1, 2.5, 3]);
    });

    test('vector.new handles high-dimensional vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])',
      );
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('vector.magnitude throws for non-vector argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude handles high-dimensional vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([1, 1, 1, 1]))',
      );
      checkResult(runtime, 2.0);
    });

    test('vector.normalize throws for non-vector argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.normalize throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add([1, 2], vector.new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2, 3, 4, 5]), vector.new([5, 4, 3, 2, 1]))',
      );
      checkResult(runtime, [6, 6, 6, 6, 6]);
    });

    test('vector.sub throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub([1, 2], vector.new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([10, 20, 30, 40, 50]), vector.new([1, 2, 3, 4, 5]))',
      );
      checkResult(runtime, [9, 18, 27, 36, 45]);
    });

    test('vector.angle throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle([1, 2], vector.new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0, 0, 0]), vector.new([0, 1, 0, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector.magnitude handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([-3, -4]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector.add with first vector empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([]), vector.new([1, 2]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.sub with first vector empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([]), vector.new([1, 2]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.angle with negative single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([-1]), vector.new([1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    test('vector.normalize handles single negative element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([-5]))',
      );
      checkResult(runtime, [-1.0]);
    });

    test('vector.magnitude with zero vector returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([0, 0, 0]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector.add with zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([0, 0]), vector.new([0, 0]))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector.sub with zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([0, 0]), vector.new([0, 0]))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector.add with mixed positive and negative results', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, -2, 3]), vector.new([-4, 5, -6]))',
      );
      checkResult(runtime, [-3, 3, -3]);
    });

    test('vector.sub with mixed positive and negative results', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, -2, 3]), vector.new([-4, 5, -6]))',
      );
      checkResult(runtime, [5, -7, 9]);
    });

    test('vector.new throws for list in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([[1, 2], [3, 4]])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle handles both vectors with same negative direction', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([-1, -1]), vector.new([-2, -2]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    // Additional edge case tests for vector.new
    test('vector.new handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1e100, 2e100, 3e100])',
      );
      checkResult(runtime, [1e100, 2e100, 3e100]);
    });

    test('vector.new handles very small numbers close to zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1e-100, 2e-100, 3e-100])',
      );
      checkResult(runtime, [1e-100, 2e-100, 3e-100]);
    });

    test('vector.new handles negative zero as zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([-0.0, 0.0])',
      );
      checkResult(runtime, [0.0, 0.0]);
    });

    test('vector.new throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new(num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.new throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.new throws for list containing function', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, num.abs, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // Additional edge case tests for vector.magnitude
    test('vector.magnitude throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(true)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.magnitude handles large components', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([1e50, 1e50]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.4142135623730951e50, 1e40),
      );
    });

    // Additional edge case tests for vector.normalize
    test('vector.normalize throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.normalize throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(true)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.normalize throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.normalize returns already normalized vector unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([1, 0, 0]))',
      );
      checkResult(runtime, [1.0, 0.0, 0.0]);
    });

    test('vector.normalize handles 2D unit vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([0.6, 0.8]))',
      );
      checkResult(runtime, [0.6, 0.8]);
    });

    // Additional edge case tests for vector.add
    test('vector.add throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.add with first vector non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2]), vector.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.add handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1e100, 2e100]), vector.new([3e100, 4e100]))',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[4e+100,'));
      expect(result, contains('e+100]'));
    });

    // Additional edge case tests for vector.sub
    test('vector.sub throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.sub with first vector non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2]), vector.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.sub handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([5e100, 6e100]), vector.new([1e100, 2e100]))',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[4e+100,'));
      expect(result, contains('e+100]'));
    });

    test('vector.sub results in zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([5, 10, 15]), vector.new([5, 10, 15]))',
      );
      checkResult(runtime, [0, 0, 0]);
    });

    // Additional edge case tests for vector.angle
    test('vector.angle throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector.angle with first empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([]), vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('vector.angle with first non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), vector.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector.angle handles both zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([0, 0]), vector.new([0, 0]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector.angle computes angle between 45 degree vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0]), vector.new([1, 1]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.7853981633974483, 0.000001),
      );
    });

    test('vector.angle handles scaled vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([2, 0]), vector.new([0, 100]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector.angle handles negative and positive vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([-1, 1]), vector.new([1, 1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    // Composition tests
    test('vector operations can be chained: add then magnitude', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.add(vector.new([1, 2]), vector.new([2, 2])))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector operations can be chained: sub then normalize', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.sub(vector.new([4, 4]), vector.new([1, 0])))',
      );
      // [4, 4] - [1, 0] = [3, 4], normalized = [0.6, 0.8]
      checkResult(runtime, [0.6, 0.8]);
    });

    test('vector operations can be chained: add then normalize', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.add(vector.new([1, 0]), vector.new([0, 1])))',
      );
      expect(
        num.parse(
          runtime.executeMain().substring(
            1,
            runtime.executeMain().indexOf(','),
          ),
        ),
        closeTo(0.7071067811865475, 0.000001),
      );
    });

    test('vector operations can be chained: multiple adds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.add(vector.new([1, 1]), vector.new([2, 2])), vector.new([3, 3]))',
      );
      checkResult(runtime, [6, 6]);
    });

    test('vector operations can be chained: multiple subs', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.sub(vector.new([10, 10]), vector.new([3, 3])), vector.new([2, 2]))',
      );
      checkResult(runtime, [5, 5]);
    });

    test('vector operations can be chained: add and sub', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.add(vector.new([5, 5]), vector.new([3, 3])), vector.new([4, 4]))',
      );
      checkResult(runtime, [4, 4]);
    });

    test('vector.angle with normalized vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.normalize(vector.new([3, 4])), vector.normalize(vector.new([4, 3])))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.28379410920832, 0.0001),
      );
    });

    // Stress tests with 20-element vectors (manageable size)
    test('vector.new handles 20-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[1, '));
      expect(result, endsWith(', 20]'));
    });

    test('vector.magnitude handles 16-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      checkResult(runtime, 4.0);
    });

    test('vector.add handles 15-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]), vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]'));
    });

    test('vector.sub handles 15-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]), vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]'));
    });

    test('vector.normalize handles 16-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      // Each component should be 1/sqrt(16) = 0.25
      expect(result, contains('0.25'));
    });

    test('vector.angle handles 10-element orthogonal vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), vector.new([0, 1, 0, 0, 0, 0, 0, 0, 0, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    // Special numeric value tests (using num.infinity() function)
    test('vector.new handles infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([num.infinity(), 1])',
      );
      final String result = runtime.executeMain();
      expect(result, contains('Infinity'));
    });

    test('vector.new handles negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([num.negative(num.infinity()), 1])',
      );
      final String result = runtime.executeMain();
      expect(result, contains('-Infinity'));
    });

    test('vector.magnitude with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([num.infinity(), 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('Infinity'));
    });

    // Numerical edge cases
    test('vector.add with opposite large values cancels to zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1e10, -1e10]), vector.new([-1e10, 1e10]))',
      );
      checkResult(runtime, [0.0, 0.0]);
    });

    test('vector.sub with identical vectors returns zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1.5, 2.5, 3.5]), vector.new([1.5, 2.5, 3.5]))',
      );
      checkResult(runtime, [0.0, 0.0, 0.0]);
    });

    test('vector.add preserves integer precision for small integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1, 2, 3]), vector.new([4, 5, 6]))',
      );
      checkResult(runtime, [5, 7, 9]);
    });

    test('vector.sub preserves integer precision for small integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([10, 20, 30]), vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [9, 18, 27]);
    });

    // Additional error case: list type validation
    test('vector.new throws for list containing map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.new([1, {"a": 1}, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // Verify angle symmetry
    test('vector.angle is symmetric', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = vector.angle(vector.new([1, 2, 3]), vector.new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main = vector.angle(vector.new([4, 5, 6]), vector.new([1, 2, 3]))',
      );
      final double angle1 = num.parse(runtime1.executeMain()).toDouble();
      final double angle2 = num.parse(runtime2.executeMain()).toDouble();
      expect(angle1, closeTo(angle2, 0.000001));
    });

    // Verify normalization produces unit vector
    test('vector.normalize produces unit magnitude vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.normalize(vector.new([3, 4, 5])))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });

    test('vector.normalize produces unit magnitude for arbitrary vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.normalize(vector.new([17, -23, 42, 8])))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });

    // Additional mathematical property tests
    test('vector.add is commutative', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = vector.add(vector.new([1, 2, 3]), vector.new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main = vector.add(vector.new([4, 5, 6]), vector.new([1, 2, 3]))',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('vector.sub is anti-commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.sub(vector.new([1, 2]), vector.new([3, 4])), vector.sub(vector.new([3, 4]), vector.new([1, 2])))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector.add with additive identity (zero vector)', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([5, 10, 15]), vector.new([0, 0, 0]))',
      );
      checkResult(runtime, [5, 10, 15]);
    });

    test('vector.sub with self returns zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([7, 14, 21]), vector.new([7, 14, 21]))',
      );
      checkResult(runtime, [0, 0, 0]);
    });

    test('vector.angle between same non-unit vector is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([5, 10, 15]), vector.new([5, 10, 15]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector.angle between scaled vectors is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2, 3]), vector.new([2, 4, 6]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector.angle between opposite direction scaled vectors is pi', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2, 3]), vector.new([-2, -4, -6]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    // Double normalize should produce a unit vector
    test('vector.normalize twice produces unit vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.normalize(vector.normalize(vector.new([3, 4, 5]))))',
      );
      // The magnitude of a normalized vector should be approximately 1
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });
  });
}
