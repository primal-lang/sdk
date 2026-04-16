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
      final RuntimeFacade runtime = getRuntime('main() = time.now()');
      checkDates(runtime, DateTime.now());
    });

    test('time.toIso', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.toIso(time.now())',
      );
      checkDates(runtime, DateTime.now());
    });

    test('time.fromIso', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("${now.toIso8601String()}")',
      );
      checkDates(runtime, now);
    });

    test('time.fromIso throws for invalid ISO string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("not-a-date")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('time.year', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.year, 0));
    });

    test('time.month', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.month, 0));
    });

    test('time.day', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main() = time.day(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.day, 0));
    });

    test('time.hour', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.hour, 0));
    });

    test('time.minute', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.minute, 0));
    });

    test('time.second', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 1));
    });

    test('time.millisecond', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 999));
    });

    test('timestamp.toEpoch', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.now())',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(now.millisecondsSinceEpoch, 500),
      );
    });

    test('time.compare returns -1 for earlier date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-02T00:00:00"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare returns 0 for equal dates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 0);
    });

    test('time.compare returns 1 for later date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-09-02T00:00:00"), time.fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Edge Cases', () {
    test('time.year extracts correct year from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.month extracts correct month from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 6);
    });

    test('time.day extracts correct day from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 15);
    });

    test('time.hour extracts correct hour from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 10);
    });

    test('time.minute extracts correct minute from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 30);
    });

    test('time.second extracts correct second from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 45);
    });

    test('time.millisecond extracts correct millisecond from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 500);
    });

    test('timestamp.toEpoch returns correct value for Unix epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.toIso roundtrips with time.fromIso', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.toIso(time.fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, '"2024-06-15T10:30:45.500Z"');
    });

    test('time.fromIso handles date without timezone', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("2024-06-15T10:30:45"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.compare with millisecond precision', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00.001Z"), time.fromIso("2024-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Type Errors', () {
    test('time.toIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.toIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.toIso("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.toIso([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.toIso(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso(["2024-01-01"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.minute(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.minute("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.minute(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.second(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.second("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.second(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare("hello", time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for list first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare([1, 2], time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for list second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.now(), [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(true, time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.now(), false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Boundary Values', () {
    test('time.month returns 1 for January', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month(time.fromIso("2024-01-15T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.month returns 12 for December', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month(time.fromIso("2024-12-15T00:00:00Z"))',
      );
      checkResult(runtime, 12);
    });

    test('time.day returns 1 for first day of month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-06-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.day returns 31 for last day of 31-day month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-01-31T00:00:00Z"))',
      );
      checkResult(runtime, 31);
    });

    test('time.day returns 30 for last day of 30-day month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-04-30T00:00:00Z"))',
      );
      checkResult(runtime, 30);
    });

    test('time.day returns 29 for leap year February', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-02-29T00:00:00Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time.day returns 28 for non-leap year February', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2023-02-28T00:00:00Z"))',
      );
      checkResult(runtime, 28);
    });

    test('time.hour returns 0 for midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T00:30:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.hour returns 23 for last hour of day', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T23:30:00Z"))',
      );
      checkResult(runtime, 23);
    });

    test('time.minute returns 0 for start of hour', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute(time.fromIso("2024-06-15T10:00:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.minute returns 59 for last minute of hour', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute(time.fromIso("2024-06-15T10:59:00Z"))',
      );
      checkResult(runtime, 59);
    });

    test('time.second returns 0 for start of minute', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second(time.fromIso("2024-06-15T10:30:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.second returns 59 for last second of minute', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second(time.fromIso("2024-06-15T10:30:59Z"))',
      );
      checkResult(runtime, 59);
    });

    test('time.millisecond returns 0 for no milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.millisecond returns 999 for max milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.999Z"))',
      );
      checkResult(runtime, 999);
    });
  });

  group('Timestamp Parse Error Cases', () {
    test('time.fromIso throws for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso("")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for partial date string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("2024-06")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for year-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso("2024")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for malformed date with invalid separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("2024/06/15T10:30:00Z")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for time without date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("10:30:00")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for random text', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso("hello world")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time.fromIso throws for whitespace string', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso("   ")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });
  });

  group('Timestamp ISO Format Variations', () {
    test('time.fromIso handles date with positive timezone offset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T10:30:00+05:00"))',
      );
      checkResult(runtime, 5);
    });

    test('time.fromIso handles date with negative timezone offset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T10:30:00-08:00"))',
      );
      checkResult(runtime, 18);
    });

    test('time.fromIso handles date with Z suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("2024-06-15T10:30:00Z"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.fromIso handles date without timezone marker', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("2024-06-15T10:30:00"))',
      );
      checkResult(runtime, 2024);
    });

    test('time.fromIso handles date with microseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.123456Z"))',
      );
      checkResult(runtime, 123);
    });

    test('time.fromIso handles date with single digit milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.1Z"))',
      );
      checkResult(runtime, 100);
    });

    test('time.fromIso handles date with two digit milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T10:30:45.12Z"))',
      );
      checkResult(runtime, 120);
    });
  });

  group('Timestamp Special Dates', () {
    test(
      'timestamp.toEpoch returns negative value for date before Unix epoch',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = timestamp.toEpoch(time.fromIso("1969-12-31T23:59:59.000Z"))',
        );
        checkResult(runtime, -1000);
      },
    );

    test('time.year handles year 1 AD', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("0001-01-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.year handles far future year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromIso("9999-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 9999);
    });

    test('timestamp.toEpoch handles new year transition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.day handles end of year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 31);
    });

    test('time.month handles leap year February 29', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.month(time.fromIso("2024-02-29T12:00:00Z"))',
      );
      checkResult(runtime, 2);
    });

    test('time.year handles year 2000 leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2000-02-29T12:00:00Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time.year handles century non-leap year 1900', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("1900-02-28T12:00:00Z"))',
      );
      checkResult(runtime, 28);
    });
  });

  group('Timestamp Compare Edge Cases', () {
    test('time.compare returns 0 for same timestamp via different paths', () {
      final RuntimeFacade runtime = getRuntime('''
timestamp() = time.fromIso("2024-06-15T10:30:00.000Z")
main() = time.compare(timestamp(), time.fromIso(time.toIso(timestamp())))
''');
      checkResult(runtime, 0);
    });

    test('time.compare detects microsecond differences when rounded', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00.001Z"), time.fromIso("2024-01-01T00:00:00.002Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles timestamps one second apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:01Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles timestamps one minute apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-01T00:01:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles timestamps one hour apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-01T01:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles timestamps one day apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-02T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles timestamps one year apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2025-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare handles epoch boundaries', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("1969-12-31T23:59:59Z"), time.fromIso("1970-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });
  });

  group('Timestamp Composition', () {
    test('time.toIso followed by time.fromIso preserves timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
original() = time.fromIso("2024-06-15T10:30:45.123Z")
roundtrip() = time.fromIso(time.toIso(original()))
main() = time.compare(original(), roundtrip())
''');
      checkResult(runtime, 0);
    });

    test('extracting all components from a known timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-06-15T10:30:45.500Z")
main() = [time.year(t()), time.month(t()), time.day(t()), time.hour(t()), time.minute(t()), time.second(t()), time.millisecond(t())]
''');
      checkResult(runtime, [2024, 6, 15, 10, 30, 45, 500]);
    });

    test('timestamp.toEpoch and components are consistent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T00:00:01.000Z"))',
      );
      checkResult(runtime, 1000);
    });

    test('time.now returns increasing values', () {
      final RuntimeFacade runtime = getRuntime('''
first() = time.now()
second() = time.now()
main() = time.compare(first(), second()) <= 0
''');
      checkResult(runtime, true);
    });
  });

  group('Timestamp Additional Type Errors', () {
    test('time.fromIso throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso(time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.toIso(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso(num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.minute(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.second(num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for function first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(num.abs, time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for function second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.now(), num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for both arguments being functions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(num.abs, num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.toIso({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromIso({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.day throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for map first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare({"a": 1}, time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare throws for map second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.now(), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Midnight and Day Boundary', () {
    test('time.hour returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.hour(time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.minute returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.minute(time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.second returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.second(time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time.millisecond returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.millisecond(time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time components at one millisecond before midnight', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-06-14T23:59:59.999Z")
main() = [time.hour(t()), time.minute(t()), time.second(t()), time.millisecond(t())]
''');
      checkResult(runtime, [23, 59, 59, 999]);
    });

    test('time.compare across midnight boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-06-14T23:59:59.999Z"), time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.compare at exact same midnight returns 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-06-15T00:00:00.000Z"), time.fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Timestamp Year Boundary', () {
    test('time components at start of year', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-01-01T00:00:00.000Z")
main() = [time.year(t()), time.month(t()), time.day(t())]
''');
      checkResult(runtime, [2024, 1, 1]);
    });

    test('time components at end of year', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-12-31T23:59:59.999Z")
main() = [time.year(t()), time.month(t()), time.day(t())]
''');
      checkResult(runtime, [2024, 12, 31]);
    });

    test('time.compare across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("2024-12-31T23:59:59.999Z"), time.fromIso("2025-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time.day for February 29 in non-century leap year 2024', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2024-02-29T12:00:00.000Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time.day for February 29 in century leap year 2000', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.day(time.fromIso("2000-02-29T12:00:00.000Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time.month handles all 12 months', () {
      final RuntimeFacade runtime = getRuntime('''
months() = [
  time.month(time.fromIso("2024-01-15T00:00:00Z")),
  time.month(time.fromIso("2024-02-15T00:00:00Z")),
  time.month(time.fromIso("2024-03-15T00:00:00Z")),
  time.month(time.fromIso("2024-04-15T00:00:00Z")),
  time.month(time.fromIso("2024-05-15T00:00:00Z")),
  time.month(time.fromIso("2024-06-15T00:00:00Z")),
  time.month(time.fromIso("2024-07-15T00:00:00Z")),
  time.month(time.fromIso("2024-08-15T00:00:00Z")),
  time.month(time.fromIso("2024-09-15T00:00:00Z")),
  time.month(time.fromIso("2024-10-15T00:00:00Z")),
  time.month(time.fromIso("2024-11-15T00:00:00Z")),
  time.month(time.fromIso("2024-12-15T00:00:00Z"))
]
main() = months()
''');
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    });
  });

  group('Timestamp Epoch Edge Cases', () {
    test('timestamp.toEpoch for one millisecond after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T00:00:00.001Z"))',
      );
      checkResult(runtime, 1);
    });

    test('timestamp.toEpoch for one millisecond before epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1969-12-31T23:59:59.999Z"))',
      );
      checkResult(runtime, -1);
    });

    test('timestamp.toEpoch for exactly one second after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T00:00:01.000Z"))',
      );
      checkResult(runtime, 1000);
    });

    test('timestamp.toEpoch for exactly one minute after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T00:01:00.000Z"))',
      );
      checkResult(runtime, 60000);
    });

    test('timestamp.toEpoch for exactly one hour after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-01T01:00:00.000Z"))',
      );
      checkResult(runtime, 3600000);
    });

    test('timestamp.toEpoch for exactly one day after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1970-01-02T00:00:00.000Z"))',
      );
      checkResult(runtime, 86400000);
    });

    test('timestamp.toEpoch for date far in past (1900)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("1900-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, -2208988800000);
    });

    test('timestamp.toEpoch for large future date (year 3000)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("3000-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 32503680000000);
    });
  });

  group('Timestamp Now Function Tests', () {
    test('time.now returns valid year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.now()) >= 2024',
      );
      checkResult(runtime, true);
    });

    test('time.now returns valid month between 1 and 12', () {
      final RuntimeFacade runtime = getRuntime('''
m() = time.month(time.now())
main() = m() >= 1 && m() <= 12
''');
      checkResult(runtime, true);
    });

    test('time.now returns valid day between 1 and 31', () {
      final RuntimeFacade runtime = getRuntime('''
d() = time.day(time.now())
main() = d() >= 1 && d() <= 31
''');
      checkResult(runtime, true);
    });

    test('time.now returns valid hour between 0 and 23', () {
      final RuntimeFacade runtime = getRuntime('''
h() = time.hour(time.now())
main() = h() >= 0 && h() <= 23
''');
      checkResult(runtime, true);
    });

    test('time.now returns valid minute between 0 and 59', () {
      final RuntimeFacade runtime = getRuntime('''
m() = time.minute(time.now())
main() = m() >= 0 && m() <= 59
''');
      checkResult(runtime, true);
    });

    test('time.now returns valid second between 0 and 59', () {
      final RuntimeFacade runtime = getRuntime('''
s() = time.second(time.now())
main() = s() >= 0 && s() <= 59
''');
      checkResult(runtime, true);
    });

    test('time.now returns valid millisecond between 0 and 999', () {
      final RuntimeFacade runtime = getRuntime('''
ms() = time.millisecond(time.now())
main() = ms() >= 0 && ms() <= 999
''');
      checkResult(runtime, true);
    });

    test('time.now returns positive epoch for current time', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.now()) > 0',
      );
      checkResult(runtime, true);
    });

    test('time.toIso of time.now produces valid ISO string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length(time.toIso(time.now())) > 20',
      );
      checkResult(runtime, true);
    });
  });

  group('Timestamp Chained Operations', () {
    test('nested time.fromIso and time.toIso operations', () {
      final RuntimeFacade runtime = getRuntime('''
original() = "2024-06-15T10:30:45.500Z"
result() = time.toIso(time.fromIso(time.toIso(time.fromIso(original()))))
main() = result()
''');
      checkResult(runtime, '"2024-06-15T10:30:45.500Z"');
    });

    test('time.compare with nested operations', () {
      final RuntimeFacade runtime = getRuntime('''
t1() = time.fromIso("2024-06-15T10:30:45.500Z")
t2() = time.fromIso(time.toIso(t1()))
main() = time.compare(t1(), t2())
''');
      checkResult(runtime, 0);
    });

    test('extracting epoch then creating new comparison', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-06-15T10:30:45.500Z")
e() = timestamp.toEpoch(t())
main() = e() > 0
''');
      checkResult(runtime, true);
    });

    test('multiple component extractions in single expression', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-06-15T10:30:45.500Z")
main() = time.year(t()) + time.month(t()) + time.day(t())
''');
      checkResult(runtime, 2024 + 6 + 15);
    });

    test('time.compare with results used in condition', () {
      final RuntimeFacade runtime = getRuntime('''
earlier() = time.fromIso("2024-01-01T00:00:00Z")
later() = time.fromIso("2024-12-31T23:59:59Z")
comparison() = time.compare(earlier(), later())
main() = comparison() < 0
''');
      checkResult(runtime, true);
    });
  });

  group('Timestamp Specific Dates', () {
    test('time components for Y2K date', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2000-01-01T00:00:00.000Z")
main() = [time.year(t()), time.month(t()), time.day(t())]
''');
      checkResult(runtime, [2000, 1, 1]);
    });

    test('timestamp.toEpoch for Y2K date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromIso("2000-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 946684800000);
    });

    test('time components for Unix epoch date', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("1970-01-01T00:00:00.000Z")
main() = [time.year(t()), time.month(t()), time.day(t()), time.hour(t()), time.minute(t()), time.second(t()), time.millisecond(t())]
''');
      checkResult(runtime, [1970, 1, 1, 0, 0, 0, 0]);
    });

    test('time components for date in distant past (1800)', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("1800-07-04T12:30:00.000Z")
main() = [time.year(t()), time.month(t()), time.day(t())]
''');
      checkResult(runtime, [1800, 7, 4]);
    });

    test('time components for date in distant future (2100)', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2100-12-25T18:45:30.123Z")
main() = [time.year(t()), time.month(t()), time.day(t()), time.hour(t()), time.minute(t()), time.second(t()), time.millisecond(t())]
''');
      checkResult(runtime, [2100, 12, 25, 18, 45, 30, 123]);
    });

    test('time.compare handles dates centuries apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.compare(time.fromIso("1900-01-01T00:00:00Z"), time.fromIso("2100-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });
  });

  group('time.fromEpoch', () {
    test('time.fromEpoch creates timestamp from epoch milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.toIso(time.fromEpoch(0))',
      );
      checkResult(runtime, '"1970-01-01T00:00:00.000Z"');
    });

    test('time.fromEpoch creates correct timestamp for known epoch value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromEpoch(1705312200000))',
      );
      checkResult(runtime, 2024);
    });

    test('time.fromEpoch roundtrips with timestamp.toEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = timestamp.toEpoch(time.fromEpoch(1705312200000))',
      );
      checkResult(runtime, 1705312200000);
    });

    test('time.fromEpoch handles negative epoch for dates before 1970', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromEpoch(-1000))',
      );
      checkResult(runtime, 1969);
    });

    test('time.fromEpoch extracts correct components', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromEpoch(0)
main() = [time.year(t()), time.month(t()), time.day(t()), time.hour(t()), time.minute(t()), time.second(t()), time.millisecond(t())]
''');
      checkResult(runtime, [1970, 1, 1, 0, 0, 0, 0]);
    });

    test('time.fromEpoch handles large epoch values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.year(time.fromEpoch(32503680000000))',
      );
      checkResult(runtime, 3000);
    });

    test('time.fromEpoch throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromEpoch("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromEpoch throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromEpoch(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromEpoch throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromEpoch([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromEpoch throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.fromEpoch(time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.format', () {
    test('time.format with yyyy-MM-dd pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "yyyy-MM-dd")',
      );
      checkResult(runtime, '"2024-01-15"');
    });

    test('time.format with HH:mm:ss pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "HH:mm:ss")',
      );
      checkResult(runtime, '"10:30:45"');
    });

    test('time.format with full datetime pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "yyyy-MM-dd HH:mm:ss")',
      );
      checkResult(runtime, '"2024-01-15 10:30:45"');
    });

    test('time.format with 12-hour format and AM/PM', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T14:30:45.123Z"), "h:mm a")',
      );
      checkResult(runtime, '"2:30 PM"');
    });

    test('time.format with AM time', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T09:30:45.123Z"), "h:mm a")',
      );
      checkResult(runtime, '"9:30 AM"');
    });

    test('time.format with milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "HH:mm:ss.SSS")',
      );
      checkResult(runtime, '"10:30:45.123"');
    });

    test('time.format with 2-digit year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "yy-MM-dd")',
      );
      checkResult(runtime, '"24-01-15"');
    });

    test('time.format with single digit month and day', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-05T10:30:45.123Z"), "M/d/yyyy")',
      );
      checkResult(runtime, '"1/5/2024"');
    });

    test('time.format with padded 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T09:05:05.007Z"), "hh:mm:ss")',
      );
      checkResult(runtime, '"09:05:05"');
    });

    test('time.format handles midnight as 12 in 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T00:30:00.000Z"), "h:mm a")',
      );
      checkResult(runtime, '"12:30 AM"');
    });

    test('time.format handles noon in 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T12:30:00.000Z"), "h:mm a")',
      );
      checkResult(runtime, '"12:30 PM"');
    });

    test('time.format with empty pattern returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromIso("2024-01-15T10:30:45.123Z"), "")',
      );
      checkResult(runtime, '""');
    });

    test('time.format with literal text only', () {
      final RuntimeFacade runtime = getRuntime(
        "main() = time.format(time.fromIso(\"2024-01-15T10:30:45.123Z\"), \"'Date': \")",
      );
      checkResult(runtime, '"Date: "');
    });

    test('time.format with escaped single quote', () {
      final RuntimeFacade runtime = getRuntime(
        "main() = time.format(time.fromIso(\"2024-01-15T10:30:45.123Z\"), \"yyyy''MM''dd\")",
      );
      checkResult(runtime, "\"2024'01'15\"");
    });

    test('time.format throws for number first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(123, "yyyy")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.format throws for string first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format("hello", "yyyy")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.format throws for number second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.now(), 123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.format throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.dayOfWeek', () {
    test('time.dayOfWeek returns 1 for Monday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-15T10:30:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.dayOfWeek returns 2 for Tuesday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-16T10:30:00Z"))',
      );
      checkResult(runtime, 2);
    });

    test('time.dayOfWeek returns 3 for Wednesday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-17T10:30:00Z"))',
      );
      checkResult(runtime, 3);
    });

    test('time.dayOfWeek returns 4 for Thursday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-18T10:30:00Z"))',
      );
      checkResult(runtime, 4);
    });

    test('time.dayOfWeek returns 5 for Friday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-19T10:30:00Z"))',
      );
      checkResult(runtime, 5);
    });

    test('time.dayOfWeek returns 6 for Saturday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-20T10:30:00Z"))',
      );
      checkResult(runtime, 6);
    });

    test('time.dayOfWeek returns 7 for Sunday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromIso("2024-01-21T10:30:00Z"))',
      );
      checkResult(runtime, 7);
    });

    test('time.dayOfWeek throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfWeek throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfWeek throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfWeek throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.dayOfYear', () {
    test('time.dayOfYear returns 1 for January 1st', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time.dayOfYear returns 15 for January 15th', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-01-15T10:30:00Z"))',
      );
      checkResult(runtime, 15);
    });

    test('time.dayOfYear returns 32 for February 1st', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, 32);
    });

    test('time.dayOfYear returns 60 for February 29th in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-02-29T00:00:00Z"))',
      );
      checkResult(runtime, 60);
    });

    test('time.dayOfYear returns 366 for December 31st in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 366);
    });

    test('time.dayOfYear returns 365 for December 31st in non-leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 365);
    });

    test('time.dayOfYear returns 100 for April 9th in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-04-09T00:00:00Z"))',
      );
      checkResult(runtime, 100);
    });

    test('time.dayOfYear returns 183 for July 1st in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromIso("2024-07-01T00:00:00Z"))',
      );
      checkResult(runtime, 183);
    });

    test('time.dayOfYear throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfYear throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfYear throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.dayOfYear throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.isLeapYear', () {
    test('time.isLeapYear returns true for 2024 (divisible by 4)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(2024)',
      );
      checkResult(runtime, true);
    });

    test('time.isLeapYear returns false for 2023 (not divisible by 4)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(2023)',
      );
      checkResult(runtime, false);
    });

    test('time.isLeapYear returns true for 2000 (divisible by 400)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(2000)',
      );
      checkResult(runtime, true);
    });

    test(
      'time.isLeapYear returns false for 1900 (divisible by 100 not 400)',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = time.isLeapYear(1900)',
        );
        checkResult(runtime, false);
      },
    );

    test(
      'time.isLeapYear returns false for 2100 (divisible by 100 not 400)',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = time.isLeapYear(2100)',
        );
        checkResult(runtime, false);
      },
    );

    test('time.isLeapYear returns true for 1600 (divisible by 400)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(1600)',
      );
      checkResult(runtime, true);
    });

    test('time.isLeapYear returns true for 2020', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(2020)',
      );
      checkResult(runtime, true);
    });

    test('time.isLeapYear returns false for 2019', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(2019)',
      );
      checkResult(runtime, false);
    });

    test('time.isLeapYear throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear("2024")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isLeapYear throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isLeapYear throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear([2024])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isLeapYear throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.isBefore', () {
    test('time.isBefore returns true when first is before second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isBefore returns false when first is after second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time.isBefore returns false when timestamps are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time.isBefore detects millisecond differences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("2024-01-01T00:00:00.000Z"), time.fromIso("2024-01-01T00:00:00.001Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isBefore works across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("2023-12-31T23:59:59Z"), time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isBefore works with epoch boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromIso("1969-12-31T23:59:59Z"), time.fromIso("1970-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isBefore throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isBefore throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore("hello", time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isBefore throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isBefore throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isBefore throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore([1, 2], [3, 4])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time.isAfter', () {
    test('time.isAfter returns true when first is after second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isAfter returns false when first is before second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time.isAfter returns false when timestamps are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time.isAfter detects millisecond differences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("2024-01-01T00:00:00.001Z"), time.fromIso("2024-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isAfter works across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isAfter works with epoch boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromIso("1970-01-01T00:00:00Z"), time.fromIso("1969-12-31T23:59:59Z"))',
      );
      checkResult(runtime, true);
    });

    test('time.isAfter throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isAfter throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter("hello", time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isAfter throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isAfter throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.isAfter throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter([1, 2], [3, 4])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('New Time Functions Composition', () {
    test('time.fromEpoch and time.isBefore composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isBefore(time.fromEpoch(0), time.fromEpoch(1000))',
      );
      checkResult(runtime, true);
    });

    test('time.fromEpoch and time.isAfter composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isAfter(time.fromEpoch(1000), time.fromEpoch(0))',
      );
      checkResult(runtime, true);
    });

    test('time.dayOfWeek with time.fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfWeek(time.fromEpoch(0))',
      );
      checkResult(runtime, 4);
    });

    test('time.dayOfYear with time.fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.dayOfYear(time.fromEpoch(0))',
      );
      checkResult(runtime, 1);
    });

    test('time.format with time.fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.format(time.fromEpoch(0), "yyyy-MM-dd")',
      );
      checkResult(runtime, '"1970-01-01"');
    });

    test('time.isLeapYear with time.year composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time.isLeapYear(time.year(time.fromIso("2024-06-15T00:00:00Z")))',
      );
      checkResult(runtime, true);
    });

    test('time.isBefore and time.isAfter are inverse', () {
      final RuntimeFacade runtime = getRuntime('''
t1() = time.fromIso("2024-01-01T00:00:00Z")
t2() = time.fromIso("2024-02-01T00:00:00Z")
main() = time.isBefore(t1(), t2()) && time.isAfter(t2(), t1())
''');
      checkResult(runtime, true);
    });

    test('time.isBefore and time.isAfter both false for equal timestamps', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time.fromIso("2024-01-01T00:00:00Z")
main() = !time.isBefore(t(), t()) && !time.isAfter(t(), t())
''');
      checkResult(runtime, true);
    });
  });
}
