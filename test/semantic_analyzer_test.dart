import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  test('Duplicated parameter', () {
    try {
      getIntermediateCode('isBiggerThan10(x, x) = x > 10');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<DuplicatedParameterError>());
    }
  });

  test('Duplicated function', () {
    try {
      getIntermediateCode('function1(x, y) = x > 10\nfunction1(a, b) = a > 10');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<DuplicatedFunctionError>());
    }
  });

  test('Undefined identifier 1', () {
    try {
      getIntermediateCode('isBiggerThan10 = z > 10');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  test('Undefined identifier 2', () {
    try {
      getIntermediateCode('isBiggerThan10 = x');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  test('Unused parameter', () {
    final IntermediateCode code = getIntermediateCode(
      'isBiggerThan10(x, y) = x > 10',
    );
    expect(code.warnings.length, equals(1));
  });

  test('Undefined function', () {
    try {
      getIntermediateCode('main = duplicate(20)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedFunctionError>());
    }
  });

  test('Invalid number of arguments', () {
    try {
      getIntermediateCode(
        'isBiggerThan10(x) = x > 10\nmain = isBiggerThan10(20, 5)',
      );
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  test('Valid program 1', () {
    final IntermediateCode code = getIntermediateCode('''
foo(x) = x * 2
main = foo(5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Valid program 2', () {
    final IntermediateCode code = getIntermediateCode('''
bar = num.abs
foo(x) = bar()(x) * 2
main = foo(5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Valid program 3', () {
    final IntermediateCode code = getIntermediateCode('''
apply(f, v) = f(v)
main = apply(num.abs, 5)
''');
    expect(code.warnings.length, equals(0));
  });

  // --- Error: argument count mismatches ---

  test('Too few arguments', () {
    try {
      getIntermediateCode(
        'isBiggerThan(x, y) = x > y\nmain = isBiggerThan(20)',
      );
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  test('Zero arguments when function expects some', () {
    try {
      getIntermediateCode(
        'identity(x) = x\nmain = identity()',
      );
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  test('Arguments when function expects zero', () {
    try {
      getIntermediateCode(
        'constant = 10\nmain = constant(5)',
      );
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  // --- Error: undefined identifiers in expressions ---

  test('Undefined identifier in nested expression', () {
    try {
      getIntermediateCode('f(x) = x + z');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  test('Undefined function in nested call', () {
    try {
      getIntermediateCode('f(x) = unknown(x) + 1');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedFunctionError>());
    }
  });

  test('Undefined identifier as function argument', () {
    try {
      getIntermediateCode('f(x) = x\nmain = f(z)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  test('Undefined identifier in list literal', () {
    try {
      getIntermediateCode('main = [1, z, 3]');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  test('Undefined identifier in map literal', () {
    try {
      getIntermediateCode('main = {"key": z}');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedIdentifierError>());
    }
  });

  // --- Error: duplicated parameters with more params ---

  test('Duplicated parameter among three', () {
    try {
      getIntermediateCode('f(a, b, a) = a + b');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<DuplicatedParameterError>());
    }
  });

  // --- Warnings ---

  test('Multiple unused parameters', () {
    final IntermediateCode code = getIntermediateCode(
      'f(x, y, z) = 1',
    );
    expect(code.warnings.length, equals(3));
  });

  test('All parameters used', () {
    final IntermediateCode code = getIntermediateCode(
      'f(x, y) = x + y',
    );
    expect(code.warnings.length, equals(0));
  });

  test('No parameters no warnings', () {
    final IntermediateCode code = getIntermediateCode('f = 10');
    expect(code.warnings.length, equals(0));
  });

  // --- Valid programs: recursion and composition ---

  test('Self-recursive function', () {
    final IntermediateCode code = getIntermediateCode('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(10)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Mutual recursion', () {
    final IntermediateCode code = getIntermediateCode('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(4)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Chained function calls', () {
    final IntermediateCode code = getIntermediateCode('''
double(x) = x * 2
quadruple(x) = double(double(x))
main = quadruple(3)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Multiple functions calling each other', () {
    final IntermediateCode code = getIntermediateCode('''
add(a, b) = a + b
mul(a, b) = a * b
combined(x, y) = add(mul(x, y), x)
main = combined(3, 4)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Parameter shadowing a function name', () {
    final IntermediateCode code = getIntermediateCode('''
double(x) = x * 2
apply(double, v) = double + v
main = apply(10, 5)
''');
    expect(code.warnings.length, equals(0));
  });
}
