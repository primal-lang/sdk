@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Arithmetic', () {
    test('num_abs returns same value for positive input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs(1)');
      checkResult(runtime, 1);
    });

    test('num_abs returns positive for negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs(-1)');
      checkResult(runtime, 1);
    });

    test('num_negative negates positive input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_negative(5)');
      checkResult(runtime, -5);
    });

    test('num_negative keeps negative input negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_negative(-5)');
      checkResult(runtime, -5);
    });

    test('num_inc increments positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(2)');
      checkResult(runtime, 3);
    });

    test('num_inc increments negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(-2)');
      checkResult(runtime, -1);
    });

    test('num_dec decrements zero to negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(0)');
      checkResult(runtime, -1);
    });

    test('num_dec decrements negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(-2)');
      checkResult(runtime, -3);
    });

    test('num_add', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(5, 7)');
      checkResult(runtime, 12);
    });

    test('num_sum', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(5, 7)');
      checkResult(runtime, 12);
    });

    test('num_sub', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(5, 7)');
      checkResult(runtime, -2);
    });

    test('num_mul', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(5, 7)');
      checkResult(runtime, 35);
    });

    test('num_div', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(5, 8)');
      checkResult(runtime, 0.625);
    });

    test('num_mod', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(7, 5)');
      checkResult(runtime, 2);
    });

    test('num_min returns smaller of two positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(7, 5)');
      checkResult(runtime, 5);
    });

    test('num_min returns smaller of two negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(-7, -5)');
      checkResult(runtime, -7);
    });

    test('num_max', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(7, 5)');
      checkResult(runtime, 7);
    });

    test('num_pow raises to positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('num_pow returns one for zero exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(7, 0)');
      checkResult(runtime, 1);
    });

    test('num_pow returns fraction for negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(4, -1)');
      checkResult(runtime, 0.25);
    });

    test('num_sqrt returns square root of perfect square', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(16)');
      checkResult(runtime, 4);
    });

    test('num_sqrt returns zero for zero input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(0)');
      checkResult(runtime, 0);
    });

    test('num_round returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.0)');
      checkResult(runtime, 4);
    });

    test('num_round rounds down below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.4)');
      checkResult(runtime, 4);
    });

    test('num_round rounds up at half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.5)');
      checkResult(runtime, 5);
    });

    test('num_round rounds up above half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.6)');
      checkResult(runtime, 5);
    });

    test('num_floor returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(4.0)');
      checkResult(runtime, 4);
    });

    test('num_floor rounds down below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(4.4)');
      checkResult(runtime, 4);
    });

    test('num_floor rounds down at half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(4.5)');
      checkResult(runtime, 4);
    });

    test('num_floor rounds down above half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(4.6)');
      checkResult(runtime, 4);
    });

    test('num_ceil returns same value for whole number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(4.0)');
      checkResult(runtime, 4);
    });

    test('num_ceil rounds up below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(4.4)');
      checkResult(runtime, 5);
    });

    test('num_ceil rounds up at half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(4.5)');
      checkResult(runtime, 5);
    });

    test('num_ceil rounds up above half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(4.6)');
      checkResult(runtime, 5);
    });

    test('num_sin', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sin(10)');
      checkResult(runtime, -0.5440211108893698);
    });

    test('num_cos', () {
      final RuntimeFacade runtime = getRuntime('main() = num_cos(10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('num_tan', () {
      final RuntimeFacade runtime = getRuntime('main() = num_tan(10)');
      checkResult(runtime, 0.6483608274590866);
    });

    test('num_log', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(10)');
      checkResult(runtime, 2.302585092994046);
    });

    test('num_isNegative returns false for positive input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isNegative(5)');
      checkResult(runtime, false);
    });

    test('num_isNegative returns true for negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isNegative(-5)');
      checkResult(runtime, true);
    });

    test('num_isPositive returns true for positive input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isPositive(5)');
      checkResult(runtime, true);
    });

    test('num_isPositive returns false for negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isPositive(-5)');
      checkResult(runtime, false);
    });

    test('num_isZero returns true for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero(0)');
      checkResult(runtime, true);
    });

    test('num_isZero returns false for non-zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero(0.1)');
      checkResult(runtime, false);
    });

    test('num_isEven returns true for even number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(6)');
      checkResult(runtime, true);
    });

    test('num_isEven returns false for odd number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(7)');
      checkResult(runtime, false);
    });

    test('num_isOdd returns false for even number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(6)');
      checkResult(runtime, false);
    });

    test('num_isOdd returns true for odd number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(7)');
      checkResult(runtime, true);
    });

    test('num_asRadians converts zero degrees to zero radians', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(0)');
      checkResult(runtime, 0.0);
    });

    test('num_asRadians converts 30 degrees to pi/6', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(30)');
      expect(num.parse(runtime.executeMain()), closeTo(0.523598775598, 0.0001));
    });

    test('num_asRadians converts 180 degrees to pi', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(180)');
      expect(num.parse(runtime.executeMain()), closeTo(3.141592653589, 0.0001));
    });

    test('num_asDegrees converts zero radians to zero degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asDegrees(0)');
      checkResult(runtime, 0.0);
    });

    test('num_asDegrees converts pi/6 to 30 degrees', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(0.52359877559829887307)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(30, 0.0001));
    });

    test('num_asDegrees converts pi to 180 degrees', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(3.141592653589793)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(180, 0.0001));
    });

    test('num_infinity returns infinity value', () {
      final RuntimeFacade runtime = getRuntime('main() = num_infinity()');
      checkResult(runtime, double.infinity);
    });

    test('num_infinity result is recognized as infinite', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(num_infinity())',
      );
      checkResult(runtime, true);
    });

    test('num_fraction returns zero for integer input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_fraction(1)');
      checkResult(runtime, 0);
    });

    test('num_fraction extracts decimal part of positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_fraction(1.25)');
      checkResult(runtime, 0.25);
    });

    test('num_fraction extracts decimal part of negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_fraction(-1.25)');
      checkResult(runtime, 0.25);
    });

    test('num_clamp clamps value below min to min', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(0, 1, 2)');
      checkResult(runtime, 1);
    });

    test('num_clamp returns value when within range', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(2, 1, 5)');
      checkResult(runtime, 2);
    });

    test('num_clamp clamps value above max to max', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(6, 1, 5)');
      checkResult(runtime, 5);
    });

    test('num_sign returns -1 for negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(-2)');
      checkResult(runtime, -1);
    });

    test('num_sign returns 0 for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(0)');
      checkResult(runtime, 0);
    });

    test('num_sign returns 1 for positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(2)');
      checkResult(runtime, 1);
    });

    test('num_integerRandom', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(10, 20)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(10, 20));
    });

    test('num_decimalRandom', () {
      final RuntimeFacade runtime = getRuntime('main() = num_decimalRandom()');
      expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1));
    });

    test('num_compare returns -1 when first is less', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(3, 7)');
      checkResult(runtime, -1);
    });

    test('num_compare returns 0 when equal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(7, 7)');
      checkResult(runtime, 0);
    });

    test('num_compare returns 1 when first is greater', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(7, 3)');
      checkResult(runtime, 1);
    });
  });

  group('Division and Modulo Edge Cases', () {
    test('division by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 / 0');
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
      final RuntimeFacade runtime = getRuntime('main() = -5 / 0');
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
      final RuntimeFacade runtime = getRuntime('main() = 5 % 0');
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

    test('num_div by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(5, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('num_div')),
          ),
        ),
      );
    });

    test('num_mod by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(5, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Division by zero'),
              contains('num_mod'),
            ),
          ),
        ),
      );
    });
  });

  group('Numeric Edge Cases', () {
    test('num_sqrt throws InvalidNumericOperationError for negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(-1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num_sqrt'),
              contains('square root'),
              contains('negative'),
              contains('-1'),
            ),
          ),
        ),
      );
    });

    test(
      'num_sqrt throws InvalidNumericOperationError for negative decimal',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_sqrt(-4.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num_sqrt'),
                contains('negative'),
              ),
            ),
          ),
        );
      },
    );

    test('num_round negative half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(-0.5)');
      checkResult(runtime, -1);
    });

    test('num_floor negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(-4.6)');
      checkResult(runtime, -5);
    });

    test('num_ceil negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(-4.6)');
      checkResult(runtime, -4);
    });

    test('num_isPositive zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isPositive(0)');
      checkResult(runtime, false);
    });

    test('num_isNegative zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isNegative(0)');
      checkResult(runtime, false);
    });

    test('num_isZero zero decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero(0.0)');
      checkResult(runtime, true);
    });

    test('num_max both negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(-7, -5)');
      checkResult(runtime, -5);
    });

    test('decimal equals integer', () {
      final RuntimeFacade runtime = getRuntime('main() = 1.0 == 1');
      checkResult(runtime, true);
    });

    test('num_sign positive decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(0.5)');
      checkResult(runtime, 1);
    });

    test('num_sign negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(-0.5)');
      checkResult(runtime, -1);
    });

    test('num_clamp value equals min', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(1, 1, 5)');
      checkResult(runtime, 1);
    });

    test('num_clamp value equals max', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(5, 1, 5)');
      checkResult(runtime, 5);
    });

    test(
      'num_clamp throws InvalidNumericOperationError when min > max',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_clamp(5, 10, 3)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num_clamp'),
                contains('min bound'),
                contains('max bound'),
              ),
            ),
          ),
        );
      },
    );

    test('num_log throws InvalidNumericOperationError for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num_log'),
              contains('logarithm'),
              contains('non-positive'),
              contains('0'),
            ),
          ),
        ),
      );
    });

    test('num_log throws InvalidNumericOperationError for negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(-5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num_log'),
              contains('logarithm'),
              contains('non-positive'),
              contains('-5'),
            ),
          ),
        ),
      );
    });

    test('num_pow(0, 0) returns 1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(0, 0)');
      checkResult(runtime, 1);
    });

    test(
      'num_pow throws InvalidNumericOperationError for negative base with fractional exponent',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_pow(-1, 0.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num_pow'),
                contains('negative'),
                contains('fractional'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num_pow throws InvalidNumericOperationError for zero to negative power',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_pow(0, -1)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(contains('num_pow'), contains('not a finite number')),
            ),
          ),
        );
      },
    );

    test(
      'num_pow throws InvalidNumericOperationError for overflow to infinity',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_pow(10, 308.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(contains('num_pow'), contains('not a finite number')),
            ),
          ),
        );
      },
    );

    test('num_sin(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sin(0)');
      checkResult(runtime, 0.0);
    });

    test('num_cos(0) returns 1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_cos(0)');
      checkResult(runtime, 1.0);
    });

    test('num_tan(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_tan(0)');
      checkResult(runtime, 0.0);
    });

    test('num_abs(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs(0)');
      checkResult(runtime, 0);
    });

    test('num_negative(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_negative(0)');
      checkResult(runtime, 0);
    });

    test('num_fraction(0) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_fraction(0)');
      checkResult(runtime, 0);
    });

    test('num_isEven(0) returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(0)');
      checkResult(runtime, true);
    });

    test('num_isOdd(0) returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(0)');
      checkResult(runtime, false);
    });

    test('large exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(2, 32)');
      checkResult(runtime, 4294967296);
    });

    test(
      'num_integerRandom throws InvalidNumericOperationError when max < min',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_integerRandom(20, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('num_integerRandom'),
                contains('max'),
                contains('min'),
              ),
            ),
          ),
        );
      },
    );

    test('num_integerRandom with equal min and max returns that value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(5, 5)',
      );
      checkResult(runtime, 5);
    });

    test('num_inc with zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(0)');
      checkResult(runtime, 1);
    });

    test('num_dec with positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(5)');
      checkResult(runtime, 4);
    });

    test('num_sqrt with non-perfect square', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(2)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.4142135623730951, 0.0001),
      );
    });

    test('num_min with equal values', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(5, 5)');
      checkResult(runtime, 5);
    });

    test('num_max with equal values', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(5, 5)');
      checkResult(runtime, 5);
    });

    test('num_max with decimal operands', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(1.5, 2.5)');
      checkResult(runtime, 2.5);
    });

    test('num_min with decimal operands', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(1.5, 2.5)');
      checkResult(runtime, 1.5);
    });

    test('num_ceil of zero returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(0)');
      checkResult(runtime, 0);
    });

    test('num_floor of zero returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(0)');
      checkResult(runtime, 0);
    });

    test('num_log(1) returns 0', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(1)');
      checkResult(runtime, 0.0);
    });

    test('num_isEven with negative even number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(-4)');
      checkResult(runtime, true);
    });

    test('num_isOdd with negative odd number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(-3)');
      checkResult(runtime, true);
    });

    test('num_compare with decimal numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(3.5, 3.5)',
      );
      checkResult(runtime, 0);
    });

    test('num_pow with negative base and integer exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(-2, 3)');
      checkResult(runtime, -8);
    });

    test('num_pow with negative base and even integer exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(-2, 4)');
      checkResult(runtime, 16);
    });

    test('num_mod with negative dividend', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(-7, 3)');
      checkResult(runtime, 2);
    });

    test('num_mod with negative divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(7, -3)');
      checkResult(runtime, 1);
    });

    test('num_div with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(-10, -2)');
      checkResult(runtime, 5.0);
    });

    test('num_add with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(-3, -7)');
      checkResult(runtime, -10);
    });

    test('num_sub with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(-3, -7)');
      checkResult(runtime, 4);
    });

    test('num_mul with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(-3, 7)');
      checkResult(runtime, -21);
    });

    test('num_clamp with decimal values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(2.5, 1.0, 5.0)',
      );
      checkResult(runtime, 2.5);
    });

    test('num_asRadians with negative degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(-90)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-1.5707963267948966, 0.0001),
      );
    });

    test('num_asDegrees with negative radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(-1.5707963267948966)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-90, 0.0001));
    });

    test('num_inc with decimal number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(1.5)');
      checkResult(runtime, 2.5);
    });

    test('num_dec with decimal number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(1.5)');
      checkResult(runtime, 0.5);
    });
  });

  group('Arithmetic Type Errors', () {
    test('num_add throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sub throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(true, 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_mul throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_div throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_mod throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_pow throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_abs throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sqrt throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_round throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_ceil throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_floor throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sum throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_min throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_max throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sin throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sin("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_cos throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_cos("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_tan throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_tan("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_log throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_inc throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_dec throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_negative throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_negative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_isNegative throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isNegative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_isPositive throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isPositive("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_isZero throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_isEven throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_isOdd throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sign throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_fraction throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_fraction("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_clamp throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp("hello", 1, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_asRadians throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asRadians("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_asDegrees throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_compare throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_integerRandom throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom("hello", 10)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Number literal formats', () {
    test('Integer with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_000_000');
      checkResult(runtime, 1000000);
    });

    test('Decimal with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main() = 3.14_159');
      checkResult(runtime, 3.14159);
    });

    test('Scientific notation - positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e6');
      checkResult(runtime, 1e6);
    });

    test('Scientific notation - explicit positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e+6');
      checkResult(runtime, 1e6);
    });

    test('Scientific notation - negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e-3');
      checkResult(runtime, 0.001);
    });

    test('Scientific notation - decimal with exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 2.5e3');
      checkResult(runtime, 2.5e3);
    });

    test('Underscore number in arithmetic', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_000 + 2_000');
      checkResult(runtime, 3000);
    });

    test('Scientific notation in arithmetic', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e3 * 2');
      checkResult(runtime, 1e3 * 2);
    });

    test('Mixed underscore and scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_000e3');
      checkResult(runtime, 1000e3);
    });
  });

  group('Zero Value Operations', () {
    test('num_add with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(0, 5)');
      checkResult(runtime, 5);
    });

    test('num_add with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(5, 0)');
      checkResult(runtime, 5);
    });

    test('num_add with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(0, 0)');
      checkResult(runtime, 0);
    });

    test('num_sub with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(0, 5)');
      checkResult(runtime, -5);
    });

    test('num_sub with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(5, 0)');
      checkResult(runtime, 5);
    });

    test('num_sub with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(0, 0)');
      checkResult(runtime, 0);
    });

    test('num_mul with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(0, 5)');
      checkResult(runtime, 0);
    });

    test('num_mul with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(5, 0)');
      checkResult(runtime, 0);
    });

    test('num_mul with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(0, 0)');
      checkResult(runtime, 0);
    });

    test('num_div with zero numerator', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(0, 5)');
      checkResult(runtime, 0.0);
    });

    test('num_mod with zero dividend', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(0, 5)');
      checkResult(runtime, 0);
    });

    test('num_pow with zero base and positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(0, 5)');
      checkResult(runtime, 0);
    });

    test('num_min with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(0, 5)');
      checkResult(runtime, 0);
    });

    test('num_min with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(0, -5)');
      checkResult(runtime, -5);
    });

    test('num_max with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(0, 5)');
      checkResult(runtime, 5);
    });

    test('num_max with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(0, -5)');
      checkResult(runtime, 0);
    });

    test('num_sum with zero first operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(0, 7)');
      checkResult(runtime, 7);
    });

    test('num_sum with zero second operand', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(7, 0)');
      checkResult(runtime, 7);
    });

    test('num_sum with both zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(0, 0)');
      checkResult(runtime, 0);
    });
  });

  group('Infinity Operations', () {
    test('num_negative with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_negative(num_infinity())',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_abs with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_abs(num_negative(num_infinity()))',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_isPositive with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isPositive(num_infinity())',
      );
      checkResult(runtime, true);
    });

    test('num_isNegative with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isNegative(num_negative(num_infinity()))',
      );
      checkResult(runtime, true);
    });

    test('num_isZero with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isZero(num_infinity())',
      );
      checkResult(runtime, false);
    });

    test('num_sign with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sign(num_infinity())',
      );
      checkResult(runtime, 1);
    });

    test('num_sign with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sign(num_negative(num_infinity()))',
      );
      checkResult(runtime, -1);
    });

    test('num_min with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_min(num_infinity(), 5)',
      );
      checkResult(runtime, 5);
    });

    test('num_max with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_max(num_infinity(), 5)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_compare with equal infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(num_infinity(), num_infinity())',
      );
      checkResult(runtime, 0);
    });

    test('num_compare infinity with finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(num_infinity(), 1000000)',
      );
      checkResult(runtime, 1);
    });
  });

  group('Decimal Input Edge Cases', () {
    test('num_isEven with decimal returns true for even integer part', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(4.5)');
      checkResult(runtime, false);
    });

    test('num_isOdd with decimal returns false for even integer part', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(4.5)');
      checkResult(runtime, true);
    });

    test('num_isEven with decimal that truncates to even', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven(4.9)');
      checkResult(runtime, false);
    });

    test('num_isOdd with decimal that truncates to odd', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd(3.1)');
      checkResult(runtime, true);
    });

    test('num_fraction with very small decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_fraction(1.001)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.001, 0.0001),
      );
    });

    test('num_fraction with many decimal places', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_fraction(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.141592653589793, 0.0000001),
      );
    });

    test('num_round with very close to half below', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.4999999)');
      checkResult(runtime, 4);
    });

    test('num_round with very close to half above', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(4.5000001)');
      checkResult(runtime, 5);
    });
  });

  group('Trigonometric Edge Cases', () {
    test('num_sin with negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sin(-10)');
      checkResult(runtime, 0.5440211108893698);
    });

    test('num_cos with negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_cos(-10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('num_tan with negative input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_tan(-10)');
      checkResult(runtime, -0.6483608274590866);
    });

    test('num_sin with pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0, 0.0000001),
      );
    });

    test('num_cos with pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_cos(3.141592653589793)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-1, 0.0000001),
      );
    });

    test('num_sin with pi/2 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(1.5707963267948966)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1, 0.0000001),
      );
    });

    test('num_cos with pi/2 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_cos(1.5707963267948966)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0, 0.0000001),
      );
    });

    test('num_asRadians with 360 degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(360)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(6.283185307179586, 0.0001),
      );
    });

    test('num_asDegrees with 2*pi radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(6.283185307179586)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(360, 0.0001),
      );
    });

    test('num_asRadians with 45 degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(45)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.7853981633974483, 0.0001),
      );
    });

    test('num_asDegrees with pi/4 radians', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(0.7853981633974483)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(45, 0.0001),
      );
    });
  });

  group('Large Number Handling', () {
    test('num_add with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_add(999999999999, 1)',
      );
      checkResult(runtime, 1000000000000);
    });

    test('num_sub with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sub(1000000000000, 1)',
      );
      checkResult(runtime, 999999999999);
    });

    test('num_mul with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_mul(1000000, 1000000)',
      );
      checkResult(runtime, 1000000000000);
    });

    test('num_sqrt with large perfect square', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(1000000)');
      checkResult(runtime, 1000);
    });

    test('num_log with large number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(1000000)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(13.815510557964274, 0.0001),
      );
    });

    test('num_pow with moderate base and exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(3, 20)');
      checkResult(runtime, 3486784401);
    });
  });

  group('Small Number Handling', () {
    test('num_add with very small decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_add(0.0001, 0.0002)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.0003, 0.00001),
      );
    });

    test('num_sub with very small decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sub(0.0003, 0.0001)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.0002, 0.00001),
      );
    });

    test('num_mul with very small decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_mul(0.001, 0.001)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.000001, 0.0000001),
      );
    });

    test('num_div with very small result', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(1, 10000)');
      checkResult(runtime, 0.0001);
    });

    test('num_sqrt with very small input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(0.0001)');
      checkResult(runtime, 0.01);
    });

    test('num_pow with negative exponent producing small result', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(10, -4)');
      checkResult(runtime, 0.0001);
    });
  });

  group('Comparison Edge Cases', () {
    test('num_compare with negative and positive', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(-5, 5)');
      checkResult(runtime, -1);
    });

    test('num_compare with very close decimals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(1.0000001, 1.0000002)',
      );
      checkResult(runtime, -1);
    });

    test('num_compare with zero and positive', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(0, 1)');
      checkResult(runtime, -1);
    });

    test('num_compare with zero and negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(0, -1)');
      checkResult(runtime, 1);
    });

    test('num_compare with two zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(0, 0)');
      checkResult(runtime, 0);
    });

    test('num_compare with integer and equivalent decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_compare(5, 5.0)');
      checkResult(runtime, 0);
    });

    test('num_min with positive and negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(-3, 3)');
      checkResult(runtime, -3);
    });

    test('num_max with positive and negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(-3, 3)');
      checkResult(runtime, 3);
    });
  });

  group('Clamp Edge Cases', () {
    test('num_clamp with negative range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(-3, -5, -1)',
      );
      checkResult(runtime, -3);
    });

    test('num_clamp value far below range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(-1000, 0, 100)',
      );
      checkResult(runtime, 0);
    });

    test('num_clamp value far above range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(1000, 0, 100)',
      );
      checkResult(runtime, 100);
    });

    test('num_clamp with zero-width range', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(10, 5, 5)');
      checkResult(runtime, 5);
    });

    test('num_clamp with negative value and positive range', () {
      final RuntimeFacade runtime = getRuntime('main() = num_clamp(-5, 0, 10)');
      checkResult(runtime, 0);
    });
  });

  group('Power Edge Cases', () {
    test('num_pow with one as base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(1, 100)');
      checkResult(runtime, 1);
    });

    test('num_pow with one as exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(100, 1)');
      checkResult(runtime, 100);
    });

    test('num_pow with fractional exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(4, 0.5)');
      checkResult(runtime, 2.0);
    });

    test('num_pow with fractional base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(0.5, 2)');
      checkResult(runtime, 0.25);
    });

    test('num_pow negative base with even exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(-3, 2)');
      checkResult(runtime, 9);
    });

    test('num_pow negative base with odd exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(-3, 3)');
      checkResult(runtime, -27);
    });
  });

  group('Rounding Negative Numbers', () {
    test('num_round negative below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(-4.4)');
      checkResult(runtime, -4);
    });

    test('num_round negative above half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round(-4.6)');
      checkResult(runtime, -5);
    });

    test('num_floor negative exact', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(-4.0)');
      checkResult(runtime, -4);
    });

    test('num_ceil negative exact', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(-4.0)');
      checkResult(runtime, -4);
    });

    test('num_ceil negative with fraction', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil(-4.1)');
      checkResult(runtime, -4);
    });

    test('num_floor negative with fraction', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor(-4.1)');
      checkResult(runtime, -5);
    });
  });

  group('Modulo Edge Cases', () {
    test('num_mod with equal operands', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(5, 5)');
      checkResult(runtime, 0);
    });

    test('num_mod dividend smaller than divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(3, 7)');
      checkResult(runtime, 3);
    });

    test('num_mod with decimal dividend', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(7.5, 2)');
      checkResult(runtime, 1.5);
    });

    test('num_mod with decimal divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(7, 2.5)');
      checkResult(runtime, 2.0);
    });

    test('num_mod both negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(-7, -3)');
      checkResult(runtime, 2);
    });
  });

  group('Sum Function Edge Cases', () {
    test('num_sum with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(-3, -4)');
      checkResult(runtime, -7);
    });

    test('num_sum with mixed signs', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(-3, 7)');
      checkResult(runtime, 4);
    });

    test('num_sum with decimals', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(1.5, 2.5)');
      checkResult(runtime, 4.0);
    });
  });

  group('Increment and Decrement Edge Cases', () {
    test('num_inc with large number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(999999999)');
      checkResult(runtime, 1000000000);
    });

    test('num_dec with large number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(1000000000)');
      checkResult(runtime, 999999999);
    });

    test('num_inc with negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc(-0.5)');
      checkResult(runtime, 0.5);
    });

    test('num_dec with positive decimal crossing zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec(0.5)');
      checkResult(runtime, -0.5);
    });
  });

  group('Logarithm Edge Cases', () {
    test('num_log with e', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_log(2.718281828459045)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.0, 0.0001),
      );
    });

    test('num_log with e squared', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_log(7.38905609893065)',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(2.0, 0.0001),
      );
    });

    test('num_log with very small positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(0.001)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-6.907755278982137, 0.0001),
      );
    });
  });

  group('Sign and Negative Function Edge Cases', () {
    test('num_negative with very small positive', () {
      final RuntimeFacade runtime = getRuntime('main() = num_negative(0.001)');
      checkResult(runtime, -0.001);
    });

    test('num_negative with very small negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_negative(-0.001)');
      checkResult(runtime, -0.001);
    });

    test('num_sign with zero decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(0.0)');
      checkResult(runtime, 0);
    });
  });

  group('Absolute Value Edge Cases', () {
    test('num_abs with very large negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_abs(-999999999999)',
      );
      checkResult(runtime, 999999999999);
    });

    test('num_abs with very small negative', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs(-0.0001)');
      checkResult(runtime, 0.0001);
    });

    test('num_abs with decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs(-3.14)');
      checkResult(runtime, 3.14);
    });
  });

  group('Division Edge Cases', () {
    test('num_div with same numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(7, 7)');
      checkResult(runtime, 1.0);
    });

    test('num_div smaller by larger', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(1, 3)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(0.3333333333333333, 0.0000001),
      );
    });

    test('num_div with decimal divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(10, 2.5)');
      checkResult(runtime, 4.0);
    });

    test('num_div with decimal dividend', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(7.5, 3)');
      checkResult(runtime, 2.5);
    });
  });

  group('Sqrt Edge Cases', () {
    test('num_sqrt with 1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(1)');
      checkResult(runtime, 1);
    });

    test('num_sqrt with large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sqrt(10000000000)',
      );
      checkResult(runtime, 100000);
    });

    test('num_sqrt with decimal perfect square', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(0.25)');
      checkResult(runtime, 0.5);
    });
  });

  group('Integer Random Edge Cases', () {
    test('num_integerRandom with negative range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(-10, -5)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(-10, -5));
    });

    test('num_integerRandom spanning zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(-5, 5)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(-5, 5));
    });

    test('num_integerRandom with consecutive numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(5, 6)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(5, 6));
    });
  });

  group('Type Error Tests for Second Arguments', () {
    test('num_add throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sub throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(1, true)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_mul throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(1, [1, 2])');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_div throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_mod throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_pow throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_sum throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_min throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_max throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max(1, "hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_compare throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_integerRandom throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_clamp throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(5, "hello", 10)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_clamp throws for wrong type on third argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(5, 1, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Additional Infinity Arithmetic', () {
    test('num_add with infinity and finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_add(num_infinity(), 100)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_sub with infinity and finite number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sub(num_infinity(), 100)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_mul with infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_mul(num_infinity(), 2)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_mul with infinity and negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_mul(num_infinity(), -1)',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_div finite by infinity returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_div(100, num_infinity())',
      );
      checkResult(runtime, 0.0);
    });

    test('num_min with negative infinity and positive number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_min(num_negative(num_infinity()), 5)',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_max with negative infinity and negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_max(num_negative(num_infinity()), -5)',
      );
      checkResult(runtime, -5);
    });

    test('num_clamp value with infinity as max', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp(1000, 0, num_infinity())',
      );
      checkResult(runtime, 1000);
    });

    test('num_floor with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_floor(num_infinity())',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_ceil with negative infinity returns negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_ceil(num_negative(num_infinity()))',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_round with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_round(num_infinity())',
      );
      checkResult(runtime, double.infinity);
    });
  });

  group('Decimal Random Tests', () {
    test('num_decimalRandom returns value in range multiple times', () {
      for (int i = 0; i < 10; i++) {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_decimalRandom()',
        );
        expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1));
      }
    });

    test('num_decimalRandom is strictly less than 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_decimalRandom() < 1',
      );
      checkResult(runtime, true);
    });

    test('num_decimalRandom is greater than or equal to 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_decimalRandom() >= 0',
      );
      checkResult(runtime, true);
    });
  });

  group('Integer Random Multiple Invocations', () {
    test('num_integerRandom returns value in range multiple times', () {
      for (int i = 0; i < 10; i++) {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_integerRandom(1, 100)',
        );
        expect(num.parse(runtime.executeMain()), inInclusiveRange(1, 100));
      }
    });

    test('num_integerRandom with large range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom(0, 1000000)',
      );
      expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1000000));
    });
  });

  group('Boundary Value Tests', () {
    test('num_pow with very small positive base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(0.001, 2)');
      expect(num.parse(runtime.executeMain()), closeTo(0.000001, 0.0000001));
    });

    test('num_sqrt with 1 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(1)');
      checkResult(runtime, 1);
    });

    test('num_sqrt with 4 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(4)');
      checkResult(runtime, 2);
    });

    test('num_sqrt with 9 returns integer', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(9)');
      checkResult(runtime, 3);
    });

    test('num_log with very large number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(1e100)');
      expect(num.parse(runtime.executeMain()), closeTo(230.2585, 0.001));
    });

    test('num_pow with 1 as exponent returns base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(42, 1)');
      checkResult(runtime, 42);
    });

    test('num_sign with very small positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(0.0000001)');
      checkResult(runtime, 1);
    });

    test('num_sign with very small negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign(-0.0000001)');
      checkResult(runtime, -1);
    });
  });

  group('Operator Precedence and Chaining', () {
    test('chained num_add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_add(num_add(1, 2), 3)',
      );
      checkResult(runtime, 6);
    });

    test('chained num_mul and num_add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_add(num_mul(2, 3), 4)',
      );
      checkResult(runtime, 10);
    });

    test('chained num_pow operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_pow(num_pow(2, 2), 2)',
      );
      checkResult(runtime, 16);
    });

    test('chained trigonometric operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(num_asRadians(90))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(1.0, 0.0001));
    });

    test('chained min and max operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_min(num_max(5, 10), 8)',
      );
      checkResult(runtime, 8);
    });

    test('chained floor and division', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_floor(num_div(7, 2))',
      );
      checkResult(runtime, 3);
    });

    test('chained ceil and division', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_ceil(num_div(7, 2))',
      );
      checkResult(runtime, 4);
    });

    test('chained abs and negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_abs(num_negative(5))',
      );
      checkResult(runtime, 5);
    });

    test('chained inc operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_inc(num_inc(num_inc(0)))',
      );
      checkResult(runtime, 3);
    });

    test('chained dec operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_dec(num_dec(num_dec(10)))',
      );
      checkResult(runtime, 7);
    });
  });

  group('Special Value Combinations', () {
    test('num_min with both infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_min(num_infinity(), num_negative(num_infinity()))',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_max with both infinities', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_max(num_infinity(), num_negative(num_infinity()))',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_compare positive infinity with negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(num_infinity(), num_negative(num_infinity()))',
      );
      checkResult(runtime, 1);
    });

    test('num_compare negative infinity with positive infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare(num_negative(num_infinity()), num_infinity())',
      );
      checkResult(runtime, -1);
    });

    test('num_fraction with infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_fraction(num_infinity())',
      );
      checkResult(runtime, double.nan);
    });

    test('num_mul zero times infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_mul(0, num_infinity())',
      );
      checkResult(runtime, double.nan);
    });

    test('NaN is not equal to itself', () {
      final RuntimeFacade runtime = getRuntime(
        'nan() = num_mul(0, num_infinity())\nmain() = nan() == nan()',
      );
      checkResult(runtime, false);
    });

    test('is_infinite returns false for NaN', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(num_mul(0, num_infinity()))',
      );
      checkResult(runtime, false);
    });

    test('to_string renders NaN', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_string(num_mul(0, num_infinity()))',
      );
      checkResult(runtime, '"NaN"');
    });

    test('num_max with NaN operand returns NaN', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_max(num_mul(0, num_infinity()), 5)',
      );
      checkResult(runtime, double.nan);
    });
  });

  group('Overflow and Underflow', () {
    test('multiplication overflowing the double range yields infinity', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e308 * 10');
      checkResult(runtime, double.infinity);
    });

    test('addition overflowing the double range yields infinity', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e308 + 1e308');
      checkResult(runtime, double.infinity);
    });

    test('negative multiplication overflow yields negative infinity', () {
      final RuntimeFacade runtime = getRuntime('main() = -1e308 * 10');
      checkResult(runtime, double.negativeInfinity);
    });

    test('is_infinite detects an overflowed multiplication', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(1e308 * 10)',
      );
      checkResult(runtime, true);
    });

    test('division below the smallest subnormal underflows to zero', () {
      final RuntimeFacade runtime = getRuntime('main() = 5e-324 / 2');
      checkResult(runtime, 0.0);
    });

    test('integer addition beyond 2^53 keeps full precision', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 9007199254740992 + 1 == 9007199254740992',
      );
      checkResult(runtime, false);
    });
  });

  group('isEven and isOdd with Large Numbers', () {
    test('num_isEven with large even number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isEven(1000000000)',
      );
      checkResult(runtime, true);
    });

    test('num_isOdd with large odd number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isOdd(1000000001)',
      );
      checkResult(runtime, true);
    });

    test('num_isEven with large odd number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isEven(999999999)',
      );
      checkResult(runtime, false);
    });

    test('num_isOdd with large even number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isOdd(1000000000)',
      );
      checkResult(runtime, false);
    });
  });

  group('Expression with Arithmetic Operators', () {
    test('addition operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = 3 + 4');
      checkResult(runtime, 7);
    });

    test('subtraction operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = 10 - 3');
      checkResult(runtime, 7);
    });

    test('multiplication operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = 3 * 4');
      checkResult(runtime, 12);
    });

    test('division operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = 10 / 2');
      checkResult(runtime, 5.0);
    });

    test('modulo operator with positive numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = 10 % 3');
      checkResult(runtime, 1);
    });

    test('combined arithmetic operators', () {
      final RuntimeFacade runtime = getRuntime('main() = 2 + 3 * 4');
      checkResult(runtime, 14);
    });

    test('arithmetic operators with parentheses', () {
      final RuntimeFacade runtime = getRuntime('main() = (2 + 3) * 4');
      checkResult(runtime, 20);
    });

    test('negative number in arithmetic expression', () {
      final RuntimeFacade runtime = getRuntime('main() = -5 + 10');
      checkResult(runtime, 5);
    });

    test('double negative in arithmetic expression', () {
      final RuntimeFacade runtime = getRuntime('main() = 10 - -5');
      checkResult(runtime, 15);
    });

    test('unary minus with parentheses', () {
      final RuntimeFacade runtime = getRuntime('main() = -(3 + 4)');
      checkResult(runtime, -7);
    });
  });

  group('Comparison Operators', () {
    test('less than operator true case', () {
      final RuntimeFacade runtime = getRuntime('main() = 3 < 5');
      checkResult(runtime, true);
    });

    test('less than operator false case', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 < 3');
      checkResult(runtime, false);
    });

    test('less than or equal operator equal case', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 <= 5');
      checkResult(runtime, true);
    });

    test('greater than operator true case', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 > 3');
      checkResult(runtime, true);
    });

    test('greater than operator false case', () {
      final RuntimeFacade runtime = getRuntime('main() = 3 > 5');
      checkResult(runtime, false);
    });

    test('greater than or equal operator equal case', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 >= 5');
      checkResult(runtime, true);
    });

    test('equality operator with equal integers', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 == 5');
      checkResult(runtime, true);
    });

    test('equality operator with unequal integers', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 == 6');
      checkResult(runtime, false);
    });

    test('inequality operator with unequal integers', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 != 6');
      checkResult(runtime, true);
    });

    test('inequality operator with equal integers', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 != 5');
      checkResult(runtime, false);
    });
  });

  group('Arithmetic Function References', () {
    test('num_add function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_add, 5, 3)
        ''',
      );
      checkResult(runtime, 8);
    });

    test('num_mul function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_mul, 2, 7)
        ''',
      );
      checkResult(runtime, 14);
    });

    test('num_sub function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_sub, 10, 3)
        ''',
      );
      checkResult(runtime, 7);
    });

    test('num_div function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_div, 100, 4)
        ''',
      );
      checkResult(runtime, 25.0);
    });

    test('num_pow function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_pow, 2, 3)
        ''',
      );
      checkResult(runtime, 8);
    });

    test('num_min function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_min, 5, 10)
        ''',
      );
      checkResult(runtime, 5);
    });

    test('num_max function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_max, 5, 3)
        ''',
      );
      checkResult(runtime, 5);
    });

    test('num_compare function reference', () {
      final RuntimeFacade runtime = getRuntime(
        '''
        applyBinaryOperation(operation, firstNumber, secondNumber) = operation(firstNumber, secondNumber)
        main() = applyBinaryOperation(num_compare, 5, 3)
        ''',
      );
      checkResult(runtime, 1);
    });
  });

  group('Mixed Type Expressions', () {
    test('integer and decimal addition', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 + 3.5');
      checkResult(runtime, 8.5);
    });

    test('integer and decimal subtraction', () {
      final RuntimeFacade runtime = getRuntime('main() = 10 - 3.5');
      checkResult(runtime, 6.5);
    });

    test('integer and decimal multiplication', () {
      final RuntimeFacade runtime = getRuntime('main() = 4 * 2.5');
      checkResult(runtime, 10.0);
    });

    test('integer and decimal division', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 / 2');
      checkResult(runtime, 2.5);
    });

    test('num_add with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(5, 3.5)');
      checkResult(runtime, 8.5);
    });

    test('num_sub with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub(10, 3.5)');
      checkResult(runtime, 6.5);
    });

    test('num_mul with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(4, 2.5)');
      checkResult(runtime, 10.0);
    });

    test('num_div with integer and decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(5, 2.5)');
      checkResult(runtime, 2.0);
    });
  });

  group('Rounding Large Numbers', () {
    test('num_round with large decimal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_round(999999999.5)',
      );
      checkResult(runtime, 1000000000);
    });

    test('num_floor with large decimal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_floor(999999999.9)',
      );
      checkResult(runtime, 999999999);
    });

    test('num_ceil with large decimal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_ceil(999999999.1)',
      );
      checkResult(runtime, 1000000000);
    });
  });

  group('Angle Conversion Edge Cases', () {
    test('num_asRadians with 90 degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(90)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(1.5707963267948966, 0.0001),
      );
    });

    test('num_asDegrees with pi/2', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(1.5707963267948966)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(90, 0.0001));
    });

    test('num_asRadians with 270 degrees', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(270)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(4.71238898038469, 0.0001),
      );
    });

    test('num_asDegrees with 3pi/2', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(4.71238898038469)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(270, 0.0001));
    });

    test('num_asRadians preserves sign', () {
      final RuntimeFacade runtime = getRuntime('main() = num_asRadians(-180)');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(-3.141592653589793, 0.0001),
      );
    });

    test('num_asDegrees preserves sign', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees(-3.141592653589793)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-180, 0.0001));
    });
  });

  group('Trigonometric Quadrant Tests', () {
    test('num_sin in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(num_asRadians(120))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0.866, 0.001));
    });

    test('num_cos in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_cos(num_asRadians(120))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.5, 0.001));
    });

    test('num_sin in third quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(num_asRadians(210))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.5, 0.001));
    });

    test('num_cos in third quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_cos(num_asRadians(210))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.866, 0.001));
    });

    test('num_sin in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_sin(num_asRadians(300))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-0.866, 0.001));
    });

    test('num_cos in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_cos(num_asRadians(300))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(0.5, 0.001));
    });

    test('num_tan in second quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_tan(num_asRadians(135))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-1, 0.001));
    });

    test('num_tan in fourth quadrant', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_tan(num_asRadians(315))',
      );
      expect(num.parse(runtime.executeMain()), closeTo(-1, 0.001));
    });
  });

  group('Division and Modulo with Decimal Divisors', () {
    test('division by 0.5', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(5, 0.5)');
      checkResult(runtime, 10.0);
    });

    test('division by 0.1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(1, 0.1)');
      checkResult(runtime, 10.0);
    });

    test('modulo with 0.5 divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(2.3, 0.5)');
      expect(num.parse(runtime.executeMain()), closeTo(0.3, 0.0001));
    });

    test('modulo with result close to divisor', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(0.99, 1)');
      expect(num.parse(runtime.executeMain()), closeTo(0.99, 0.0001));
    });
  });

  group('Boolean Property Functions with Decimals', () {
    test('num_isZero with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero(-0.0)');
      checkResult(runtime, true);
    });

    test('num_isPositive with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isPositive(-0.0)');
      checkResult(runtime, false);
    });

    test('num_isNegative with negative zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isNegative(-0.0)');
      checkResult(runtime, false);
    });
  });

  group('Random Number Edge Cases', () {
    test(
      'num_integerRandom throws InvalidNumericOperationError on range overflow',
      () {
        // Use very large values that would cause range overflow
        // (max - min + 1) would overflow if > max int
        final RuntimeFacade runtime = getRuntime(
          'main() = num_integerRandom(-9223372036854775808, 9223372036854775807)',
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

  group('num_logBase', () {
    test('num_logBase returns correct result for base 2', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(8, 2)');
      checkResult(runtime, 3.0);
    });

    test('num_logBase returns correct result for base 10', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_logBase(1000, 10)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(3.0, 0.0001));
    });

    test('num_logBase returns 1 when value equals base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(5, 5)');
      checkResult(runtime, 1.0);
    });

    test('num_logBase returns 0 when value is 1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(1, 10)');
      checkResult(runtime, 0.0);
    });

    test('num_logBase with fractional result', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(2, 4)');
      expect(num.parse(runtime.executeMain()), closeTo(0.5, 0.0001));
    });

    test('num_logBase with decimal base', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(4, 0.5)');
      expect(num.parse(runtime.executeMain()), closeTo(-2.0, 0.0001));
    });

    test(
      'num_logBase throws InvalidNumericOperationError for non-positive value',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_logBase(0, 2)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              allOf(
                contains('num_logBase'),
                contains('non-positive'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num_logBase throws InvalidNumericOperationError for negative value',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_logBase(-5, 2)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              allOf(
                contains('num_logBase'),
                contains('non-positive'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num_logBase throws InvalidNumericOperationError for non-positive base',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_logBase(8, 0)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              allOf(
                contains('num_logBase'),
                contains('base'),
                contains('positive'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num_logBase throws InvalidNumericOperationError for negative base',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_logBase(8, -2)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              allOf(
                contains('num_logBase'),
                contains('base'),
                contains('positive'),
              ),
            ),
          ),
        );
      },
    );

    test('num_logBase throws InvalidNumericOperationError for base 1', () {
      final RuntimeFacade runtime = getRuntime('main() = num_logBase(8, 1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (Exception exception) => exception.toString(),
            'message',
            allOf(
              contains('num_logBase'),
              contains('base'),
              contains('1'),
            ),
          ),
        ),
      );
    });

    test('num_logBase throws for wrong type on first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_logBase("hello", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_logBase throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_logBase(8, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('num_truncate', () {
    test('num_truncate returns same value for positive integer', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(5)');
      checkResult(runtime, 5);
    });

    test('num_truncate returns same value for negative integer', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(-5)');
      checkResult(runtime, -5);
    });

    test('num_truncate truncates positive decimal toward zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(3.7)');
      checkResult(runtime, 3);
    });

    test('num_truncate truncates negative decimal toward zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(-3.7)');
      checkResult(runtime, -3);
    });

    test('num_truncate with positive decimal below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(3.2)');
      checkResult(runtime, 3);
    });

    test('num_truncate with negative decimal below half', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(-3.2)');
      checkResult(runtime, -3);
    });

    test('num_truncate with zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(0)');
      checkResult(runtime, 0);
    });

    test('num_truncate with zero decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(0.0)');
      checkResult(runtime, 0);
    });

    test('num_truncate with positive infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_truncate(num_infinity())',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_truncate with negative infinity returns negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_truncate(num_negative(num_infinity()))',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('num_truncate with very small positive decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = num_truncate(0.9999)');
      checkResult(runtime, 0);
    });

    test('num_truncate with very small negative decimal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_truncate(-0.9999)',
      );
      checkResult(runtime, 0);
    });

    test('num_truncate throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_truncate("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('num_roundTo', () {
    test('num_roundTo with 0 decimal places', () {
      final RuntimeFacade runtime = getRuntime('main() = num_roundTo(3.7, 0)');
      checkResult(runtime, 4.0);
    });

    test('num_roundTo with 1 decimal place', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.14159, 1)',
      );
      checkResult(runtime, 3.1);
    });

    test('num_roundTo with 2 decimal places', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.14159, 2)',
      );
      checkResult(runtime, 3.14);
    });

    test('num_roundTo with 3 decimal places', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.14159, 3)',
      );
      checkResult(runtime, 3.142);
    });

    test('num_roundTo rounds up at half', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.145, 2)',
      );
      checkResult(runtime, 3.15);
    });

    test('num_roundTo rounds down below half', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.144, 2)',
      );
      checkResult(runtime, 3.14);
    });

    test('num_roundTo with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(-3.14159, 2)',
      );
      checkResult(runtime, -3.14);
    });

    test('num_roundTo with negative number rounds toward negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(-3.145, 2)',
      );
      checkResult(runtime, -3.15);
    });

    test('num_roundTo with integer input', () {
      final RuntimeFacade runtime = getRuntime('main() = num_roundTo(5, 2)');
      checkResult(runtime, 5.0);
    });

    test('num_roundTo with zero', () {
      final RuntimeFacade runtime = getRuntime('main() = num_roundTo(0, 2)');
      checkResult(runtime, 0.0);
    });

    test('num_roundTo with infinity returns infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(num_infinity(), 2)',
      );
      checkResult(runtime, double.infinity);
    });

    test('num_roundTo with negative infinity returns negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(num_negative(num_infinity()), 2)',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test(
      'num_roundTo with decimal places parameter as decimal truncates it',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_roundTo(3.14159, 2.9)',
        );
        checkResult(runtime, 3.14);
      },
    );

    test(
      'num_roundTo throws InvalidNumericOperationError for negative decimal places',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_roundTo(3.14159, -1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (Exception exception) => exception.toString(),
              'message',
              allOf(
                contains('num_roundTo'),
                contains('decimal places'),
                contains('negative'),
              ),
            ),
          ),
        );
      },
    );

    test('num_roundTo throws for wrong type on first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo("hello", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num_roundTo throws for wrong type on second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_roundTo(3.14159, "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });
}
