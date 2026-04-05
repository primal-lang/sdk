@Tags(['compiler'])
library;

import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  test('Duplicated parameter', () {
    expect(
      () => getIntermediateRepresentation('isBiggerThan10(x, x) = x > 10'),
      throwsA(isA<DuplicatedParameterError>()),
    );
  });

  test('Duplicated function', () {
    expect(
      () => getIntermediateRepresentation(
        'function1(x, y) = x > 10\nfunction1(a, b) = a > 10',
      ),
      throwsA(isA<DuplicatedFunctionError>()),
    );
  });

  test('Undefined identifier 1', () {
    expect(
      () => getIntermediateRepresentation('isBiggerThan10 = z > 10'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('Undefined identifier 2', () {
    expect(
      () => getIntermediateRepresentation('isBiggerThan10 = x'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('Unused parameter', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'isBiggerThan10(x, y) = x > 10',
    );
    expect(code.warnings.length, equals(1));
  });

  test('Undefined function', () {
    expect(
      () => getIntermediateRepresentation('main = duplicate(20)'),
      throwsA(isA<UndefinedFunctionError>()),
    );
  });

  test('Invalid number of arguments', () {
    expect(
      () => getIntermediateRepresentation(
        'isBiggerThan10(x) = x > 10\nmain = isBiggerThan10(20, 5)',
      ),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  test('Valid program 1', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
foo(x) = x * 2
main = foo(5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Valid program 2', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
bar = num.abs
foo(x) = bar()(x) * 2
main = foo(5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Valid program 3', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
apply(f, v) = f(v)
main = apply(num.abs, 5)
''');
    expect(code.warnings.length, equals(0));
  });

  // --- Error: argument count mismatches ---

  test('Too few arguments', () {
    expect(
      () => getIntermediateRepresentation(
        'isBiggerThan(x, y) = x > y\nmain = isBiggerThan(20)',
      ),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  test('Zero arguments when function expects some', () {
    expect(
      () => getIntermediateRepresentation('identity(x) = x\nmain = identity()'),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  test('Arguments when function expects zero', () {
    expect(
      () => getIntermediateRepresentation('constant = 10\nmain = constant(5)'),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  // --- Error: undefined identifiers in expressions ---

  test('Undefined identifier in nested expression', () {
    expect(
      () => getIntermediateRepresentation('f(x) = x + z'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('Undefined function in nested call', () {
    expect(
      () => getIntermediateRepresentation('f(x) = unknown(x) + 1'),
      throwsA(isA<UndefinedFunctionError>()),
    );
  });

  test('Undefined identifier as function argument', () {
    expect(
      () => getIntermediateRepresentation('f(x) = x\nmain = f(z)'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('Undefined identifier in list literal', () {
    expect(
      () => getIntermediateRepresentation('main = [1, z, 3]'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('Undefined identifier in map literal', () {
    expect(
      () => getIntermediateRepresentation('main = {"key": z}'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  // --- Error: duplicated parameters with more params ---

  test('Duplicated parameter among three', () {
    expect(
      () => getIntermediateRepresentation('f(a, b, a) = a + b'),
      throwsA(isA<DuplicatedParameterError>()),
    );
  });

  // --- Warnings ---

  test('Multiple unused parameters', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'f(x, y, z) = 1',
    );
    expect(code.warnings.length, equals(3));
  });

  test('All parameters used', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'f(x, y) = x + y',
    );
    expect(code.warnings.length, equals(0));
  });

  test('No parameters no warnings', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'f = 10',
    );
    expect(code.warnings.length, equals(0));
  });

  // --- Valid programs: recursion and composition ---

  test('Self-recursive function', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(10)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Mutual recursion', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(4)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Chained function calls', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
double(x) = x * 2
quadruple(x) = double(double(x))
main = quadruple(3)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Multiple functions calling each other', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
add(a, b) = a + b
mul(a, b) = a * b
combined(x, y) = add(mul(x, y), x)
main = combined(3, 4)
''');
    expect(code.warnings.length, equals(0));
  });

  test('Parameter shadowing a function name', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
double(x) = x * 2
apply(double, v) = double + v
main = apply(10, 5)
''');
    expect(code.warnings.length, equals(0));
  });

  // --- Error: non-callable literals ---

  test('calling number literal throws NotCallableError', () {
    expect(
      () => getIntermediateRepresentation('main = 5(1)'),
      throwsA(isA<NotCallableError>()),
    );
  });

  test('calling boolean literal throws NotCallableError', () {
    expect(
      () => getIntermediateRepresentation('main = true(1)'),
      throwsA(isA<NotCallableError>()),
    );
  });

  test('calling string literal throws NotCallableError', () {
    expect(
      () => getIntermediateRepresentation('main = "hello"(1)'),
      throwsA(isA<NotCallableError>()),
    );
  });

  test('calling list literal throws NotCallableError', () {
    expect(
      () => getIntermediateRepresentation('main = [1, 2](0)'),
      throwsA(isA<NotCallableError>()),
    );
  });

  test('calling map literal throws NotCallableError', () {
    expect(
      () => getIntermediateRepresentation('main = {"a": 1}("a")'),
      throwsA(isA<NotCallableError>()),
    );
  });

  // --- Error: non-indexable literals ---

  test('indexing number literal throws NotIndexableError', () {
    expect(
      () => getIntermediateRepresentation('main = 5[0]'),
      throwsA(isA<NotIndexableError>()),
    );
  });

  test('indexing boolean literal throws NotIndexableError', () {
    expect(
      () => getIntermediateRepresentation('main = true[0]'),
      throwsA(isA<NotIndexableError>()),
    );
  });

  // --- Valid: indexable literals ---

  test('indexing string literal is valid', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'main = "hello"[0]',
    );
    expect(code.warnings.length, equals(0));
  });

  test('indexing list literal is valid', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'main = [1, 2, 3][0]',
    );
    expect(code.warnings.length, equals(0));
  });

  test('indexing map literal is valid', () {
    final IntermediateRepresentation code = getIntermediateRepresentation(
      'main = {"a": 1}["a"]',
    );
    expect(code.warnings.length, equals(0));
  });

  // --- Valid: identifier/call expressions (runtime checked) ---

  test('calling identifier is valid (runtime checked)', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
foo(x) = num.abs(x)
main = foo(-5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('indexing identifier is valid (runtime checked)', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
foo = [1, 2, 3]
main = foo[0]
''');
    expect(code.warnings.length, equals(0));
  });

  test('calling call result is valid (runtime checked)', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
getFunc = num.abs
main = getFunc()(-5)
''');
    expect(code.warnings.length, equals(0));
  });

  test('chained indexing on identifier is valid', () {
    final IntermediateRepresentation code = getIntermediateRepresentation('''
matrix = [[1, 2], [3, 4]]
main = matrix[0][1]
''');
    expect(code.warnings.length, equals(0));
  });
}
