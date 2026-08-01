@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Timestamp', () {
    test('time_now', () {
      final RuntimeFacade runtime = getRuntime('main() = time_now()');
      checkDates(runtime, DateTime.now());
    });

    test('time_toIso', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toIso(time_now())',
      );
      checkDates(runtime, DateTime.now());
    });

    test('time_fromIso', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("${now.toIso8601String()}")',
      );
      checkDates(runtime, now);
    });

    test('time_fromIso throws for invalid ISO string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("not-a-date")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('time_year', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.year, 0));
    });

    test('time_month', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.month, 0));
    });

    test('time_day', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime('main() = time_day(time_now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.day, 0));
    });

    test('time_hour', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.hour, 0));
    });

    test('time_minute', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.minute, 0));
    });

    test('time_second', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 1));
    });

    test('time_millisecond', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_now())',
      );
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 999));
    });

    test('time_toEpoch', () {
      final DateTime now = DateTime.now();
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_now())',
      );
      expect(
        num.parse(runtime.executeMain()),
        closeTo(now.millisecondsSinceEpoch, 500),
      );
    });

    test('time_compare returns -1 for earlier date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-09-01T00:00:00"), time_fromIso("2024-09-02T00:00:00"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare returns 0 for equal dates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-09-01T00:00:00"), time_fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 0);
    });

    test('time_compare returns 1 for later date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-09-02T00:00:00"), time_fromIso("2024-09-01T00:00:00"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Edge Cases', () {
    test('time_year extracts correct year from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 2024);
    });

    test('time_month extracts correct month from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 6);
    });

    test('time_day extracts correct day from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 15);
    });

    test('time_hour extracts correct hour from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 10);
    });

    test('time_minute extracts correct minute from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 30);
    });

    test('time_second extracts correct second from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 45);
    });

    test('time_millisecond extracts correct millisecond from known date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, 500);
    });

    test('time_toEpoch returns correct value for Unix epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_toIso roundtrips with time_fromIso', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toIso(time_fromIso("2024-06-15T10:30:45.500Z"))',
      );
      checkResult(runtime, '"2024-06-15T10:30:45.500Z"');
    });

    test('time_fromIso handles date without timezone', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("2024-06-15T10:30:45"))',
      );
      checkResult(runtime, 2024);
    });

    test('time_compare with millisecond precision', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00.001Z"), time_fromIso("2024-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Timestamp Type Errors', () {
    test('time_toIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toIso("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toIso([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toIso(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso(["2024-01-01"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_minute(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_minute("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_minute(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_second(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_second("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_second(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare("hello", time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for list first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare([1, 2], time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for list second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_now(), [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(true, time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_now(), false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Boundary Values', () {
    test('time_month returns 1 for January', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month(time_fromIso("2024-01-15T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_month returns 12 for December', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month(time_fromIso("2024-12-15T00:00:00Z"))',
      );
      checkResult(runtime, 12);
    });

    test('time_day returns 1 for first day of month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-06-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_day returns 31 for last day of 31-day month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-01-31T00:00:00Z"))',
      );
      checkResult(runtime, 31);
    });

    test('time_day returns 30 for last day of 30-day month', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-04-30T00:00:00Z"))',
      );
      checkResult(runtime, 30);
    });

    test('time_day returns 29 for leap year February', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-02-29T00:00:00Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time_day returns 28 for non-leap year February', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2023-02-28T00:00:00Z"))',
      );
      checkResult(runtime, 28);
    });

    test('time_hour returns 0 for midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T00:30:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_hour returns 23 for last hour of day', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T23:30:00Z"))',
      );
      checkResult(runtime, 23);
    });

    test('time_minute returns 0 for start of hour', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute(time_fromIso("2024-06-15T10:00:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_minute returns 59 for last minute of hour', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute(time_fromIso("2024-06-15T10:59:00Z"))',
      );
      checkResult(runtime, 59);
    });

    test('time_second returns 0 for start of minute', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second(time_fromIso("2024-06-15T10:30:00Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_second returns 59 for last second of minute', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second(time_fromIso("2024-06-15T10:30:59Z"))',
      );
      checkResult(runtime, 59);
    });

    test('time_millisecond returns 0 for no milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_millisecond returns 999 for max milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.999Z"))',
      );
      checkResult(runtime, 999);
    });
  });

  group('Timestamp Parse Error Cases', () {
    test('time_fromIso throws for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso("")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for partial date string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("2024-06")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for year-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso("2024")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for malformed date with invalid separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("2024/06/15T10:30:00Z")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for time without date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("10:30:00")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for random text', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("hello world")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('time_fromIso throws for whitespace string', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso("   ")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });
  });

  group('Timestamp ISO Format Variations', () {
    test('time_fromIso handles date with positive timezone offset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T10:30:00+05:00"))',
      );
      checkResult(runtime, 5);
    });

    test('time_fromIso handles date with negative timezone offset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T10:30:00-08:00"))',
      );
      checkResult(runtime, 18);
    });

    test('time_fromIso handles date with Z suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("2024-06-15T10:30:00Z"))',
      );
      checkResult(runtime, 2024);
    });

    test('time_fromIso handles date without timezone marker', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("2024-06-15T10:30:00"))',
      );
      checkResult(runtime, 2024);
    });

    test('time_fromIso handles date with microseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.123456Z"))',
      );
      checkResult(runtime, 123);
    });

    test('time_fromIso handles date with single digit milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.1Z"))',
      );
      checkResult(runtime, 100);
    });

    test('time_fromIso handles date with two digit milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T10:30:45.12Z"))',
      );
      checkResult(runtime, 120);
    });
  });

  group('Timestamp Special Dates', () {
    test(
      'time_toEpoch returns negative value for date before Unix epoch',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = time_toEpoch(time_fromIso("1969-12-31T23:59:59.000Z"))',
        );
        checkResult(runtime, -1000);
      },
    );

    test('time_year handles year 1 AD', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("0001-01-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_year handles far future year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromIso("9999-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 9999);
    });

    test('time_toEpoch handles new year transition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_day handles end of year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 31);
    });

    test('time_month handles leap year February 29', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_month(time_fromIso("2024-02-29T12:00:00Z"))',
      );
      checkResult(runtime, 2);
    });

    test('time_year handles year 2000 leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2000-02-29T12:00:00Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time_year handles century non-leap year 1900', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("1900-02-28T12:00:00Z"))',
      );
      checkResult(runtime, 28);
    });
  });

  group('Timestamp Compare Edge Cases', () {
    test('time_compare returns 0 for same timestamp via different paths', () {
      final RuntimeFacade runtime = getRuntime('''
timestamp() = time_fromIso("2024-06-15T10:30:00.000Z")
main() = time_compare(timestamp(), time_fromIso(time_toIso(timestamp())))
''');
      checkResult(runtime, 0);
    });

    test('time_compare detects microsecond differences when rounded', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00.001Z"), time_fromIso("2024-01-01T00:00:00.002Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles timestamps one second apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:01Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles timestamps one minute apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-01T00:01:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles timestamps one hour apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-01T01:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles timestamps one day apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-02T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles timestamps one year apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2025-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare handles epoch boundaries', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("1969-12-31T23:59:59Z"), time_fromIso("1970-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });
  });

  group('Timestamp Composition', () {
    test('time_toIso followed by time_fromIso preserves timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
original() = time_fromIso("2024-06-15T10:30:45.123Z")
roundtrip() = time_fromIso(time_toIso(original()))
main() = time_compare(original(), roundtrip())
''');
      checkResult(runtime, 0);
    });

    test('extracting all components from a known timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-06-15T10:30:45.500Z")
main() = [time_year(t()), time_month(t()), time_day(t()), time_hour(t()), time_minute(t()), time_second(t()), time_millisecond(t())]
''');
      checkResult(runtime, [2024, 6, 15, 10, 30, 45, 500]);
    });

    test('time_toEpoch and components are consistent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T00:00:01.000Z"))',
      );
      checkResult(runtime, 1000);
    });

    test('time_now returns increasing values', () {
      final RuntimeFacade runtime = getRuntime('''
first() = time_now()
second() = time_now()
main() = time_compare(first(), second()) <= 0
''');
      checkResult(runtime, true);
    });
  });

  group('Timestamp Additional Type Errors', () {
    test('time_fromIso throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toIso(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso(num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_minute(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_second(num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for function argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for function first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(num_abs, time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for function second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_now(), num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for both arguments being functions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(num_abs, num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toIso({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_day throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour throws for map argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for map first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare({"a": 1}, time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare throws for map second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_now(), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Midnight and Day Boundary', () {
    test('time_hour returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_hour(time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_minute returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_minute(time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_second returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_second(time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time_millisecond returns 0 at exact midnight', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_millisecond(time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });

    test('time components at one millisecond before midnight', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-06-14T23:59:59.999Z")
main() = [time_hour(t()), time_minute(t()), time_second(t()), time_millisecond(t())]
''');
      checkResult(runtime, [23, 59, 59, 999]);
    });

    test('time_compare across midnight boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-06-14T23:59:59.999Z"), time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_compare at exact same midnight returns 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-06-15T00:00:00.000Z"), time_fromIso("2024-06-15T00:00:00.000Z"))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Timestamp Year Boundary', () {
    test('time components at start of year', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00.000Z")
main() = [time_year(t()), time_month(t()), time_day(t())]
''');
      checkResult(runtime, [2024, 1, 1]);
    });

    test('time components at end of year', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-12-31T23:59:59.999Z")
main() = [time_year(t()), time_month(t()), time_day(t())]
''');
      checkResult(runtime, [2024, 12, 31]);
    });

    test('time_compare across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("2024-12-31T23:59:59.999Z"), time_fromIso("2025-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_day for February 29 in non-century leap year 2024', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2024-02-29T12:00:00.000Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time_day for February 29 in century leap year 2000', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_day(time_fromIso("2000-02-29T12:00:00.000Z"))',
      );
      checkResult(runtime, 29);
    });

    test('time_month handles all 12 months', () {
      final RuntimeFacade runtime = getRuntime('''
months() = [
  time_month(time_fromIso("2024-01-15T00:00:00Z")),
  time_month(time_fromIso("2024-02-15T00:00:00Z")),
  time_month(time_fromIso("2024-03-15T00:00:00Z")),
  time_month(time_fromIso("2024-04-15T00:00:00Z")),
  time_month(time_fromIso("2024-05-15T00:00:00Z")),
  time_month(time_fromIso("2024-06-15T00:00:00Z")),
  time_month(time_fromIso("2024-07-15T00:00:00Z")),
  time_month(time_fromIso("2024-08-15T00:00:00Z")),
  time_month(time_fromIso("2024-09-15T00:00:00Z")),
  time_month(time_fromIso("2024-10-15T00:00:00Z")),
  time_month(time_fromIso("2024-11-15T00:00:00Z")),
  time_month(time_fromIso("2024-12-15T00:00:00Z"))
]
main() = months()
''');
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    });
  });

  group('Timestamp Epoch Edge Cases', () {
    test('time_toEpoch for one millisecond after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T00:00:00.001Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_toEpoch for one millisecond before epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1969-12-31T23:59:59.999Z"))',
      );
      checkResult(runtime, -1);
    });

    test('time_toEpoch for exactly one second after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T00:00:01.000Z"))',
      );
      checkResult(runtime, 1000);
    });

    test('time_toEpoch for exactly one minute after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T00:01:00.000Z"))',
      );
      checkResult(runtime, 60000);
    });

    test('time_toEpoch for exactly one hour after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-01T01:00:00.000Z"))',
      );
      checkResult(runtime, 3600000);
    });

    test('time_toEpoch for exactly one day after epoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1970-01-02T00:00:00.000Z"))',
      );
      checkResult(runtime, 86400000);
    });

    test('time_toEpoch for date far in past (1900)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("1900-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, -2208988800000);
    });

    test('time_toEpoch for large future date (year 3000)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("3000-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 32503680000000);
    });
  });

  group('Timestamp Now Function Tests', () {
    test('time_now returns valid year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_now()) >= 2024',
      );
      checkResult(runtime, true);
    });

    test('time_now returns valid month between 1 and 12', () {
      final RuntimeFacade runtime = getRuntime('''
m() = time_month(time_now())
main() = m() >= 1 && m() <= 12
''');
      checkResult(runtime, true);
    });

    test('time_now returns valid day between 1 and 31', () {
      final RuntimeFacade runtime = getRuntime('''
d() = time_day(time_now())
main() = d() >= 1 && d() <= 31
''');
      checkResult(runtime, true);
    });

    test('time_now returns valid hour between 0 and 23', () {
      final RuntimeFacade runtime = getRuntime('''
h() = time_hour(time_now())
main() = h() >= 0 && h() <= 23
''');
      checkResult(runtime, true);
    });

    test('time_now returns valid minute between 0 and 59', () {
      final RuntimeFacade runtime = getRuntime('''
m() = time_minute(time_now())
main() = m() >= 0 && m() <= 59
''');
      checkResult(runtime, true);
    });

    test('time_now returns valid second between 0 and 59', () {
      final RuntimeFacade runtime = getRuntime('''
s() = time_second(time_now())
main() = s() >= 0 && s() <= 59
''');
      checkResult(runtime, true);
    });

    test('time_now returns valid millisecond between 0 and 999', () {
      final RuntimeFacade runtime = getRuntime('''
ms() = time_millisecond(time_now())
main() = ms() >= 0 && ms() <= 999
''');
      checkResult(runtime, true);
    });

    test('time_now returns positive epoch for current time', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_now()) > 0',
      );
      checkResult(runtime, true);
    });

    test('time_toIso of time_now produces valid ISO string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length(time_toIso(time_now())) > 20',
      );
      checkResult(runtime, true);
    });
  });

  group('Timestamp Chained Operations', () {
    test('nested time_fromIso and time_toIso operations', () {
      final RuntimeFacade runtime = getRuntime('''
original() = "2024-06-15T10:30:45.500Z"
result() = time_toIso(time_fromIso(time_toIso(time_fromIso(original()))))
main() = result()
''');
      checkResult(runtime, '"2024-06-15T10:30:45.500Z"');
    });

    test('time_compare with nested operations', () {
      final RuntimeFacade runtime = getRuntime('''
t1() = time_fromIso("2024-06-15T10:30:45.500Z")
t2() = time_fromIso(time_toIso(t1()))
main() = time_compare(t1(), t2())
''');
      checkResult(runtime, 0);
    });

    test('extracting epoch then creating new comparison', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-06-15T10:30:45.500Z")
e() = time_toEpoch(t())
main() = e() > 0
''');
      checkResult(runtime, true);
    });

    test('multiple component extractions in single expression', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-06-15T10:30:45.500Z")
main() = time_year(t()) + time_month(t()) + time_day(t())
''');
      checkResult(runtime, 2024 + 6 + 15);
    });

    test('time_compare with results used in condition', () {
      final RuntimeFacade runtime = getRuntime('''
earlier() = time_fromIso("2024-01-01T00:00:00Z")
later() = time_fromIso("2024-12-31T23:59:59Z")
comparison() = time_compare(earlier(), later())
main() = comparison() < 0
''');
      checkResult(runtime, true);
    });
  });

  group('Timestamp Specific Dates', () {
    test('time components for Y2K date', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2000-01-01T00:00:00.000Z")
main() = [time_year(t()), time_month(t()), time_day(t())]
''');
      checkResult(runtime, [2000, 1, 1]);
    });

    test('time_toEpoch for Y2K date', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromIso("2000-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, 946684800000);
    });

    test('time components for Unix epoch date', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("1970-01-01T00:00:00.000Z")
main() = [time_year(t()), time_month(t()), time_day(t()), time_hour(t()), time_minute(t()), time_second(t()), time_millisecond(t())]
''');
      checkResult(runtime, [1970, 1, 1, 0, 0, 0, 0]);
    });

    test('time components for date in distant past (1800)', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("1800-07-04T12:30:00.000Z")
main() = [time_year(t()), time_month(t()), time_day(t())]
''');
      checkResult(runtime, [1800, 7, 4]);
    });

    test('time components for date in distant future (2100)', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2100-12-25T18:45:30.123Z")
main() = [time_year(t()), time_month(t()), time_day(t()), time_hour(t()), time_minute(t()), time_second(t()), time_millisecond(t())]
''');
      checkResult(runtime, [2100, 12, 25, 18, 45, 30, 123]);
    });

    test('time_compare handles dates centuries apart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_compare(time_fromIso("1900-01-01T00:00:00Z"), time_fromIso("2100-01-01T00:00:00Z"))',
      );
      checkResult(runtime, -1);
    });
  });

  group('time_fromEpoch', () {
    test('time_fromEpoch creates timestamp from epoch milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toIso(time_fromEpoch(0))',
      );
      checkResult(runtime, '"1970-01-01T00:00:00.000Z"');
    });

    test('time_fromEpoch creates correct timestamp for known epoch value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromEpoch(1705312200000))',
      );
      checkResult(runtime, 2024);
    });

    test('time_fromEpoch roundtrips with time_toEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(time_fromEpoch(1705312200000))',
      );
      checkResult(runtime, 1705312200000);
    });

    test('time_fromEpoch handles negative epoch for dates before 1970', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromEpoch(-1000))',
      );
      checkResult(runtime, 1969);
    });

    test('time_fromEpoch extracts correct components', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromEpoch(0)
main() = [time_year(t()), time_month(t()), time_day(t()), time_hour(t()), time_minute(t()), time_second(t()), time_millisecond(t())]
''');
      checkResult(runtime, [1970, 1, 1, 0, 0, 0, 0]);
    });

    test('time_fromEpoch handles large epoch values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_year(time_fromEpoch(32503680000000))',
      );
      checkResult(runtime, 3000);
    });

    test('time_fromEpoch throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromEpoch("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromEpoch throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromEpoch(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromEpoch throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromEpoch([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromEpoch throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromEpoch(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_format', () {
    test('time_format with yyyy-MM-dd pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "yyyy-MM-dd")',
      );
      checkResult(runtime, '"2024-01-15"');
    });

    test('time_format with HH:mm:ss pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "HH:mm:ss")',
      );
      checkResult(runtime, '"10:30:45"');
    });

    test('time_format with full datetime pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "yyyy-MM-dd HH:mm:ss")',
      );
      checkResult(runtime, '"2024-01-15 10:30:45"');
    });

    test('time_format with 12-hour format and AM/PM', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T14:30:45.123Z"), "h:mm a")',
      );
      checkResult(runtime, '"2:30 PM"');
    });

    test('time_format with AM time', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T09:30:45.123Z"), "h:mm a")',
      );
      checkResult(runtime, '"9:30 AM"');
    });

    test('time_format with milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "HH:mm:ss.SSS")',
      );
      checkResult(runtime, '"10:30:45.123"');
    });

    test('time_format with 2-digit year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "yy-MM-dd")',
      );
      checkResult(runtime, '"24-01-15"');
    });

    test('time_format with single digit month and day', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-05T10:30:45.123Z"), "M/d/yyyy")',
      );
      checkResult(runtime, '"1/5/2024"');
    });

    test('time_format with padded 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T09:05:05.007Z"), "hh:mm:ss")',
      );
      checkResult(runtime, '"09:05:05"');
    });

    test('time_format handles midnight as 12 in 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T00:30:00.000Z"), "h:mm a")',
      );
      checkResult(runtime, '"12:30 AM"');
    });

    test('time_format handles noon in 12-hour format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T12:30:00.000Z"), "h:mm a")',
      );
      checkResult(runtime, '"12:30 PM"');
    });

    test('time_format with empty pattern returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromIso("2024-01-15T10:30:45.123Z"), "")',
      );
      checkResult(runtime, '""');
    });

    test('time_format with literal text only', () {
      final RuntimeFacade runtime = getRuntime(
        "main() = time_format(time_fromIso(\"2024-01-15T10:30:45.123Z\"), \"'Date': \")",
      );
      checkResult(runtime, '"Date: "');
    });

    test('time_format with escaped single quote', () {
      final RuntimeFacade runtime = getRuntime(
        "main() = time_format(time_fromIso(\"2024-01-15T10:30:45.123Z\"), \"yyyy''MM''dd\")",
      );
      checkResult(runtime, "\"2024'01'15\"");
    });

    test('time_format throws for number first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(123, "yyyy")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_format throws for string first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format("hello", "yyyy")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_format throws for number second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_now(), 123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_format throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_dayOfWeek', () {
    test('time_dayOfWeek returns 1 for Monday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-15T10:30:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_dayOfWeek returns 2 for Tuesday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-16T10:30:00Z"))',
      );
      checkResult(runtime, 2);
    });

    test('time_dayOfWeek returns 3 for Wednesday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-17T10:30:00Z"))',
      );
      checkResult(runtime, 3);
    });

    test('time_dayOfWeek returns 4 for Thursday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-18T10:30:00Z"))',
      );
      checkResult(runtime, 4);
    });

    test('time_dayOfWeek returns 5 for Friday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-19T10:30:00Z"))',
      );
      checkResult(runtime, 5);
    });

    test('time_dayOfWeek returns 6 for Saturday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-20T10:30:00Z"))',
      );
      checkResult(runtime, 6);
    });

    test('time_dayOfWeek returns 7 for Sunday', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromIso("2024-01-21T10:30:00Z"))',
      );
      checkResult(runtime, 7);
    });

    test('time_dayOfWeek throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfWeek throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfWeek throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfWeek throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_dayOfYear', () {
    test('time_dayOfYear returns 1 for January 1st', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, 1);
    });

    test('time_dayOfYear returns 15 for January 15th', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-01-15T10:30:00Z"))',
      );
      checkResult(runtime, 15);
    });

    test('time_dayOfYear returns 32 for February 1st', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, 32);
    });

    test('time_dayOfYear returns 60 for February 29th in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-02-29T00:00:00Z"))',
      );
      checkResult(runtime, 60);
    });

    test('time_dayOfYear returns 366 for December 31st in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 366);
    });

    test('time_dayOfYear returns 365 for December 31st in non-leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, 365);
    });

    test('time_dayOfYear returns 100 for April 9th in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-04-09T00:00:00Z"))',
      );
      checkResult(runtime, 100);
    });

    test('time_dayOfYear returns 183 for July 1st in leap year', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromIso("2024-07-01T00:00:00Z"))',
      );
      checkResult(runtime, 183);
    });

    test('time_dayOfYear throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfYear throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfYear throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_dayOfYear throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_isLeapYear', () {
    test('time_isLeapYear returns true for 2024 (divisible by 4)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(2024)',
      );
      checkResult(runtime, true);
    });

    test('time_isLeapYear returns false for 2023 (not divisible by 4)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(2023)',
      );
      checkResult(runtime, false);
    });

    test('time_isLeapYear returns true for 2000 (divisible by 400)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(2000)',
      );
      checkResult(runtime, true);
    });

    test(
      'time_isLeapYear returns false for 1900 (divisible by 100 not 400)',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = time_isLeapYear(1900)',
        );
        checkResult(runtime, false);
      },
    );

    test(
      'time_isLeapYear returns false for 2100 (divisible by 100 not 400)',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = time_isLeapYear(2100)',
        );
        checkResult(runtime, false);
      },
    );

    test('time_isLeapYear returns true for 1600 (divisible by 400)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(1600)',
      );
      checkResult(runtime, true);
    });

    test('time_isLeapYear returns true for 2020', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(2020)',
      );
      checkResult(runtime, true);
    });

    test('time_isLeapYear returns false for 2019', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(2019)',
      );
      checkResult(runtime, false);
    });

    test('time_isLeapYear throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear("2024")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isLeapYear throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isLeapYear throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear([2024])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isLeapYear throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_isBefore', () {
    test('time_isBefore returns true when first is before second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isBefore returns false when first is after second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("2024-02-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time_isBefore returns false when timestamps are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time_isBefore detects millisecond differences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("2024-01-01T00:00:00.000Z"), time_fromIso("2024-01-01T00:00:00.001Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isBefore works across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("2023-12-31T23:59:59Z"), time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isBefore works with epoch boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromIso("1969-12-31T23:59:59Z"), time_fromIso("1970-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isBefore throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isBefore throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore("hello", time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isBefore throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isBefore throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isBefore throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore([1, 2], [3, 4])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('time_isAfter', () {
    test('time_isAfter returns true when first is after second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("2024-02-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isAfter returns false when first is before second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-02-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time_isAfter returns false when timestamps are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:00Z"))',
      );
      checkResult(runtime, false);
    });

    test('time_isAfter detects millisecond differences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("2024-01-01T00:00:00.001Z"), time_fromIso("2024-01-01T00:00:00.000Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isAfter works across year boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("2024-01-01T00:00:00Z"), time_fromIso("2023-12-31T23:59:59Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isAfter works with epoch boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromIso("1970-01-01T00:00:00Z"), time_fromIso("1969-12-31T23:59:59Z"))',
      );
      checkResult(runtime, true);
    });

    test('time_isAfter throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isAfter throws for first argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter("hello", time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isAfter throws for second argument being non-timestamp', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_now(), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isAfter throws for boolean arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(true, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_isAfter throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter([1, 2], [3, 4])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('New Time Functions Composition', () {
    test('time_fromEpoch and time_isBefore composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isBefore(time_fromEpoch(0), time_fromEpoch(1000))',
      );
      checkResult(runtime, true);
    });

    test('time_fromEpoch and time_isAfter composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isAfter(time_fromEpoch(1000), time_fromEpoch(0))',
      );
      checkResult(runtime, true);
    });

    test('time_dayOfWeek with time_fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfWeek(time_fromEpoch(0))',
      );
      checkResult(runtime, 4);
    });

    test('time_dayOfYear with time_fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_dayOfYear(time_fromEpoch(0))',
      );
      checkResult(runtime, 1);
    });

    test('time_format with time_fromEpoch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_format(time_fromEpoch(0), "yyyy-MM-dd")',
      );
      checkResult(runtime, '"1970-01-01"');
    });

    test('time_isLeapYear with time_year composition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_isLeapYear(time_year(time_fromIso("2024-06-15T00:00:00Z")))',
      );
      checkResult(runtime, true);
    });

    test('time_isBefore and time_isAfter are inverse', () {
      final RuntimeFacade runtime = getRuntime('''
t1() = time_fromIso("2024-01-01T00:00:00Z")
t2() = time_fromIso("2024-02-01T00:00:00Z")
main() = time_isBefore(t1(), t2()) && time_isAfter(t2(), t1())
''');
      checkResult(runtime, true);
    });

    test('time_isBefore and time_isAfter both false for equal timestamps', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00Z")
main() = !time_isBefore(t(), t()) && !time_isAfter(t(), t())
''');
      checkResult(runtime, true);
    });
  });

  group('Timestamp Integration', () {
    test('time_add adds duration to timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00Z")
main() = time_day(time_add(t(), duration_fromDays(7)))
''');
      checkResult(runtime, 8);
    });

    test('time_add with zero duration', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00Z")
main() = time_compare(t(), time_add(t(), duration_fromMilliseconds(0)))
''');
      checkResult(runtime, 0);
    });

    test('time_subtract subtracts duration from timestamp', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-08T00:00:00Z")
main() = time_day(time_subtract(t(), duration_fromDays(7)))
''');
      checkResult(runtime, 1);
    });

    test('time_subtract with zero duration', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00Z")
main() = time_compare(t(), time_subtract(t(), duration_fromMilliseconds(0)))
''');
      checkResult(runtime, 0);
    });

    test('time_between returns duration between timestamps', () {
      final RuntimeFacade runtime = getRuntime('''
start() = time_fromIso("2024-01-01T00:00:00Z")
end() = time_fromIso("2024-01-08T00:00:00Z")
main() = duration_toDays(time_between(start(), end()))
''');
      checkResult(runtime, 7);
    });

    test(
      'time_between with reversed arguments returns absolute difference',
      () {
        final RuntimeFacade runtime = getRuntime('''
start() = time_fromIso("2024-01-01T00:00:00Z")
end() = time_fromIso("2024-01-08T00:00:00Z")
main() = duration_toDays(time_between(end(), start()))
''');
        checkResult(runtime, 7);
      },
    );

    test('time_between with same timestamp returns zero duration', () {
      final RuntimeFacade runtime = getRuntime('''
t() = time_fromIso("2024-01-01T00:00:00Z")
main() = duration_toMilliseconds(time_between(t(), t()))
''');
      checkResult(runtime, 0);
    });

    test('roundtrip: time_between then time_add', () {
      final RuntimeFacade runtime = getRuntime('''
a() = time_fromIso("2024-01-01T00:00:00Z")
b() = time_fromIso("2024-01-08T00:00:00Z")
d() = time_between(a(), b())
main() = time_compare(time_add(a(), d()), b())
''');
      checkResult(runtime, 0);
    });

    test('time_add throws for number first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_add(123, duration_fromHours(1))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_add throws for number second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_add(time_now(), 123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_subtract throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_subtract(123, 456)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_between throws for duration arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_between(duration_fromHours(1), duration_fromHours(2))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
