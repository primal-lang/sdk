import 'package:dry/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Runtime', () {
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
  });
}
