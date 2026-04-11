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

    test(
      'num.clamp throws InvalidNumericOperationError when min > max',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.clamp(5, 10, 3)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num.clamp'),
                contains('min bound'),
                contains('max bound'),
              ),
            ),
          ),
        );
      },
    );

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

    test('num.inc with zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(0)');
      checkResult(runtime, 1);
    });

    test('num.dec with positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(5)');
      checkResult(runtime, 4);
    });

    test('num.sqrt with non-perfect square', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(2)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.4142135623730951, 0.0001),
      );
    });

    test('num.min with equal values', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(5, 5)');
      checkResult(runtime, 5);
    });

    test('num.max with equal values', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(5, 5)');
      checkResult(runtime, 5);
    });

    test('num.log(1) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(1)');
      checkResult(runtime, 0.0);
    });

    test('num.isEven with negative even number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(-4)');
      checkResult(runtime, true);
    });

    test('num.isOdd with negative odd number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(-3)');
      checkResult(runtime, true);
    });

    test('num.compare with decimal numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(3.5, 3.5)');
      checkResult(runtime, 0);
    });

    test('num.pow with negative base and integer exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(-2, 3)');
      checkResult(runtime, -8);
    });

    test('num.pow with negative base and even integer exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(-2, 4)');
      checkResult(runtime, 16);
    });

    test('num.mod with negative dividend', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(-7, 3)');
      checkResult(runtime, 2);
    });

    test('num.mod with negative divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(7, -3)');
      checkResult(runtime, 1);
    });

    test('num.div with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(-10, -2)');
      checkResult(runtime, 5.0);
    });

    test('num.add with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(-3, -7)');
      checkResult(runtime, -10);
    });

    test('num.sub with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(-3, -7)');
      checkResult(runtime, 4);
    });

    test('num.mul with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(-3, 7)');
      checkResult(runtime, -21);
    });

    test('num.clamp with decimal values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(2.5, 1.0, 5.0)',
      );
      checkResult(runtime, 2.5);
    });

    test('num.asRadians with negative degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(-90)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-1.5707963267948966, 0.0001),
      );
    });

    test('num.asDegrees with negative radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(-1.5707963267948966)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-90, 0.0001));
    });

    test('num.inc with decimal number', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(1.5)');
      checkResult(runtime, 2.5);
    });

    test('num.dec with decimal number', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(1.5)');
      checkResult(runtime, 0.5);
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

    test('num.sum throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.min throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.min("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.max throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sin throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.sin("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.cos throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.cos("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.tan throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.tan("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.log throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.log("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.inc throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.dec throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.negative throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.isNegative throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isNegative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.isPositive throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isPositive("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.isZero throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.isEven throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.isOdd throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sign throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.fraction throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.clamp throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp("hello", 1, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.asRadians throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.asDegrees throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = num.asDegrees("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.compare throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.integerRandom throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom("hello", 10)',
      );
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

  group('Zero Value Operations', () {
    test('num.add with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(0, 5)');
      checkResult(runtime, 5);
    });

    test('num.add with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(5, 0)');
      checkResult(runtime, 5);
    });

    test('num.add with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(0, 0)');
      checkResult(runtime, 0);
    });

    test('num.sub with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(0, 5)');
      checkResult(runtime, -5);
    });

    test('num.sub with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(5, 0)');
      checkResult(runtime, 5);
    });

    test('num.sub with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(0, 0)');
      checkResult(runtime, 0);
    });

    test('num.mul with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(0, 5)');
      checkResult(runtime, 0);
    });

    test('num.mul with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(5, 0)');
      checkResult(runtime, 0);
    });

    test('num.mul with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(0, 0)');
      checkResult(runtime, 0);
    });

    test('num.div with zero numerator', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(0, 5)');
      checkResult(runtime, 0.0);
    });

    test('num.mod with zero dividend', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(0, 5)');
      checkResult(runtime, 0);
    });

    test('num.pow with zero base and positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(0, 5)');
      checkResult(runtime, 0);
    });

    test('num.min with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(0, 5)');
      checkResult(runtime, 0);
    });

    test('num.min with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(0, -5)');
      checkResult(runtime, -5);
    });

    test('num.max with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(0, 5)');
      checkResult(runtime, 5);
    });

    test('num.max with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(0, -5)');
      checkResult(runtime, 0);
    });

    test('num.sum with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(0, 7)');
      checkResult(runtime, 7);
    });

    test('num.sum with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(7, 0)');
      checkResult(runtime, 7);
    });

    test('num.sum with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(0, 0)');
      checkResult(runtime, 0);
    });
  });

  group('Infinity Operations', () {
    test('num.negative with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.negative(num.infinity())',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num.abs with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.abs(num.negative(num.infinity()))',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.isPositive with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isPositive(num.infinity())',
      );
      checkResult(runtime, true);
    });

    test('num.isNegative with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isNegative(num.negative(num.infinity()))',
      );
      checkResult(runtime, true);
    });

    test('num.isZero with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isZero(num.infinity())',
      );
      checkResult(runtime, false);
    });

    test('num.sign with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sign(num.infinity())',
      );
      checkResult(runtime, 1);
    });

    test('num.sign with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sign(num.negative(num.infinity()))',
      );
      checkResult(runtime, -1);
    });

    test('num.min with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.min(num.infinity(), 5)',
      );
      checkResult(runtime, 5);
    });

    test('num.max with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.max(num.infinity(), 5)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.compare with equal infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(num.infinity(), num.infinity())',
      );
      checkResult(runtime, 0);
    });

    test('num.compare infinity with finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(num.infinity(), 1000000)',
      );
      checkResult(runtime, 1);
    });
  });

  group('Decimal Input Edge Cases', () {
    test('num.isEven with decimal returns true for even integer part', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(4.5)');
      checkResult(runtime, false);
    });

    test('num.isOdd with decimal returns false for even integer part', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(4.5)');
      checkResult(runtime, true);
    });

    test('num.isEven with decimal that truncates to even', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(4.9)');
      checkResult(runtime, false);
    });

    test('num.isOdd with decimal that truncates to odd', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(3.1)');
      checkResult(runtime, true);
    });

    test('num.fraction with very small decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction(1.001)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.001, 0.0001),
      );
    });

    test('num.fraction with many decimal places', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.fraction(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.141592653589793, 0.0000001),
      );
    });

    test('num.round with very close to half below', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.4999999)');
      checkResult(runtime, 4);
    });

    test('num.round with very close to half above', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(4.5000001)');
      checkResult(runtime, 5);
    });
  });

  group('Trigonometric Edge Cases', () {
    test('num.sin with negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.sin(-10)');
      checkResult(runtime, 0.5440211108893698);
    });

    test('num.cos with negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.cos(-10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('num.tan with negative input', () {
      final RuntimeFacade runtime = getRuntime('main = num.tan(-10)');
      checkResult(runtime, -0.6483608274590866);
    });

    test('num.sin with pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0, 0.0000001),
      );
    });

    test('num.cos with pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.cos(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-1, 0.0000001),
      );
    });

    test('num.sin with pi/2 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(1.5707963267948966)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1, 0.0000001),
      );
    });

    test('num.cos with pi/2 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.cos(1.5707963267948966)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0, 0.0000001),
      );
    });

    test('num.asRadians with 360 degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(360)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(6.283185307179586, 0.0001),
      );
    });

    test('num.asDegrees with 2*pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(6.283185307179586)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(360, 0.0001),
      );
    });

    test('num.asRadians with 45 degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(45)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.7853981633974483, 0.0001),
      );
    });

    test('num.asDegrees with pi/4 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(0.7853981633974483)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(45, 0.0001),
      );
    });
  });

  group('Large Number Handling', () {
    test('num.add with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(999999999999, 1)',
      );
      checkResult(runtime, 1000000000000);
    });

    test('num.sub with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sub(1000000000000, 1)',
      );
      checkResult(runtime, 999999999999);
    });

    test('num.mul with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.mul(1000000, 1000000)',
      );
      checkResult(runtime, 1000000000000);
    });

    test('num.sqrt with large perfect square', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(1000000)');
      checkResult(runtime, 1000);
    });

    test('num.log with large number', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(1000000)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(13.815510557964274, 0.0001),
      );
    });

    test('num.pow with moderate base and exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(3, 20)');
      checkResult(runtime, 3486784401);
    });
  });

  group('Small Number Handling', () {
    test('num.add with very small decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(0.0001, 0.0002)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.0003, 0.00001),
      );
    });

    test('num.sub with very small decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sub(0.0003, 0.0001)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.0002, 0.00001),
      );
    });

    test('num.mul with very small decimals', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(0.001, 0.001)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.000001, 0.0000001),
      );
    });

    test('num.div with very small result', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(1, 10000)');
      checkResult(runtime, 0.0001);
    });

    test('num.sqrt with very small input', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(0.0001)');
      checkResult(runtime, 0.01);
    });

    test('num.pow with negative exponent producing small result', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(10, -4)');
      checkResult(runtime, 0.0001);
    });
  });

  group('Comparison Edge Cases', () {
    test('num.compare with negative and positive', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(-5, 5)');
      checkResult(runtime, -1);
    });

    test('num.compare with very close decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(1.0000001, 1.0000002)',
      );
      checkResult(runtime, -1);
    });

    test('num.compare with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(0, 1)');
      checkResult(runtime, -1);
    });

    test('num.compare with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(0, -1)');
      checkResult(runtime, 1);
    });

    test('num.compare with two zeros', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(0, 0)');
      checkResult(runtime, 0);
    });

    test('num.compare with integer and equivalent decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare(5, 5.0)');
      checkResult(runtime, 0);
    });

    test('num.min with positive and negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(-3, 3)');
      checkResult(runtime, -3);
    });

    test('num.max with positive and negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(-3, 3)');
      checkResult(runtime, 3);
    });
  });

  group('Clamp Edge Cases', () {
    test('num.clamp with negative range', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(-3, -5, -1)');
      checkResult(runtime, -3);
    });

    test('num.clamp value far below range', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(-1000, 0, 100)',
      );
      checkResult(runtime, 0);
    });

    test('num.clamp value far above range', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(1000, 0, 100)',
      );
      checkResult(runtime, 100);
    });

    test('num.clamp with zero-width range', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(10, 5, 5)');
      checkResult(runtime, 5);
    });

    test('num.clamp with negative value and positive range', () {
      final RuntimeFacade runtime = getRuntime('main = num.clamp(-5, 0, 10)');
      checkResult(runtime, 0);
    });
  });

  group('Power Edge Cases', () {
    test('num.pow with one as base', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(1, 100)');
      checkResult(runtime, 1);
    });

    test('num.pow with one as exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(100, 1)');
      checkResult(runtime, 100);
    });

    test('num.pow with fractional exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(4, 0.5)');
      checkResult(runtime, 2.0);
    });

    test('num.pow with fractional base', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(0.5, 2)');
      checkResult(runtime, 0.25);
    });

    test('num.pow negative base with even exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(-3, 2)');
      checkResult(runtime, 9);
    });

    test('num.pow negative base with odd exponent', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(-3, 3)');
      checkResult(runtime, -27);
    });
  });

  group('Rounding Negative Numbers', () {
    test('num.round negative below half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(-4.4)');
      checkResult(runtime, -4);
    });

    test('num.round negative above half', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(-4.6)');
      checkResult(runtime, -5);
    });

    test('num.floor negative exact', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(-4.0)');
      checkResult(runtime, -4);
    });

    test('num.ceil negative exact', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(-4.0)');
      checkResult(runtime, -4);
    });

    test('num.ceil negative with fraction', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(-4.1)');
      checkResult(runtime, -4);
    });

    test('num.floor negative with fraction', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(-4.1)');
      checkResult(runtime, -5);
    });
  });

  group('Modulo Edge Cases', () {
    test('num.mod with equal operands', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(5, 5)');
      checkResult(runtime, 0);
    });

    test('num.mod dividend smaller than divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(3, 7)');
      checkResult(runtime, 3);
    });

    test('num.mod with decimal dividend', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(7.5, 2)');
      checkResult(runtime, 1.5);
    });

    test('num.mod with decimal divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(7, 2.5)');
      checkResult(runtime, 2.0);
    });

    test('num.mod both negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(-7, -3)');
      checkResult(runtime, 2);
    });
  });

  group('Sum Function Edge Cases', () {
    test('num.sum with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(-3, -4)');
      checkResult(runtime, -7);
    });

    test('num.sum with mixed signs', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(-3, 7)');
      checkResult(runtime, 4);
    });

    test('num.sum with decimals', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(1.5, 2.5)');
      checkResult(runtime, 4.0);
    });
  });

  group('Increment and Decrement Edge Cases', () {
    test('num.inc with large number', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(999999999)');
      checkResult(runtime, 1000000000);
    });

    test('num.dec with large number', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(1000000000)');
      checkResult(runtime, 999999999);
    });

    test('num.inc with negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc(-0.5)');
      checkResult(runtime, 0.5);
    });

    test('num.dec with positive decimal crossing zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec(0.5)');
      checkResult(runtime, -0.5);
    });
  });

  group('Logarithm Edge Cases', () {
    test('num.log with e', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.log(2.718281828459045)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.0, 0.0001),
      );
    });

    test('num.log with e squared', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.log(7.38905609893065)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(2.0, 0.0001),
      );
    });

    test('num.log with very small positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(0.001)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-6.907755278982137, 0.0001),
      );
    });
  });

  group('Sign and Negative Function Edge Cases', () {
    test('num.negative with very small positive', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative(0.001)');
      checkResult(runtime, -0.001);
    });

    test('num.negative with very small negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative(-0.001)');
      checkResult(runtime, -0.001);
    });

    test('num.sign with zero decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(0.0)');
      checkResult(runtime, 0);
    });
  });

  group('Absolute Value Edge Cases', () {
    test('num.abs with very large negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(-999999999999)');
      checkResult(runtime, 999999999999);
    });

    test('num.abs with very small negative', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(-0.0001)');
      checkResult(runtime, 0.0001);
    });

    test('num.abs with decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs(-3.14)');
      checkResult(runtime, 3.14);
    });
  });

  group('Division Edge Cases', () {
    test('num.div with same numbers', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(7, 7)');
      checkResult(runtime, 1.0);
    });

    test('num.div smaller by larger', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(1, 3)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.3333333333333333, 0.0000001),
      );
    });

    test('num.div with decimal divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(10, 2.5)');
      checkResult(runtime, 4.0);
    });

    test('num.div with decimal dividend', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(7.5, 3)');
      checkResult(runtime, 2.5);
    });
  });

  group('Sqrt Edge Cases', () {
    test('num.sqrt with 1', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(1)');
      checkResult(runtime, 1);
    });

    test('num.sqrt with large number', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(10000000000)');
      checkResult(runtime, 100000);
    });

    test('num.sqrt with decimal perfect square', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(0.25)');
      checkResult(runtime, 0.5);
    });
  });

  group('Integer Random Edge Cases', () {
    test('num.integerRandom with negative range', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(-10, -5)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(-10, -5));
    });

    test('num.integerRandom spanning zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(-5, 5)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(-5, 5));
    });

    test('num.integerRandom with consecutive numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(5, 6)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(5, 6));
    });
  });

  group('Type Error Tests for Second Arguments', () {
    test('num.add throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sub throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(1, true)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mul throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(1, [1, 2])');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.div throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mod throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.pow throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sum throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.min throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.min(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.max throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main = num.max(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.compare throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.integerRandom throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.clamp throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(5, "hello", 10)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.clamp throws for wrong type on third argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(5, 1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Additional Infinity Arithmetic', () {
    test('num.add with infinity and finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(num.infinity(), 100)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.sub with infinity and finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sub(num.infinity(), 100)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.mul with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.mul(num.infinity(), 2)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.mul with infinity and negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.mul(num.infinity(), -1)',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num.div finite by infinity returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.div(100, num.infinity())',
      );
      checkResult(runtime, 0.0);
    });

    test('num.min with negative infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.min(num.negative(num.infinity()), 5)',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num.max with negative infinity and negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.max(num.negative(num.infinity()), -5)',
      );
      checkResult(runtime, -5);
    });

    test('num.clamp value with infinity as max', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp(1000, 0, num.infinity())',
      );
      checkResult(runtime, 1000);
    });

    test('num.floor with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.floor(num.infinity())',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.ceil with negative infinity returns negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.ceil(num.negative(num.infinity()))',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num.round with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.round(num.infinity())',
      );
      checkResult(runtime, double.infinity);
    });
  });

  group('Decimal Random Tests', () {
    test('num.decimalRandom returns value in range multiple times', () {
      for (int i = 0; i < 10; i++) {
        final RuntimeFacade runtime = getRuntime('main = num.decimalRandom()');
        expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1));
      }
    });

    test('num.decimalRandom is strictly less than 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.decimalRandom() < 1',
      );
      checkResult(runtime, true);
    });

    test('num.decimalRandom is greater than or equal to 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.decimalRandom() >= 0',
      );
      checkResult(runtime, true);
    });
  });

  group('Integer Random Multiple Invocations', () {
    test('num.integerRandom returns value in range multiple times', () {
      for (int i = 0; i < 10; i++) {
        final RuntimeFacade runtime = getRuntime(
          'main = num.integerRandom(1, 100)',
        );
        expect(num.parse(runtime.executeMain()), inInclusiveRange(1, 100));
      }
    });

    test('num.integerRandom with large range', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom(0, 1000000)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1000000));
    });
  });

  group('Boundary Value Tests', () {
    test('num.pow with very small positive base', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(0.001, 2)');
      expect(num.parse(runtime.executeMain()), closeTo(0.000001, 0.0000001));
    });

    test('num.sqrt with 1 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(1)');
      checkResult(runtime, 1);
    });

    test('num.sqrt with 4 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(4)');
      checkResult(runtime, 2);
    });

    test('num.sqrt with 9 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(9)');
      checkResult(runtime, 3);
    });

    test('num.log with very large number', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(1e100)');
      expect(num.parse(runtime.executeMain()), closeTo(230.2585, 0.001));
    });

    test('num.pow with 1 as exponent returns base', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(42, 1)');
      checkResult(runtime, 42);
    });

    test('num.sign with very small positive number', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(0.0000001)');
      checkResult(runtime, 1);
    });

    test('num.sign with very small negative number', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign(-0.0000001)');
      checkResult(runtime, -1);
    });
  });

  group('Operator Precedence and Chaining', () {
    test('chained num.add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(num.add(1, 2), 3)',
      );
      checkResult(runtime, 6);
    });

    test('chained num.mul and num.add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(num.mul(2, 3), 4)',
      );
      checkResult(runtime, 10);
    });

    test('chained num.pow operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.pow(num.pow(2, 2), 2)',
      );
      checkResult(runtime, 16);
    });

    test('chained trigonometric operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(num.asRadians(90))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.0001));
    });

    test('chained min and max operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.min(num.max(5, 10), 8)',
      );
      checkResult(runtime, 8);
    });

    test('chained floor and division', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.floor(num.div(7, 2))',
      );
      checkResult(runtime, 3);
    });

    test('chained ceil and division', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.ceil(num.div(7, 2))',
      );
      checkResult(runtime, 4);
    });

    test('chained abs and negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.abs(num.negative(5))',
      );
      checkResult(runtime, 5);
    });

    test('chained inc operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.inc(num.inc(num.inc(0)))',
      );
      checkResult(runtime, 3);
    });

    test('chained dec operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.dec(num.dec(num.dec(10)))',
      );
      checkResult(runtime, 7);
    });
  });

  group('Special Value Combinations', () {
    test('num.min with both infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.min(num.infinity(), num.negative(num.infinity()))',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num.max with both infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.max(num.infinity(), num.negative(num.infinity()))',
      );
      checkResult(runtime, double.infinity);
    });

    test('num.compare positive infinity with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(num.infinity(), num.negative(num.infinity()))',
      );
      checkResult(runtime, 1);
    });

    test('num.compare negative infinity with positive infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.compare(num.negative(num.infinity()), num.infinity())',
      );
      checkResult(runtime, -1);
    });

    test('num.fraction with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.fraction(num.infinity())',
      );
      checkResult(runtime, double.nan);
    });

    test('num.mul zero times infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.mul(0, num.infinity())',
      );
      checkResult(runtime, double.nan);
    });
  });

  group('isEven and isOdd with Large Numbers', () {
    test('num.isEven with large even number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(1000000000)');
      checkResult(runtime, true);
    });

    test('num.isOdd with large odd number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(1000000001)');
      checkResult(runtime, true);
    });

    test('num.isEven with large odd number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven(999999999)');
      checkResult(runtime, false);
    });

    test('num.isOdd with large even number', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd(1000000000)');
      checkResult(runtime, false);
    });
  });

  group('Expression with Arithmetic Operators', () {
    test('addition operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = 3 + 4');
      checkResult(runtime, 7);
    });

    test('subtraction operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = 10 - 3');
      checkResult(runtime, 7);
    });

    test('multiplication operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = 3 * 4');
      checkResult(runtime, 12);
    });

    test('division operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = 10 / 2');
      checkResult(runtime, 5.0);
    });

    test('modulo operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main = 10 % 3');
      checkResult(runtime, 1);
    });

    test('combined arithmetic operators', () {
      final RuntimeFacade runtime = getRuntime('main = 2 + 3 * 4');
      checkResult(runtime, 14);
    });

    test('arithmetic operators with parentheses', () {
      final RuntimeFacade runtime = getRuntime('main = (2 + 3) * 4');
      checkResult(runtime, 20);
    });

    test('negative number in arithmetic expression', () {
      final RuntimeFacade runtime = getRuntime('main = -5 + 10');
      checkResult(runtime, 5);
    });

    test('double negative in arithmetic expression', () {
      final RuntimeFacade runtime = getRuntime('main = 10 - -5');
      checkResult(runtime, 15);
    });

    test('unary minus with parentheses', () {
      final RuntimeFacade runtime = getRuntime('main = -(3 + 4)');
      checkResult(runtime, -7);
    });
  });

  group('Comparison Operators', () {
    test('less than operator true case', () {
      final RuntimeFacade runtime = getRuntime('main = 3 < 5');
      checkResult(runtime, true);
    });

    test('less than operator false case', () {
      final RuntimeFacade runtime = getRuntime('main = 5 < 3');
      checkResult(runtime, false);
    });

    test('less than or equal operator equal case', () {
      final RuntimeFacade runtime = getRuntime('main = 5 <= 5');
      checkResult(runtime, true);
    });

    test('greater than operator true case', () {
      final RuntimeFacade runtime = getRuntime('main = 5 > 3');
      checkResult(runtime, true);
    });

    test('greater than operator false case', () {
      final RuntimeFacade runtime = getRuntime('main = 3 > 5');
      checkResult(runtime, false);
    });

    test('greater than or equal operator equal case', () {
      final RuntimeFacade runtime = getRuntime('main = 5 >= 5');
      checkResult(runtime, true);
    });

    test('equality operator with equal integers', () {
      final RuntimeFacade runtime = getRuntime('main = 5 == 5');
      checkResult(runtime, true);
    });

    test('equality operator with unequal integers', () {
      final RuntimeFacade runtime = getRuntime('main = 5 == 6');
      checkResult(runtime, false);
    });

    test('inequality operator with unequal integers', () {
      final RuntimeFacade runtime = getRuntime('main = 5 != 6');
      checkResult(runtime, true);
    });

    test('inequality operator with equal integers', () {
      final RuntimeFacade runtime = getRuntime('main = 5 != 5');
      checkResult(runtime, false);
    });
  });

  group('Arithmetic Function References', () {
    test('num.add function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.add, 5, 3)
        ''',
      );
      checkResult(runtime, 8);
    });

    test('num.mul function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.mul, 2, 7)
        ''',
      );
      checkResult(runtime, 14);
    });

    test('num.sub function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.sub, 10, 3)
        ''',
      );
      checkResult(runtime, 7);
    });

    test('num.div function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.div, 100, 4)
        ''',
      );
      checkResult(runtime, 25.0);
    });

    test('num.pow function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.pow, 2, 3)
        ''',
      );
      checkResult(runtime, 8);
    });

    test('num.min function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.min, 5, 10)
        ''',
      );
      checkResult(runtime, 5);
    });

    test('num.max function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.max, 5, 3)
        ''',
      );
      checkResult(runtime, 5);
    });

    test('num.compare function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main = applyBinaryOperation(num.compare, 5, 3)
        ''',
      );
      checkResult(runtime, 1);
    });
  });

  group('Mixed Type Expressions', () {
    test('integer and decimal addition', () {
      final RuntimeFacade runtime = getRuntime('main = 5 + 3.5');
      checkResult(runtime, 8.5);
    });

    test('integer and decimal subtraction', () {
      final RuntimeFacade runtime = getRuntime('main = 10 - 3.5');
      checkResult(runtime, 6.5);
    });

    test('integer and decimal multiplication', () {
      final RuntimeFacade runtime = getRuntime('main = 4 * 2.5');
      checkResult(runtime, 10.0);
    });

    test('integer and decimal division', () {
      final RuntimeFacade runtime = getRuntime('main = 5 / 2');
      checkResult(runtime, 2.5);
    });

    test('num.add with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(5, 3.5)');
      checkResult(runtime, 8.5);
    });

    test('num.sub with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub(10, 3.5)');
      checkResult(runtime, 6.5);
    });

    test('num.mul with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(4, 2.5)');
      checkResult(runtime, 10.0);
    });

    test('num.div with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(5, 2.5)');
      checkResult(runtime, 2.0);
    });
  });

  group('Rounding Large Numbers', () {
    test('num.round with large decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.round(999999999.5)');
      checkResult(runtime, 1000000000);
    });

    test('num.floor with large decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.floor(999999999.9)');
      checkResult(runtime, 999999999);
    });

    test('num.ceil with large decimal', () {
      final RuntimeFacade runtime = getRuntime('main = num.ceil(999999999.1)');
      checkResult(runtime, 1000000000);
    });
  });

  group('Angle Conversion Edge Cases', () {
    test('num.asRadians with 90 degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(90)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.5707963267948966, 0.0001),
      );
    });

    test('num.asDegrees with pi/2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(1.5707963267948966)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(90, 0.0001));
    });

    test('num.asRadians with 270 degrees', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(270)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(4.71238898038469, 0.0001),
      );
    });

    test('num.asDegrees with 3pi/2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(4.71238898038469)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(270, 0.0001));
    });

    test('num.asRadians preserves sign', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians(-180)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-3.141592653589793, 0.0001),
      );
    });

    test('num.asDegrees preserves sign', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.asDegrees(-3.141592653589793)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-180, 0.0001));
    });
  });

  group('Trigonometric Quadrant Tests', () {
    test('num.sin in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(num.asRadians(120))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0.866, 0.001));
    });

    test('num.cos in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.cos(num.asRadians(120))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.5, 0.001));
    });

    test('num.sin in third quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(num.asRadians(210))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.5, 0.001));
    });

    test('num.cos in third quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.cos(num.asRadians(210))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.866, 0.001));
    });

    test('num.sin in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.sin(num.asRadians(300))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.866, 0.001));
    });

    test('num.cos in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.cos(num.asRadians(300))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0.5, 0.001));
    });

    test('num.tan in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.tan(num.asRadians(135))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-1, 0.001));
    });

    test('num.tan in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.tan(num.asRadians(315))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-1, 0.001));
    });
  });

  group('Division and Modulo with Decimal Divisors', () {
    test('division by 0.5', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(5, 0.5)');
      checkResult(runtime, 10.0);
    });

    test('division by 0.1', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(1, 0.1)');
      checkResult(runtime, 10.0);
    });

    test('modulo with 0.5 divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(2.3, 0.5)');
      expect(num.parse(runtime.executeMain()), closeTo(0.3, 0.0001));
    });

    test('modulo with result close to divisor', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(0.99, 1)');
      expect(num.parse(runtime.executeMain()), closeTo(0.99, 0.0001));
    });
  });

  group('Boolean Property Functions with Decimals', () {
    test('num.isZero with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero(-0.0)');
      checkResult(runtime, true);
    });

    test('num.isPositive with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isPositive(-0.0)');
      checkResult(runtime, false);
    });

    test('num.isNegative with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main = num.isNegative(-0.0)');
      checkResult(runtime, false);
    });
  });

  group('Random Number Edge Cases', () {
    test(
      'num.integerRandom throws InvalidNumericOperationError on range overflow',
      () {
        // Use very large values that would cause range overflow
        // (max - min + 1) would overflow if > max int
        final RuntimeFacade runtime = getRuntime(
          'main = num.integerRandom(-9223372036854775808, 9223372036854775807)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              contains('range overflow'),
            ),
          ),
        );
      },
    );
  });
}
