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
  });
}
