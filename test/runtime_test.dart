import 'package:dry/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Runtime', () {
    test('Generic (eq)', () {
      final Runtime runtime = getRuntime('main = eq("hey", "hey")');
      checkResult(runtime, true);
    });

    test('Numbers (neq)', () {
      final Runtime runtime = getRuntime('main = neq(7, 8)');
      checkResult(runtime, true);
    });

    test('Numbers (abs)', () {
      final Runtime runtime = getRuntime('main = abs(-1)');
      checkResult(runtime, 1);
    });

    test('Numbers (inc)', () {
      final Runtime runtime = getRuntime('main = inc(2)');
      checkResult(runtime, 3);
    });

    test('Numbers (dec)', () {
      final Runtime runtime = getRuntime('main = dec(0)');
      checkResult(runtime, -1);
    });

    test('Numbers (sum)', () {
      final Runtime runtime = getRuntime('main = sum(5, -7)');
      checkResult(runtime, -2);
    });

    test('Numbers (sub)', () {
      final Runtime runtime = getRuntime('main = sub(5, -7)');
      checkResult(runtime, 12);
    });

    test('Numbers (mul)', () {
      final Runtime runtime = getRuntime('main = mul(5, -7)');
      checkResult(runtime, -35);
    });

    test('Numbers (div)', () {
      final Runtime runtime = getRuntime('main = div(5, -8)');
      checkResult(runtime, -0.625);
    });

    test('Numbers (mod)', () {
      final Runtime runtime = getRuntime('main = mod(7, 5)');
      checkResult(runtime, 2);
    });

    test('Numbers (min)', () {
      final Runtime runtime = getRuntime('main = min(7, 5)');
      checkResult(runtime, 5);
    });

    test('Numbers (max)', () {
      final Runtime runtime = getRuntime('main = max(7, 5)');
      checkResult(runtime, 7);
    });

    test('Numbers (pow)', () {
      final Runtime runtime = getRuntime('main = pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('Numbers (sqrt)', () {
      final Runtime runtime = getRuntime('main = sqrt(16)');
      checkResult(runtime, 4);
    });

    test('Numbers (round)', () {
      final Runtime runtime = getRuntime('main = round(4.8)');
      checkResult(runtime, 5);
    });

    test('Numbers (floor)', () {
      final Runtime runtime = getRuntime('main = floor(4.8)');
      checkResult(runtime, 4);
    });

    test('Numbers (ceil)', () {
      final Runtime runtime = getRuntime('main = ceil(4.2)');
      checkResult(runtime, 5);
    });

    test('Numbers (sin)', () {
      final Runtime runtime = getRuntime('main = sin(10)');
      checkResult(runtime, -0.5440211108893698);
    });

    test('Numbers (cos)', () {
      final Runtime runtime = getRuntime('main = cos(10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('Numbers (tan)', () {
      final Runtime runtime = getRuntime('main = tan(10)');
      checkResult(runtime, 0.6483608274590866);
    });

    test('Numbers (log)', () {
      final Runtime runtime = getRuntime('main = log(10)');
      checkResult(runtime, 2.302585092994046);
    });

    test('Numbers (gt)', () {
      final Runtime runtime = getRuntime('main = gt(10, 4)');
      checkResult(runtime, true);
    });

    test('Numbers (lt)', () {
      final Runtime runtime = getRuntime('main = lt(10, 4)');
      checkResult(runtime, false);
    });

    test('Numbers (ge)', () {
      final Runtime runtime = getRuntime('main = ge(10, 4)');
      checkResult(runtime, true);
    });

    test('Numbers (le)', () {
      final Runtime runtime = getRuntime('main = le(10, 10)');
      checkResult(runtime, true);
    });

    test('Numbers (isNegative)', () {
      final Runtime runtime = getRuntime('main = isNegative(-5)');
      checkResult(runtime, true);
    });

    test('Numbers (isPositive)', () {
      final Runtime runtime = getRuntime('main = isPositive(-5)');
      checkResult(runtime, false);
    });

    test('Numbers (isZero)', () {
      final Runtime runtime = getRuntime('main = isZero(0)');
      checkResult(runtime, true);
    });

    test('Numbers (isEven)', () {
      final Runtime runtime = getRuntime('main = isEven(6)');
      checkResult(runtime, true);
    });

    test('Numbers (isOdd)', () {
      final Runtime runtime = getRuntime('main = isOdd(7)');
      checkResult(runtime, true);
    });
  });
}
