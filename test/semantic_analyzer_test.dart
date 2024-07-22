import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  test('Duplicated parameter', () {
    try {
      getIntermediateCode('isBiggerThan10(x, x) = gt(x, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<DuplicatedParameterError>());
    }
  });

  test('Duplicated function', () {
    try {
      getIntermediateCode(
          'function1(x, y) = gt(x, 10)\nfunction1(a, b) = gt(a, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<DuplicatedFunctionError>());
    }
  });

  test('Undefined symbol 1', () {
    try {
      getIntermediateCode('isBiggerThan10 = gt(z, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedSymbolError>());
    }
  });

  test('Undefined symbol 2', () {
    try {
      getIntermediateCode('isBiggerThan10 = x');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UndefinedSymbolError>());
    }
  });

  test('Unused parameter', () {
    try {
      getIntermediateCode('isBiggerThan10(x, y) = gt(x, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnusedParameterError>());
    }
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
          'isBiggerThan10(x) = gt(x, 10)\nmain = isBiggerThan10(20, 5)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<InvalidNumberOfArgumentsError>());
    }
  });

  /*test('Check result', () {
    final IntermediateCode code = getIntermediateCode('main = abs(-10)');
    checkCode(code, 10);
  });*/
}
