@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Vector', () {
    test('vector_new creates empty vector from empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_new([])');
      checkResult(runtime, []);
    });

    test('vector_new creates vector from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('vector_magnitude returns zero for empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector_magnitude computes length of non-empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([1, 2, 3]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(3.7416573867739413, 0.001),
      );
    });

    test('vector_normalize returns empty vector for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector_normalize throws for zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([0, 0, 0]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test('vector_normalize returns unit vector for non-empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([1, 2, 3]))',
      );
      checkResult(runtime, [
        0.2672612419124244,
        0.5345224838248488,
        0.8017837257372732,
      ]);
    });

    test('vector_add of two empty vectors returns empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([]), vector_new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector_add sums corresponding components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2]), vector_new([3, 4]))',
      );
      checkResult(runtime, [4, 6]);
    });

    test('vector_add throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2]), vector_new([4, 5, 6]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_sub of two empty vectors returns empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([]), vector_new([]))',
      );
      checkResult(runtime, []);
    });

    test('vector_sub subtracts corresponding components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, 2]), vector_new([3, 4]))',
      );
      checkResult(runtime, [-2, -2]);
    });

    test('vector_sub throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, 2]), vector_new([4, 5, 6]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_angle throws for empty vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([]), vector_new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('vector_angle throws for zero-magnitude vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([0, 0, 0]), vector_new([1, 2, 3]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector_angle computes angle between 2D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2]), vector_new([3, 4]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.17985349979247847, 0.000001),
      );
    });

    test('vector_angle computes angle between 3D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([3, 4, 0]), vector_new([4, 3, 0]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.28379410920832, 0.0001),
      );
    });

    test('vector_angle returns 0 for parallel vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0]), vector_new([1, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector_angle returns pi for anti-parallel vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0]), vector_new([-1, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    test('vector_angle returns pi/2 for perpendicular vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0]), vector_new([0, 1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector_angle throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2]), vector_new([3, 4, 5]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_angle computes angle between single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1]), vector_new([1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector_new creates single-element vector', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_new([42])');
      checkResult(runtime, [42]);
    });

    test('vector_new throws for list containing non-number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, "two", 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude computes length of single-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([5]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_normalize returns unit vector for single-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([5]))',
      );
      checkResult(runtime, [1.0]);
    });

    test('vector_add sums single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([3]), vector_new([7]))',
      );
      checkResult(runtime, [10]);
    });

    test('vector_sub subtracts single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([10]), vector_new([4]))',
      );
      checkResult(runtime, [6]);
    });

    test('vector_magnitude returns magnitude for 2D vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([3, 4]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_normalize handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([-3, -4]))',
      );
      checkResult(runtime, [-0.6, -0.8]);
    });

    test('vector_add handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([-1, -2]), vector_new([-3, -4]))',
      );
      checkResult(runtime, [-4, -6]);
    });

    test('vector_sub handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([-1, -2]), vector_new([-3, -4]))',
      );
      checkResult(runtime, [2, 2]);
    });

    test('vector_new handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('vector_add handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1.5, 2.5]), vector_new([0.5, 0.5]))',
      );
      checkResult(runtime, [2.0, 3.0]);
    });

    test('vector_sub handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([2.5, 3.5]), vector_new([0.5, 1.5]))',
      );
      checkResult(runtime, [2.0, 2.0]);
    });

    test('vector_angle handles second vector with zero magnitude', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2, 3]), vector_new([0, 0, 0]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector_new throws for boolean in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, true, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_new throws for non-list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_new throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_new handles mixed integers and floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, 2.5, 3])',
      );
      checkResult(runtime, [1, 2.5, 3]);
    });

    test('vector_new handles high-dimensional vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])',
      );
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('vector_magnitude throws for non-vector argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude handles high-dimensional vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([1, 1, 1, 1]))',
      );
      checkResult(runtime, 2.0);
    });

    test('vector_normalize throws for non-vector argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_normalize throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(42)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2, 3, 4, 5]), vector_new([5, 4, 3, 2, 1]))',
      );
      checkResult(runtime, [6, 6, 6, 6, 6]);
    });

    test('vector_sub throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([10, 20, 30, 40, 50]), vector_new([1, 2, 3, 4, 5]))',
      );
      checkResult(runtime, [9, 18, 27, 36, 45]);
    });

    test('vector_angle throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0, 0, 0]), vector_new([0, 1, 0, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector_magnitude handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([-3, -4]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_add with first vector empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([]), vector_new([1, 2]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_sub with first vector empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([]), vector_new([1, 2]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_angle with negative single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([-1]), vector_new([1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    test('vector_normalize handles single negative element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([-5]))',
      );
      checkResult(runtime, [-1.0]);
    });

    test('vector_magnitude with zero vector returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([0, 0, 0]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector_add with zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([0, 0]), vector_new([0, 0]))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector_sub with zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([0, 0]), vector_new([0, 0]))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector_add with mixed positive and negative results', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, -2, 3]), vector_new([-4, 5, -6]))',
      );
      checkResult(runtime, [-3, 3, -3]);
    });

    test('vector_sub with mixed positive and negative results', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, -2, 3]), vector_new([-4, 5, -6]))',
      );
      checkResult(runtime, [5, -7, 9]);
    });

    test('vector_new throws for list in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([[1, 2], [3, 4]])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle handles both vectors with same negative direction', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([-1, -1]), vector_new([-2, -2]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    // Additional edge case tests for vector_new
    test('vector_new handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1e100, 2e100, 3e100])',
      );
      checkResult(runtime, [1e100, 2e100, 3e100]);
    });

    test('vector_new handles very small numbers close to zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1e-100, 2e-100, 3e-100])',
      );
      checkResult(runtime, [1e-100, 2e-100, 3e-100]);
    });

    test('vector_new handles negative zero as zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([-0.0, 0.0])',
      );
      checkResult(runtime, [0.0, 0.0]);
    });

    test('vector_new throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new(num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_new throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_new throws for list containing function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, num_abs, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // Additional edge case tests for vector_magnitude
    test('vector_magnitude throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(true)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_magnitude handles large components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([1e50, 1e50]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.4142135623730951e50, 1e40),
      );
    });

    // Additional edge case tests for vector_normalize
    test('vector_normalize throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize("hello")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_normalize throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(true)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_normalize throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_normalize returns already normalized vector unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([1, 0, 0]))',
      );
      checkResult(runtime, [1.0, 0.0, 0.0]);
    });

    test('vector_normalize handles 2D unit vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([0.6, 0.8]))',
      );
      checkResult(runtime, [0.6, 0.8]);
    });

    // Additional edge case tests for vector_add
    test('vector_add throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_add with first vector non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2]), vector_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_add handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1e100, 2e100]), vector_new([3e100, 4e100]))',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[4e+100,'));
      expect(result, contains('e+100]'));
    });

    // Additional edge case tests for vector_sub
    test('vector_sub throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_sub with first vector non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, 2]), vector_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_sub handles very large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([5e100, 6e100]), vector_new([1e100, 2e100]))',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[4e+100,'));
      expect(result, contains('e+100]'));
    });

    test('vector_sub results in zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([5, 10, 15]), vector_new([5, 10, 15]))',
      );
      checkResult(runtime, [0, 0, 0]);
    });

    // Additional edge case tests for vector_angle
    test('vector_angle throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(true, false)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle throws for map arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle({"a": 1}, {"b": 2})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_angle with first empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([]), vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('vector_angle with first non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2]), vector_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_angle handles both zero vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([0, 0]), vector_new([0, 0]))',
      );
      expect(runtime.executeMain, throwsA(isA<DivisionByZeroError>()));
    });

    test('vector_angle computes angle between 45 degree vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0]), vector_new([1, 1]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.7853981633974483, 0.000001),
      );
    });

    test('vector_angle handles scaled vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([2, 0]), vector_new([0, 100]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    test('vector_angle handles negative and positive vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([-1, 1]), vector_new([1, 1]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    // Composition tests
    test('vector operations can be chained: add then magnitude', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_add(vector_new([1, 2]), vector_new([2, 2])))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector operations can be chained: sub then normalize', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_sub(vector_new([4, 4]), vector_new([1, 0])))',
      );
      // [4, 4] - [1, 0] = [3, 4], normalized = [0.6, 0.8]
      checkResult(runtime, [0.6, 0.8]);
    });

    test('vector operations can be chained: add then normalize', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_add(vector_new([1, 0]), vector_new([0, 1])))',
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
        'main() = vector_add(vector_add(vector_new([1, 1]), vector_new([2, 2])), vector_new([3, 3]))',
      );
      checkResult(runtime, [6, 6]);
    });

    test('vector operations can be chained: multiple subs', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_sub(vector_new([10, 10]), vector_new([3, 3])), vector_new([2, 2]))',
      );
      checkResult(runtime, [5, 5]);
    });

    test('vector operations can be chained: add and sub', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_add(vector_new([5, 5]), vector_new([3, 3])), vector_new([4, 4]))',
      );
      checkResult(runtime, [4, 4]);
    });

    test('vector_angle with normalized vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_normalize(vector_new([3, 4])), vector_normalize(vector_new([4, 3])))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.28379410920832, 0.0001),
      );
    });

    // Stress tests with 20-element vectors (manageable size)
    test('vector_new handles 20-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])',
      );
      final String result = runtime.executeMain();
      expect(result, startsWith('[1, '));
      expect(result, endsWith(', 20]'));
    });

    test('vector_magnitude handles 16-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      checkResult(runtime, 4.0);
    });

    test('vector_add handles 15-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]), vector_new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]'));
    });

    test('vector_sub handles 15-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]), vector_new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]'));
    });

    test('vector_normalize handles 16-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))',
      );
      final String result = runtime.executeMain();
      // Each component should be 1/sqrt(16) = 0.25
      expect(result, contains('0.25'));
    });

    test('vector_angle handles 10-element orthogonal vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), vector_new([0, 1, 0, 0, 0, 0, 0, 0, 0, 0]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.5707963, 0.000001));
    });

    // Special numeric value tests (using num_infinity() function)
    test('vector_new handles infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([num_infinity(), 1])',
      );
      final String result = runtime.executeMain();
      expect(result, contains('Infinity'));
    });

    test('vector_new handles negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([num_negative(num_infinity()), 1])',
      );
      final String result = runtime.executeMain();
      expect(result, contains('-Infinity'));
    });

    test('vector_magnitude with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([num_infinity(), 1]))',
      );
      final String result = runtime.executeMain();
      expect(result, equals('Infinity'));
    });

    // Numerical edge cases
    test('vector_add with opposite large values cancels to zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1e10, -1e10]), vector_new([-1e10, 1e10]))',
      );
      checkResult(runtime, [0.0, 0.0]);
    });

    test('vector_sub with identical vectors returns zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1.5, 2.5, 3.5]), vector_new([1.5, 2.5, 3.5]))',
      );
      checkResult(runtime, [0.0, 0.0, 0.0]);
    });

    test('vector_add preserves integer precision for small integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      checkResult(runtime, [5, 7, 9]);
    });

    test('vector_sub preserves integer precision for small integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([10, 20, 30]), vector_new([1, 2, 3]))',
      );
      checkResult(runtime, [9, 18, 27]);
    });

    // Additional error case: list type validation
    test('vector_new throws for list containing map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new([1, {"a": 1}, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // Verify angle symmetry
    test('vector_angle is symmetric', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = vector_angle(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = vector_angle(vector_new([4, 5, 6]), vector_new([1, 2, 3]))',
      );
      final double angle1 = num.parse(runtime1.executeMain()).toDouble();
      final double angle2 = num.parse(runtime2.executeMain()).toDouble();
      expect(angle1, closeTo(angle2, 0.000001));
    });

    // Verify normalization produces unit vector
    test('vector_normalize produces unit magnitude vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_normalize(vector_new([3, 4, 5])))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });

    test('vector_normalize produces unit magnitude for arbitrary vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_normalize(vector_new([17, -23, 42, 8])))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });

    // Additional mathematical property tests
    test('vector_add is commutative', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = vector_add(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = vector_add(vector_new([4, 5, 6]), vector_new([1, 2, 3]))',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('vector_sub is anti-commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_sub(vector_new([1, 2]), vector_new([3, 4])), vector_sub(vector_new([3, 4]), vector_new([1, 2])))',
      );
      checkResult(runtime, [0, 0]);
    });

    test('vector_add with additive identity (zero vector)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([5, 10, 15]), vector_new([0, 0, 0]))',
      );
      checkResult(runtime, [5, 10, 15]);
    });

    test('vector_sub with self returns zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([7, 14, 21]), vector_new([7, 14, 21]))',
      );
      checkResult(runtime, [0, 0, 0]);
    });

    test('vector_angle between same non-unit vector is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([5, 10, 15]), vector_new([5, 10, 15]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector_angle between scaled vectors is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2, 3]), vector_new([2, 4, 6]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0, 0.000001));
    });

    test('vector_angle between opposite direction scaled vectors is pi', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2, 3]), vector_new([-2, -4, -6]))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.14159265, 0.000001));
    });

    // Double normalize should produce a unit vector
    test('vector_normalize twice produces unit vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_normalize(vector_normalize(vector_new([3, 4, 5]))))',
      );
      // The magnitude of a normalized vector should be approximately 1
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.000001));
    });

    // ===== vector_dot tests =====

    test('vector_dot of two empty vectors returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([]), vector_new([]))',
      );
      checkResult(runtime, 0);
    });

    test('vector_dot computes dot product of 2D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 2]), vector_new([3, 4]))',
      );
      checkResult(runtime, 11);
    });

    test('vector_dot computes dot product of 3D vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      checkResult(runtime, 32);
    });

    test('vector_dot of single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([5]), vector_new([7]))',
      );
      checkResult(runtime, 35);
    });

    test('vector_dot throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 2]), vector_new([3, 4, 5]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_dot throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_dot throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_dot throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_dot throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_dot throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_dot handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([-1, 2, -3]), vector_new([4, -5, 6]))',
      );
      checkResult(runtime, -32);
    });

    test('vector_dot handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1.5, 2.5]), vector_new([2.0, 3.0]))',
      );
      checkResult(runtime, 10.5);
    });

    test('vector_dot with zero vectors returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([0, 0, 0]), vector_new([1, 2, 3]))',
      );
      checkResult(runtime, 0);
    });

    test('vector_dot is commutative', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = vector_dot(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = vector_dot(vector_new([4, 5, 6]), vector_new([1, 2, 3]))',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('vector_dot of perpendicular vectors is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 0]), vector_new([0, 1]))',
      );
      checkResult(runtime, 0);
    });

    test('vector_dot of parallel vectors equals product of magnitudes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([3, 0]), vector_new([4, 0]))',
      );
      checkResult(runtime, 12);
    });

    test('vector_dot of anti-parallel vectors is negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 0]), vector_new([-1, 0]))',
      );
      checkResult(runtime, -1);
    });

    test('vector_dot handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_dot(vector_new([1, 1, 1, 1, 1]), vector_new([2, 2, 2, 2, 2]))',
      );
      checkResult(runtime, 10);
    });

    // ===== vector_scale tests =====

    test('vector_scale of empty vector returns empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([]), 5)',
      );
      checkResult(runtime, []);
    });

    test('vector_scale scales 2D vector by positive scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2]), 3)',
      );
      checkResult(runtime, [3, 6]);
    });

    test('vector_scale scales 3D vector by positive scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2, 3]), 2)',
      );
      checkResult(runtime, [2, 4, 6]);
    });

    test('vector_scale with scalar zero returns zero vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2, 3]), 0)',
      );
      checkResult(runtime, [0, 0, 0]);
    });

    test('vector_scale with scalar one returns same vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([5, 10, 15]), 1)',
      );
      checkResult(runtime, [5, 10, 15]);
    });

    test('vector_scale with negative scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2, 3]), -2)',
      );
      checkResult(runtime, [-2, -4, -6]);
    });

    test('vector_scale with fractional scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([4, 8, 12]), 0.5)',
      );
      checkResult(runtime, [2.0, 4.0, 6.0]);
    });

    test('vector_scale throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale([1, 2, 3], 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_scale throws when second argument is not a number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2, 3]), "two")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_scale throws for string first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale("hello", 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_scale throws for boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2]), true)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_scale throws when second argument is a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2]), vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_scale handles negative vector components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([-1, -2, -3]), 2)',
      );
      checkResult(runtime, [-2, -4, -6]);
    });

    test('vector_scale of single-element vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([7]), 3)',
      );
      checkResult(runtime, [21]);
    });

    test('vector_scale handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2, 3, 4, 5]), 10)',
      );
      checkResult(runtime, [10, 20, 30, 40, 50]);
    });

    test('vector_scale then magnitude equals magnitude times scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_scale(vector_new([3, 4]), 2))',
      );
      checkResult(runtime, 10.0);
    });

    test('vector_scale with very large scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2]), 1e10)',
      );
      checkResult(runtime, [1e10, 2e10]);
    });

    test('vector_scale with very small scalar', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_scale(vector_new([1, 2]), 1e-10)',
      );
      checkResult(runtime, [1e-10, 2e-10]);
    });

    // ===== vector_distance tests =====

    test('vector_distance of two empty vectors returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([]), vector_new([]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector_distance computes distance between 2D points', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([0, 0]), vector_new([3, 4]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_distance computes distance between 3D points', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([1, 2, 3]), vector_new([4, 6, 3]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_distance of same point returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([5, 10, 15]), vector_new([5, 10, 15]))',
      );
      checkResult(runtime, 0.0);
    });

    test('vector_distance of single-element vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([3]), vector_new([7]))',
      );
      checkResult(runtime, 4.0);
    });

    test('vector_distance throws for vectors with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([1, 2]), vector_new([3, 4, 5]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_distance throws when first argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_distance throws when second argument is not a vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_distance throws when both arguments are not vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance([1, 2], [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_distance throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance("hello", "world")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_distance throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(42, 43)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('vector_distance is symmetric', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = vector_distance(vector_new([1, 2, 3]), vector_new([4, 5, 6]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = vector_distance(vector_new([4, 5, 6]), vector_new([1, 2, 3]))',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('vector_distance handles negative components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([-1, -2]), vector_new([2, 2]))',
      );
      checkResult(runtime, 5.0);
    });

    test('vector_distance handles floating point numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([0.0, 0.0]), vector_new([1.0, 1.0]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.4142135623730951, 0.000001),
      );
    });

    test('vector_distance handles high-dimensional vectors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([0, 0, 0, 0]), vector_new([1, 1, 1, 1]))',
      );
      checkResult(runtime, 2.0);
    });

    test('vector_distance with first empty and second non-empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([]), vector_new([1, 2]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_distance with first non-empty and second empty throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([1, 2]), vector_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });

    test('vector_distance equals magnitude of difference', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = vector_distance(vector_new([1, 2, 3]), vector_new([4, 6, 3]))',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = vector_magnitude(vector_sub(vector_new([1, 2, 3]), vector_new([4, 6, 3])))',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('vector_distance with very large coordinates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([0, 0]), vector_new([3e10, 4e10]))',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(5e10, 1e5),
      );
    });

    test('vector_distance along a single axis', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_distance(vector_new([0, 0, 0]), vector_new([0, 0, 10]))',
      );
      checkResult(runtime, 10.0);
    });
  });
}
