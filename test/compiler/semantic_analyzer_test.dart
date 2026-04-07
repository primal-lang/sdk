@Tags(['compiler'])
library;

import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
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
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'isBiggerThan10(x, y) = x > 10',
        );
    expect(intermediateRepresentation.warnings.length, equals(1));
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
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
foo(x) = x * 2
main = foo(5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Valid program 2', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
bar = num.abs
foo(x) = bar()(x) * 2
main = foo(5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Valid program 3', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
apply(f, v) = f(v)
main = apply(num.abs, 5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
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
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'f(x, y, z) = 1',
        );
    expect(intermediateRepresentation.warnings.length, equals(3));
  });

  test('All parameters used', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'f(x, y) = x + y',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('No parameters no warnings', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'f = 10',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Valid programs: recursion and composition ---

  test('Self-recursive function', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(10)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Mutual recursion', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(4)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Chained function calls', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
double(x) = x * 2
quadruple(x) = double(double(x))
main = quadruple(3)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Multiple functions calling each other', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
add(a, b) = a + b
mul(a, b) = a * b
combined(x, y) = add(mul(x, y), x)
main = combined(3, 4)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('Parameter shadowing a function name', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
double(x) = x * 2
apply(double, v) = double + v
main = apply(10, 5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
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
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = "hello"[0]',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('indexing list literal is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = [1, 2, 3][0]',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('indexing map literal is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = {"a": 1}["a"]',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Valid: identifier/call expressions (runtime checked) ---

  test('calling identifier is valid (runtime checked)', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
foo(x) = num.abs(x)
main = foo(-5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('indexing identifier is valid (runtime checked)', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
foo = [1, 2, 3]
main = foo[0]
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('calling call result is valid (runtime checked)', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
getFunc = num.abs
main = getFunc()(-5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('chained indexing on identifier is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
matrix = [[1, 2], [3, 4]]
main = matrix[0][1]
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Error: custom function conflicting with standard library ---

  test('custom function conflicts with standard library', () {
    expect(
      () => getIntermediateRepresentation('num.abs(x) = x'),
      throwsA(isA<DuplicatedFunctionError>()),
    );
  });

  test('custom function conflicts with stdlib function list.map', () {
    expect(
      () => getIntermediateRepresentation('list.map(a, b) = a'),
      throwsA(isA<DuplicatedFunctionError>()),
    );
  });

  // --- Edge cases: empty and minimal inputs ---

  test('empty input produces no functions and no warnings', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('');
    expect(intermediateRepresentation.customFunctions.isEmpty, isTrue);
    expect(intermediateRepresentation.warnings.isEmpty, isTrue);
  });

  test('single constant function', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('x = 42');
    expect(intermediateRepresentation.customFunctions.length, equals(1));
    expect(intermediateRepresentation.customFunctions.containsKey('x'), isTrue);
    expect(intermediateRepresentation.warnings.isEmpty, isTrue);
  });

  // --- IntermediateRepresentation helper methods ---

  group('IntermediateRepresentation', () {
    test('containsFunction returns true for custom function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('myFunc(x) = x * 2');
      expect(intermediateRepresentation.containsFunction('myFunc'), isTrue);
    });

    test('containsFunction returns true for stdlib function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 1');
      expect(intermediateRepresentation.containsFunction('num.abs'), isTrue);
    });

    test('containsFunction returns false for unknown function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 1');
      expect(
        intermediateRepresentation.containsFunction('unknownFunc'),
        isFalse,
      );
    });

    test('allFunctionNames includes custom and stdlib functions', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('myFunc = 1');
      final Set<String> names = intermediateRepresentation.allFunctionNames;
      expect(names.contains('myFunc'), isTrue);
      expect(names.contains('num.abs'), isTrue);
    });

    test('getCustomFunction returns function when exists', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('myFunc(x) = x + 1');
      final SemanticFunction? function = intermediateRepresentation
          .getCustomFunction('myFunc');
      expect(function, isNotNull);
      expect(function!.name, equals('myFunc'));
    });

    test('getCustomFunction returns null for unknown function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 1');
      expect(
        intermediateRepresentation.getCustomFunction('unknownFunc'),
        isNull,
      );
    });

    test('getStandardLibrarySignature returns signature when exists', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 1');
      expect(
        intermediateRepresentation.getStandardLibrarySignature('num.abs'),
        isNotNull,
      );
    });

    test('getStandardLibrarySignature returns null for unknown', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 1');
      expect(
        intermediateRepresentation.getStandardLibrarySignature('unknownFunc'),
        isNull,
      );
    });

    test('empty factory creates representation with stdlib signatures', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();
      expect(intermediateRepresentation.customFunctions.isEmpty, isTrue);
      expect(intermediateRepresentation.warnings.isEmpty, isTrue);
      expect(
        intermediateRepresentation.standardLibrarySignatures.isNotEmpty,
        isTrue,
      );
      expect(intermediateRepresentation.containsFunction('num.abs'), isTrue);
    });
  });

  // --- Identifier resolution edge cases ---

  test('function reference without call is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
double(x) = x * 2
main = double
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('stdlib function reference without call is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = num.abs');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Bound variable as callee ---

  test('parameter used as callee is valid (runtime checked)', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
apply(f, x) = f(x)
main = apply(num.abs, -5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('parameter used as callee with multiple arguments', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
apply2(f, x, y) = f(x, y)
main = apply2(num.add, 1, 2)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Undefined identifier in map key ---

  test('Undefined identifier in map key', () {
    expect(
      () => getIntermediateRepresentation('main = {z: 1}'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  // --- Deeply nested expressions ---

  test('deeply nested arithmetic expression is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = ((((1 + 2) * 3) - 4) / 5)',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('deeply nested function calls are valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
f(x) = x + 1
g(x) = x * 2
h(x) = x - 3
main = f(g(h(f(g(h(1))))))
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('undefined identifier in deeply nested expression', () {
    expect(
      () => getIntermediateRepresentation('main = 1 + (2 * (3 + z))'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  // --- Multiple functions with warnings ---

  test('multiple functions each with unused parameters', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
f(a, b) = 1
g(x, y, z) = 2
''');
    // f has 2 unused, g has 3 unused
    expect(intermediateRepresentation.warnings.length, equals(5));
  });

  // --- Warning message content verification ---

  test('unused parameter warning contains function and parameter names', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('myFunc(unusedParam) = 42');
    expect(intermediateRepresentation.warnings.length, equals(1));
    final String warningMessage =
        intermediateRepresentation.warnings.first.message;
    expect(warningMessage.contains('unusedParam'), isTrue);
    expect(warningMessage.contains('myFunc'), isTrue);
  });

  // --- Call expressions on non-identifier callees ---

  test('calling index result is valid (runtime checked)', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
funcs = [num.abs]
main = funcs[0](-5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('nested call expression as callee is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
getFunc = num.abs
main = getFunc()(-5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Complex list and map expressions ---

  test('nested list expressions are valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = [[1, 2], [3, 4], [5, 6]]');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('nested map expressions are valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = {"outer": {"inner": 1}}',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('list with function calls as elements is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = [num.abs(-1), num.abs(-2)]');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('map with function call values is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation(
          'main = {"a": num.abs(-1), "b": num.abs(-2)}',
        );
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('undefined function in list element', () {
    expect(
      () => getIntermediateRepresentation('main = [unknown()]'),
      throwsA(isA<UndefinedFunctionError>()),
    );
  });

  test('undefined function in map value', () {
    expect(
      () => getIntermediateRepresentation('main = {"key": unknown()}'),
      throwsA(isA<UndefinedFunctionError>()),
    );
  });

  // --- Parameter shadowing ---

  test('parameter shadows another custom function', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
foo = 10
bar(foo) = foo + 1
main = bar(5)
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Error message formatting with inFunction parameter ---

  test('undefined identifier error includes function context', () {
    try {
      getIntermediateRepresentation('myFunc(x) = z');
      fail('Expected UndefinedIdentifierError');
    } on UndefinedIdentifierError catch (error) {
      expect(error.message.contains('myFunc'), isTrue);
      expect(error.message.contains('z'), isTrue);
    }
  });

  test('undefined function error includes function context', () {
    try {
      getIntermediateRepresentation('myFunc = unknown()');
      fail('Expected UndefinedFunctionError');
    } on UndefinedFunctionError catch (error) {
      expect(error.message.contains('myFunc'), isTrue);
      expect(error.message.contains('unknown'), isTrue);
    }
  });

  // --- Empty list and map literals ---

  test('empty list literal is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = []');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('empty map literal is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = {}');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  // --- Conditional expression (if/else) ---

  test('if expression with valid branches is valid', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = if (true) 1 else 2');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('if expression with undefined in condition', () {
    expect(
      () => getIntermediateRepresentation('main = if (z) 1 else 2'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('if expression with undefined in then branch', () {
    expect(
      () => getIntermediateRepresentation('main = if (true) z else 2'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  test('if expression with undefined in else branch', () {
    expect(
      () => getIntermediateRepresentation('main = if (true) 1 else z'),
      throwsA(isA<UndefinedIdentifierError>()),
    );
  });

  // --- SemanticFunction structure verification ---

  test('SemanticFunction has correct parameter count', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('myFunc(a, b, c) = a + b + c');
    final SemanticFunction? function = intermediateRepresentation
        .getCustomFunction('myFunc');
    expect(function, isNotNull);
    expect(function!.parameters.length, equals(3));
  });

  test('SemanticFunction parameters preserve names', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('myFunc(alpha, beta) = alpha + beta');
    final SemanticFunction? function = intermediateRepresentation
        .getCustomFunction('myFunc');
    expect(function, isNotNull);
    expect(function!.parameters[0].name, equals('alpha'));
    expect(function.parameters[1].name, equals('beta'));
  });

  // --- Duplicate parameter edge cases ---

  test('three identical parameters throws on first duplicate', () {
    expect(
      () => getIntermediateRepresentation('f(x, x, x) = 1'),
      throwsA(isA<DuplicatedParameterError>()),
    );
  });

  test('duplicate parameter at end of list', () {
    expect(
      () => getIntermediateRepresentation('f(a, b, c, a) = 1'),
      throwsA(isA<DuplicatedParameterError>()),
    );
  });

  // --- Standard library function usage ---

  test('calling stdlib function with correct arity succeeds', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('main = num.abs(-5)');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('calling stdlib function with wrong arity fails', () {
    expect(
      () => getIntermediateRepresentation('main = num.abs(1, 2)'),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  test('calling stdlib function with zero args when it needs one', () {
    expect(
      () => getIntermediateRepresentation('main = num.abs()'),
      throwsA(isA<InvalidNumberOfArgumentsError>()),
    );
  });

  // --- Multiple functions in program ---

  test('multiple valid functions', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
add(a, b) = a + b
multiply(a, b) = a * b
subtract(a, b) = a - b
main = add(multiply(2, 3), subtract(10, 5))
''');
    expect(intermediateRepresentation.customFunctions.length, equals(4));
    expect(intermediateRepresentation.warnings.length, equals(0));
  });

  test('function order does not matter for forward references', () {
    final IntermediateRepresentation intermediateRepresentation =
        getIntermediateRepresentation('''
main = helper(5)
helper(x) = x * 2
''');
    expect(intermediateRepresentation.warnings.length, equals(0));
  });
}
