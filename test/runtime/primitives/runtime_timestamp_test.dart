import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Timestamp', () {
    test('time.now', () {
      final Runtime runtime = getRuntime('main = time.now()');
      checkDates(runtime, DateTime.now());
    });

    test('time.toIso', () {
      final Runtime runtime = getRuntime('main = time.toIso(time.now())');
      checkDates(runtime, DateTime.now());
    });

    test('time.fromIso', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime(
        'main = time.fromIso("${now.toIso8601String()}")',
      );
      checkDates(runtime, now);
    });

    test('time.year', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.year(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.year, 0));
    });

    test('time.month', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.month(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.month, 0));
    });

    test('time.day', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.day(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.day, 0));
    });

    test('time.hour', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.hour(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.hour, 0));
    });

    test('time.minute', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.minute(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.minute, 0));
    });

    test('time.second', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.second(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 1));
    });

    test('time.millisecond', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.millisecond(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 999));
    });

    test('time.epoch', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.epoch(time.now())');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(now.millisecondsSinceEpoch, 500),
      );
    });

    test('time.compare returns -1 for earlier date', () {
      final Runtime runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-02T00:00:00"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare returns 0 for equal dates', () {
      final Runtime runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 0);
    });

    test('time.compare returns 1 for later date', () {
      final Runtime runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-02T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 1);
    });
  });
}
