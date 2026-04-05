@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Arithmetic', () {
    test('num.abs returns same value for positive input', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(1)');
      checkResult(runtime, 1);
    });

    test('num.abs returns positive for negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(-1)');
      checkResult(runtime, 1);
    });

    test('num.negative negates positive input', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative(5)');
      checkResult(runtime, -5);
    });

    test('num.negative keeps negative input negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative(-5)');
      checkResult(runtime, -5);
    });

    test('num.inc increments positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(2)');
      checkResult(runtime, 3);
    });

    test('num.inc increments negative number', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(-2)');
      checkResult(runtime, -1);
    });

    test('num.dec decrements zero to negative one', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(0)');
      checkResult(runtime, -1);
    });

    test('num.dec decrements negative number', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(-2)');
      checkResult(runtime, -3);
    });

    test('num.add', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(5, 7)');
      checkResult(runtime, 12);
    });

    test('num.sum', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(5, 7)');
      checkResult(runtime, 12);
    });

    test('num.sub', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(5, 7)');
      checkResult(runtime, -2);
    });

    test('num.mul', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(5, 7)');
      checkResult(runtime, 35);
    });

    test('num.div', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(5, 8)');
      checkResult(runtime, 0.625);
    });

    test('num.mod', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(7, 5)');
      checkResult(runtime, 2);
    });

    test('num.min returns smaller of two positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(7, 5)');
      checkResult(runtime, 5);
    });

    test('num.min returns smaller of two negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(-7, -5)');
      checkResult(runtime, -7);
    });

    test('num.max', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(7, 5)');
      checkResult(runtime, 7);
    });

    test('num.pow raises to positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('num.pow returns one for zero exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(7, 0)');
      checkResult(runtime, 1);
    });

    test('num.pow returns fraction for negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(4, -1)');
      checkResult(runtime, 0.25);
    });

    test('num.sqrt returns square root of perfect square', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(16)');
      checkResult(runtime, 4);
    });

    test('num.sqrt returns zero for zero input', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(0)');
      checkResult(runtime, 0);
    });

    test('num.round returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.0)');
      checkResult(runtime, 4);
    });

    test('num.round rounds down below half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.4)');
      checkResult(runtime, 4);
    });

    test('num.round rounds up at half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.5)');
      checkResult(runtime, 5);
    });

    test('num.round rounds up above half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.6)');
      checkResult(runtime, 5);
    });

    test('num.floor returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(4.0)');
      checkResult(runtime, 4);
    });

    test('num.floor rounds down below half', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(4.4)');
      checkResult(runtime, 4);
    });

    test('num.floor rounds down at half', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(4.5)');
      checkResult(runtime, 4);
    });

    test('num.floor rounds down above half', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(4.6)');
      checkResult(runtime, 4);
    });

    test('num.ceil returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(4.0)');
      checkResult(runtime, 4);
    });

    test('num.ceil rounds up below half', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(4.4)');
      checkResult(runtime, 5);
    });

    test('num.ceil rounds up at half', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(4.5)');
      checkResult(runtime, 5);
    });

    test('num.ceil rounds up above half', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(4.6)');
      checkResult(runtime, 5);
    });

    test('num.sin', () {
      final RuntimeFacade runtime = getRuntime('main = num.sin(10)');
      checkResult(runtime, -0.5440211108893698);
    });

    test('num.cos', () {
      final RuntimeFacade runtime = getRuntime('main = num.cos(10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('num.tan', () {
      final RuntimeFacade runtime = getRuntime('main = num.tan(10)');
      checkResult(runtime, 0.6483608274590866);
    });

    test('num.log', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(10)');
      checkResult(runtime, 2.302585092994046);
    });

    test('num.isNegative returns false for positive input', () {
      final RuntimeFacade runtime = getRuntime('main = num.isNegative(5)');
      checkResult(runtime, false);
    });

    test('num.isNegative returns true for negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.isNegative(-5)');
      checkResult(runtime, true);
    });

    test('num.isPositive returns true for positive input', () {
      final RuntimeFacade runtime = getRuntime('main = num.isPositive(5)');
      checkResult(runtime, true);
    });

    test('num.isPositive returns false for negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.isPositive(-5)');
      checkResult(runtime, false);
    });

    test('num.isZero returns true for zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero(0)');
      checkResult(runtime, true);
    });

    test('num.isZero returns false for non-zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero(0.1)');
      checkResult(runtime, false);
    });

    test('num.isEven returns true for even number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(6)');
      checkResult(runtime, true);
    });

    test('num.isEven returns false for odd number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(7)');
      checkResult(runtime, false);
    });

    test('num.isOdd returns false for even number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(6)');
      checkResult(runtime, false);
    });

    test('num.isOdd returns true for odd number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(7)');
      checkResult(runtime, true);
    });

    test('num.asRadians converts zero degrees to zero radians', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(0)');
      checkResult(runtime, 0.0);
    });

    test('num.asRadians converts 30 degrees to pi/6', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(30)');
      expect(num.parse(runtime.executeMain()), closeTo(0.523598775598, 0.0001));
    });

    test('num.asRadians converts 180 degrees to pi', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(180)');
      expect(num.parse(runtime.executeMain()), closeTo(3.141592653589, 0.0001));
    });

    test('num.asDegrees converts zero radians to zero degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asDegrees(0)');
      checkResult(runtime, 0.0);
    });

    test('num.asDegrees converts pi/6 to 30 degrees', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(0.52359877559829887307)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(30, 0.0001));
    });

    test('num.asDegrees converts pi to 180 degrees', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(3.141592653589793)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(180, 0.0001));
    });

    test('num.infinity returns infinity value', () {
      final RuntimeFacade runtime = getRuntime('main = num.infinity()');
      checkResult(runtime, double.infinity);
    });

    test('num.infinity result is recognized as infinite', () {
      final RuntimeFacade runtime = getRuntime(
        'main = is.infinite(num.infinity())',
      );
      checkResult(runtime, true);
    });

    test('num.fraction returns zero for integer input', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction(1)');
      checkResult(runtime, 0);
    });

    test('num.fraction extracts decimal part of positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction(1.25)');
      checkResult(runtime, 0.25);
    });

    test('num.fraction extracts decimal part of negative number', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction(-1.25)');
      checkResult(runtime, 0.25);
    });

    test('num.clamp clamps value below min to min', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(0, 1, 2)');
      checkResult(runtime, 1);
    });

    test('num.clamp returns value when within range', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(2, 1, 5)');
      checkResult(runtime, 2);
    });

    test('num.clamp clamps value above max to max', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(6, 1, 5)');
      checkResult(runtime, 5);
    });

    test('num.sign returns -1 for negative number', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(-2)');
      checkResult(runtime, -1);
    });

    test('num.sign returns 0 for zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(0)');
      checkResult(runtime, 0);
    });

    test('num.sign returns 1 for positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(2)');
      checkResult(runtime, 1);
    });

    test('num.integerRandom', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(10, 20)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(10, 20));
    });

    test('num.decimalRandom', () {
      final RuntimeFacade runtime = getRuntime('main = num.decimalRandom()');
      expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1));
    });

    test('num.compare returns -1 when first is less', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(3, 7)');
      checkResult(runtime, -1);
    });

    test('num.compare returns 0 when equal', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(7, 7)');
      checkResult(runtime, 0);
    });

    test('num.compare returns 1 when first is greater', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(7, 3)');
      checkResult(runtime, 1);
    });
  });

  group('Division and Modulo Edge Cases', () {
    test('division by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = 5 / 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('/')),
          ),
        ),
      );
    });

    test('negative division by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = -5 / 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('/')),
          ),
        ),
      );
    });

    test('modulo by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = 5 % 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('%')),
          ),
        ),
      );
    });

    test('num.div by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(5, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('num.div')),
          ),
        ),
      );
    });

    test('num.mod by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(5, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Division by zero'),
              contains('num.mod'),
            ),
          ),
        ),
      );
    });
  });

  group('Numeric Edge Cases', () {
    test('num.sqrt throws InvalidNumericOperationError for negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(-1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num.sqrt'),
              contains('square root'),
              contains('negative'),
              contains('-1'),
            ),
          ),
        ),
      );
    });

    test(
      'num.sqrt throws InvalidNumericOperationError for negative decimal',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.sqrt(-4.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num.sqrt'),
                contains('negative'),
              ),
            ),
          ),
        );
      },
    );

    test('num.round negative half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(-0.5)');
      checkResult(runtime, -1);
    });

    test('num.floor negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(-4.6)');
      checkResult(runtime, -5);
    });

    test('num.ceil negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(-4.6)');
      checkResult(runtime, -4);
    });

    test('num.isPositive zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isPositive(0)');
      checkResult(runtime, false);
    });

    test('num.isNegative zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isNegative(0)');
      checkResult(runtime, false);
    });

    test('num.isZero zero decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero(0.0)');
      checkResult(runtime, true);
    });

    test('num.max both negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(-7, -5)');
      checkResult(runtime, -5);
    });

    test('decimal equals integer', () {
      final RuntimeFacade runtime = getRuntime('main = 1.0 == 1');
      checkResult(runtime, true);
    });

    test('num.sign positive decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(0.5)');
      checkResult(runtime, 1);
    });

    test('num.sign negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(-0.5)');
      checkResult(runtime, -1);
    });

    test('num.clamp value equals min', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(1, 1, 5)');
      checkResult(runtime, 1);
    });

    test('num.clamp value equals max', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(5, 1, 5)');
      checkResult(runtime, 5);
    });

    test('num.log throws InvalidNumericOperationError for zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num.log'),
              contains('logarithm'),
              contains('non-positive'),
              contains('0'),
            ),
          ),
        ),
      );
    });

    test('num.log throws InvalidNumericOperationError for negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(-5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num.log'),
              contains('logarithm'),
              contains('non-positive'),
              contains('-5'),
            ),
          ),
        ),
      );
    });

    test('num.pow(0, 0) returns 1', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(0, 0)');
      checkResult(runtime, 1);
    });

    test(
      'num.pow throws InvalidNumericOperationError for negative base with fractional exponent',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.pow(-1, 0.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num.pow'),
                contains('negative'),
                contains('fractional'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num.pow throws InvalidNumericOperationError for zero to negative power',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.pow(0, -1)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(contains('num.pow'), contains('not a finite number')),
            ),
          ),
        );
      },
    );

    test(
      'num.pow throws InvalidNumericOperationError for overflow to infinity',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.pow(10, 308.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(contains('num.pow'), contains('not a finite number')),
            ),
          ),
        );
      },
    );

    test('num.sin(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.sin(0)');
      checkResult(runtime, 0.0);
    });

    test('num.cos(0) returns 1', () {
      final RuntimeFacade runtime = getRuntime('main = num.cos(0)');
      checkResult(runtime, 1.0);
    });

    test('num.tan(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.tan(0)');
      checkResult(runtime, 0.0);
    });

    test('num.abs(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(0)');
      checkResult(runtime, 0);
    });

    test('num.negative(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative(0)');
      checkResult(runtime, 0);
    });

    test('num.fraction(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction(0)');
      checkResult(runtime, 0);
    });

    test('num.isEven(0) returns true', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(0)');
      checkResult(runtime, true);
    });

    test('num.isOdd(0) returns false', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(0)');
      checkResult(runtime, false);
    });

    test('large exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(2, 32)');
      checkResult(runtime, 4294967296);
    });

    test(
      'num.integerRandom throws InvalidNumericOperationError when max < min',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = num.integerRandom(20, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num.integerRandom'),
                contains('max'),
                contains('min'),
              ),
            ),
          ),
        );
      },
    );

    test('num.integerRandom with equal min and max returns that value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(5, 5)',
      );
      checkResult(runtime, 5);
    });
  });

  group('Arithmetic Type Errors', () {
    test('num.add throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.add("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sub throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(true, 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mul throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.div throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.div("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mod throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.pow throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.abs throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sqrt throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.round throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.round("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.ceil throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.floor throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Number literal formats', () {
    test('Integer with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main = 1_000_000');
      checkResult(runtime, 1000000);
    });

    test('Decimal with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main = 3.14_159');
      checkResult(runtime, 3.14159);
    });

    test('Scientific notation - positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e6');
      checkResult(runtime, 1e6);
    });

    test('Scientific notation - explicit positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e+6');
      checkResult(runtime, 1e6);
    });

    test('Scientific notation - negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e-3');
      checkResult(runtime, 0.001);
    });

    test('Scientific notation - decimal with exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 2.5e3');
      checkResult(runtime, 2.5e3);
    });

    test('Underscore number in arithmetic', () {
      final RuntimeFacade runtime = getRuntime('main = 1_000 + 2_000');
      checkResult(runtime, 3000);
    });

    test('Scientific notation in arithmetic', () {
      final RuntimeFacade runtime = getRuntime('main = 1e3 * 2');
      checkResult(runtime, 1e3 * 2);
    });

    test('Mixed underscore and scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main = 1_000e3');
      checkResult(runtime, 1000e3);
    });
  });
}
