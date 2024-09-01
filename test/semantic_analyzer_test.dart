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
    final IntermediateCode code =
        getIntermediateCode('isBiggerThan10(x, y) = x > 10');
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
          'isBiggerThan10(x) = x > 10\nmain = isBiggerThan10(20, 5)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  test('Valid program 1', () {
    final IntermediateCode code =
        getIntermediateCode('foo(x) = x * 2\n\nmain = foo(5)');
    expect(code.warnings.length, equals(0));
  });

  test('Valid program 2', () {
    final IntermediateCode code = getIntermediateCode(
        'bar = num.abs\n\nfoo(x) = bar()(x) * 2\n\nmain = foo(5)');
    expect(code.warnings.length, equals(0));
  });
}
