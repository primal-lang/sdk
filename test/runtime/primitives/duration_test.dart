@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Duration Construction', () {
    test('duration_fromMilliseconds creates duration from integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromMilliseconds(500))',
      );
      checkResult(runtime, 500);
    });

    test(
      'duration_fromMilliseconds creates duration from fractional value',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = duration_toMilliseconds(duration_fromMilliseconds(1.5))',
        );
        checkResult(runtime, 1.5);
      },
    );

    test('duration_fromMilliseconds with zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromMilliseconds(0))',
      );
      checkResult(runtime, 0);
    });

    test('duration_fromMilliseconds throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromMilliseconds(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_fromSeconds creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toSeconds(duration_fromSeconds(30))',
      );
      checkResult(runtime, 30);
    });

    test('duration_fromSeconds with fractional value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromSeconds(1.5))',
      );
      checkResult(runtime, 1500);
    });

    test('duration_fromSeconds throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromSeconds(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_fromMinutes creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(duration_fromMinutes(5))',
      );
      checkResult(runtime, 5);
    });

    test('duration_fromMinutes throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromMinutes(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_fromHours creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours(duration_fromHours(2))',
      );
      checkResult(runtime, 2);
    });

    test('duration_fromHours with fractional value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(duration_fromHours(2.5))',
      );
      checkResult(runtime, 150);
    });

    test('duration_fromHours throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_fromDays creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toDays(duration_fromDays(7))',
      );
      checkResult(runtime, 7);
    });

    test('duration_fromDays with fractional value equals 12 hours', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours(duration_fromDays(0.5))',
      );
      checkResult(runtime, 12);
    });

    test('duration_fromDays throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromDays(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Combined Constructor', () {
    test('duration_from creates duration from all components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_from(0, 2, 30, 0, 0))',
      );
      // 2 hours 30 minutes = 9000000 milliseconds
      checkResult(runtime, 9000000);
    });

    test('duration_from with all zeros', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_from(0, 0, 0, 0, 0))',
      );
      checkResult(runtime, 0);
    });

    test('duration_from with all components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_from(1, 2, 30, 45, 500))',
      );
      // 1 day + 2 hours + 30 minutes + 45 seconds + 500 ms
      // = 86400000 + 7200000 + 1800000 + 45000 + 500 = 95445500
      checkResult(runtime, 95445500);
    });

    test('duration_from throws for negative days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(-1, 0, 0, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_from throws for negative hours', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(0, -1, 0, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_from throws for negative minutes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(0, 0, -1, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_from throws for negative seconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(0, 0, 0, -1, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_from throws for negative milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(0, 0, 0, 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration_from validates left-to-right (first negative stops)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from(-1, -2, 0, 0, 0)',
      );
      // Should throw for days, not hours
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Total Conversion', () {
    test('duration_toMilliseconds returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromSeconds(1))',
      );
      checkResult(runtime, 1000);
    });

    test('duration_toSeconds returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toSeconds(duration_fromMilliseconds(1500))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration_toMinutes returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(duration_fromSeconds(90))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration_toHours returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours(duration_fromMinutes(90))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration_toDays returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toDays(duration_fromHours(36))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration_toHours zero duration returns 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours(duration_fromMilliseconds(0))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Duration Component Extraction', () {
    test('duration_milliseconds returns 0-999 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_milliseconds(duration_from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 500);
    });

    test('duration_seconds returns 0-59 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_seconds(duration_from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 45);
    });

    test('duration_minutes returns 0-59 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_minutes(duration_from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 30);
    });

    test('duration_hours returns 0-23 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_hours(duration_from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 2);
    });

    test('duration_hours for 50 hours returns 2 (after extracting 2 days)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_hours(duration_fromHours(50))',
      );
      checkResult(runtime, 2);
    });

    test('duration_days for 50 hours returns 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_days(duration_fromHours(50))',
      );
      checkResult(runtime, 2);
    });

    test('duration_days is unbounded', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_days(duration_fromDays(100))',
      );
      checkResult(runtime, 100);
    });
  });

  group('Duration Compare', () {
    test('duration_compare returns -1 for less than', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_compare(duration_fromHours(1), duration_fromHours(2))',
      );
      checkResult(runtime, -1);
    });

    test('duration_compare returns 0 for equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_compare(duration_fromHours(1), duration_fromMinutes(60))',
      );
      checkResult(runtime, 0);
    });

    test('duration_compare returns 1 for greater than', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_compare(duration_fromHours(2), duration_fromHours(1))',
      );
      checkResult(runtime, 1);
    });

    test('duration_compare with same duration via different constructors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_compare(duration_fromHours(1), duration_fromMinutes(60))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Duration Format', () {
    test('duration_format with HH:mm:ss pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_from(0, 5, 30, 45, 0), "HH:mm:ss")',
      );
      checkResult(runtime, '"05:30:45"');
    });

    test('duration_format with HH:mm:ss.SSS pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_from(0, 5, 30, 45, 500), "HH:mm:ss.SSS")',
      );
      checkResult(runtime, '"05:30:45.500"');
    });

    test('duration_format with d days HH hours pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_fromHours(50), "d days HH hours")',
      );
      checkResult(runtime, '"2 days 02 hours"');
    });

    test('duration_format with dd zero-pads days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_fromDays(5), "dd")',
      );
      checkResult(runtime, '"05"');
    });

    test('duration_format with large days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_fromDays(100), "d")',
      );
      checkResult(runtime, '"100"');
    });

    test('duration_format uses component values not totals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_fromHours(50), "HH:mm")',
      );
      // 50 hours = 2 days + 2 hours, so HH should be 02
      checkResult(runtime, '"02:00"');
    });

    test('a duration returned from main is rendered as a quoted string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(2)',
      );
      checkResult(runtime, '"0d 2h 00m 00s 000ms"');
    });

    test('duration_format with unpadded H:m:s.S pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_from(0, 1, 2, 3, 4), "H:m:s.S")',
      );
      checkResult(runtime, '"1:2:3.4"');
    });

    test('duration_format unpadded specifiers keep multi-digit values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_from(0, 11, 22, 33, 444), "H:m:s.S")',
      );
      checkResult(runtime, '"11:22:33.444"');
    });
  });

  group('Duration Arithmetic', () {
    test('duration + duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(duration_fromHours(2) + duration_fromMinutes(30))',
      );
      checkResult(runtime, 150);
    });

    test('duration + zero duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours(duration_fromHours(2) + duration_fromMilliseconds(0))',
      );
      checkResult(runtime, 2);
    });

    test('duration - duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(duration_fromHours(2) - duration_fromMinutes(30))',
      );
      checkResult(runtime, 90);
    });

    test('duration - duration resulting in zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromHours(1) - duration_fromHours(1))',
      );
      checkResult(runtime, 0);
    });

    test('duration - duration resulting in negative throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) - duration_fromHours(2)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Comparison Operators', () {
    test('duration < duration returns true when less', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) < duration_fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration < duration returns false when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(2) < duration_fromHours(1)',
      );
      checkResult(runtime, false);
    });

    test('duration < duration returns false when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) < duration_fromMinutes(60)',
      );
      checkResult(runtime, false);
    });

    test('duration > duration returns true when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(2) > duration_fromHours(1)',
      );
      checkResult(runtime, true);
    });

    test('duration <= duration returns true when less', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) <= duration_fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration <= duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) <= duration_fromMinutes(60)',
      );
      checkResult(runtime, true);
    });

    test('duration >= duration returns true when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(2) >= duration_fromHours(1)',
      );
      checkResult(runtime, true);
    });

    test('duration >= duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) >= duration_fromMinutes(60)',
      );
      checkResult(runtime, true);
    });
  });

  group('Duration Equality Operators', () {
    test('duration == duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) == duration_fromMinutes(60)',
      );
      checkResult(runtime, true);
    });

    test('duration == duration returns false when not equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) == duration_fromHours(2)',
      );
      checkResult(runtime, false);
    });

    test('duration != duration returns true when not equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) != duration_fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration != duration returns false when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours(1) != duration_fromMinutes(60)',
      );
      checkResult(runtime, false);
    });
  });

  group('Duration Type Errors', () {
    test('duration_fromMilliseconds throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromMilliseconds("100")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_fromMilliseconds throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromMilliseconds(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toMilliseconds throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(1000)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toMilliseconds throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_compare throws for non-duration arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_compare(1, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_format throws for number first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(123, "HH:mm")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_format throws for number second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_format(duration_fromHours(1), 123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_from throws for string first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_from("0", 1, 0, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_fromDays throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromDays("7")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_fromHours throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromHours([1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_fromMinutes throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromMinutes(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_fromSeconds throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_fromSeconds("60")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toDays throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = duration_toDays(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toHours throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toHours("1h")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toMinutes throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMinutes(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_toSeconds throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toSeconds(1000)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_days throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = duration_days(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_hours throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_hours(time_now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_minutes throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_minutes("x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_seconds throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_seconds(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration_milliseconds throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_milliseconds([1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Duration Edge Cases', () {
    test('fractional milliseconds roundtrip', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration_toMilliseconds(duration_fromMilliseconds(1.5))',
      );
      checkResult(runtime, 1.5);
    });
  });

  group('Duration Hashable', () {
    test('duration as map key', () {
      final RuntimeFacade runtime = getRuntime('''
m() = {duration_fromHours(1): "one hour", duration_fromHours(2): "two hours"}
main() = map_at(m(), duration_fromMinutes(60))
''');
      checkResult(runtime, '"one hour"');
    });

    test('equal durations hash to same value in set', () {
      final RuntimeFacade runtime = getRuntime('''
s() = set_new([duration_fromHours(1), duration_fromMinutes(60), duration_fromHours(2)])
main() = set_length(s())
''');
      // duration_fromHours(1) == duration_fromMinutes(60), so set has 2 elements
      checkResult(runtime, 2);
    });

    test('zero duration as map key', () {
      final RuntimeFacade runtime = getRuntime('''
m() = {duration_fromMilliseconds(0): "zero"}
main() = map_at(m(), duration_from(0, 0, 0, 0, 0))
''');
      checkResult(runtime, '"zero"');
    });
  });

  group('Duration Integration', () {
    test('list_reduce with duration addition', () {
      final RuntimeFacade runtime = getRuntime('''
shifts() = [
  duration_from(0, 8, 30, 0, 0),
  duration_from(0, 7, 45, 0, 0),
  duration_from(0, 9, 0, 0, 0)
]
total() = list_reduce(shifts(), duration_fromMilliseconds(0), (a, b) -> a + b)
main() = duration_toHours(total())
''');
      // 8.5 + 7.75 + 9 = 25.25
      checkResult(runtime, 25.25);
    });

    test('list_map with duration function', () {
      final RuntimeFacade runtime = getRuntime('''
hours() = [1, 2, 3]
durations() = list_map(hours(), (h) -> duration_fromHours(h))
main() = duration_toMinutes(list_at(durations(), 1))
''');
      checkResult(runtime, 120);
    });

    test('list_filter with duration comparison', () {
      final RuntimeFacade runtime = getRuntime('''
durations() = [
  duration_fromHours(1),
  duration_fromHours(2),
  duration_fromHours(3)
]
longDurations() = list_filter(durations(), (d) -> d > duration_fromMinutes(90))
main() = list_length(longDurations())
''');
      checkResult(runtime, 2);
    });

    test('duration in conditional expression', () {
      final RuntimeFacade runtime = getRuntime('''
elapsed() = duration_fromHours(2)
threshold() = duration_fromHours(1)
main() = if (elapsed() > threshold()) "overtime" else "ok"
''');
      checkResult(runtime, '"overtime"');
    });
  });
}
