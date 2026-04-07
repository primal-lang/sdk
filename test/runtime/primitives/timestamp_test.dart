@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Timestamp', () {
    test('time.now', () {
      final RuntimeFacade runtime = getRuntime('main = time.now()');
      checkDates(runtime, DateTime.now());
    });

    test('time.toIso', () {
      final RuntimeFacade runtime = getRuntime('main = time.toIso(time.now())');
      checkDates(runtime, DateTime.now());
    });

    test('time.fromIso', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main = time.fromIso("${now.toIso8601String()}")',
      );
      checkDates(runtime, now);
    });

    test('time.fromIso throws for invalid ISO string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.fromIso("not-a-date")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('time.year', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main = time.year(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.year, 0));
    });

    test('time.month', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main = time.month(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.month, 0));
    });

    test('time.day', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main = time.day(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.day, 0));
    });

    test('time.hour', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main = time.hour(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.hour, 0));
    });

    test('time.minute', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main = time.minute(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.minute, 0));
    });

    test('time.second', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main = time.second(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 1));
    });

    test('time.millisecond', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main = time.millisecond(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 999));
    });

    test('time.epoch', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main = time.epoch(time.now())');
      expect(
        num.parse(runtime.executeMain()),
        closeTo(now.millisecondsSinceEpoch, 500),
      );
    });

    test('time.compare returns -1 for earlier date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-02T00:00:00"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare returns 0 for equal dates', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 0);
    });

    test('time.compare returns 1 for later date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-09-02T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Edge Cases', () {
    test('time.year extracts correct year from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.year(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.month extracts correct month from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.month(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 6);
    });

    test('time.day extracts correct day from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.day(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 15);
    });

    test('time.hour extracts correct hour from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.hour(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 10);
    });

    test('time.minute extracts correct minute from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.minute(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 30);
    });

    test('time.second extracts correct second from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.second(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 45);
    });

    test('time.millisecond extracts correct millisecond from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.millisecond(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 500);
    });

    test('time.epoch returns correct value for Unix epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.epoch(time.fromIso("1970-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.toIso roundtrips with time.fromIso', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.toIso(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, '"2024-06-15T10:30:45.500Z"');
    });

    test('time.fromIso handles date without timezone', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.year(time.fromIso("2024-06-15T10:30:45"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.compare with millisecond precision', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare(time.fromIso("2024-01-01T00:00:00.001Z"), time.fromIso("2024-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Type Errors', () {
    test('time.toIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.toIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.toIso("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.fromIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.year(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.year("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.month(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.day(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.hour(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.minute(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.second(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.millisecond(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.epoch throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = time.epoch(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main = time.compare(123, 456)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare("hello", time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.compare(time.now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
