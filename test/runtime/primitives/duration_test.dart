@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Duration Construction', () {
    test('duration.fromMilliseconds creates duration from integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromMilliseconds(500))',
      );
      checkResult(runtime, 500);
    });

    test(
      'duration.fromMilliseconds creates duration from fractional value',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = duration.toMilliseconds(duration.fromMilliseconds(1.5))',
        );
        checkResult(runtime, 1.5);
      },
    );

    test('duration.fromMilliseconds with zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromMilliseconds(0))',
      );
      checkResult(runtime, 0);
    });

    test('duration.fromMilliseconds throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromMilliseconds(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.fromSeconds creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toSeconds(duration.fromSeconds(30))',
      );
      checkResult(runtime, 30);
    });

    test('duration.fromSeconds with fractional value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromSeconds(1.5))',
      );
      checkResult(runtime, 1500);
    });

    test('duration.fromSeconds throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromSeconds(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.fromMinutes creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMinutes(duration.fromMinutes(5))',
      );
      checkResult(runtime, 5);
    });

    test('duration.fromMinutes throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromMinutes(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.fromHours creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toHours(duration.fromHours(2))',
      );
      checkResult(runtime, 2);
    });

    test('duration.fromHours with fractional value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMinutes(duration.fromHours(2.5))',
      );
      checkResult(runtime, 150);
    });

    test('duration.fromHours throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.fromDays creates duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toDays(duration.fromDays(7))',
      );
      checkResult(runtime, 7);
    });

    test('duration.fromDays with fractional value equals 12 hours', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toHours(duration.fromDays(0.5))',
      );
      checkResult(runtime, 12);
    });

    test('duration.fromDays throws for negative input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromDays(-1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Combined Constructor', () {
    test('duration.from creates duration from all components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.from(0, 2, 30, 0, 0))',
      );
      // 2 hours 30 minutes = 9000000 milliseconds
      checkResult(runtime, 9000000);
    });

    test('duration.from with all zeros', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.from(0, 0, 0, 0, 0))',
      );
      checkResult(runtime, 0);
    });

    test('duration.from with all components', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.from(1, 2, 30, 45, 500))',
      );
      // 1 day + 2 hours + 30 minutes + 45 seconds + 500 ms
      // = 86400000 + 7200000 + 1800000 + 45000 + 500 = 95445500
      checkResult(runtime, 95445500);
    });

    test('duration.from throws for negative days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(-1, 0, 0, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.from throws for negative hours', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(0, -1, 0, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.from throws for negative minutes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(0, 0, -1, 0, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.from throws for negative seconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(0, 0, 0, -1, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.from throws for negative milliseconds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(0, 0, 0, 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });

    test('duration.from validates left-to-right (first negative stops)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.from(-1, -2, 0, 0, 0)',
      );
      // Should throw for days, not hours
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Total Conversion', () {
    test('duration.toMilliseconds returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromSeconds(1))',
      );
      checkResult(runtime, 1000);
    });

    test('duration.toSeconds returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toSeconds(duration.fromMilliseconds(1500))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration.toMinutes returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMinutes(duration.fromSeconds(90))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration.toHours returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toHours(duration.fromMinutes(90))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration.toDays returns fractional result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toDays(duration.fromHours(36))',
      );
      checkResult(runtime, 1.5);
    });

    test('duration.toHours zero duration returns 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toHours(duration.fromMilliseconds(0))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Duration Component Extraction', () {
    test('duration.milliseconds returns 0-999 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.milliseconds(duration.from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 500);
    });

    test('duration.seconds returns 0-59 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.seconds(duration.from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 45);
    });

    test('duration.minutes returns 0-59 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.minutes(duration.from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 30);
    });

    test('duration.hours returns 0-23 range', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.hours(duration.from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, 2);
    });

    test('duration.hours for 50 hours returns 2 (after extracting 2 days)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.hours(duration.fromHours(50))',
      );
      checkResult(runtime, 2);
    });

    test('duration.days for 50 hours returns 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.days(duration.fromHours(50))',
      );
      checkResult(runtime, 2);
    });

    test('duration.days is unbounded', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.days(duration.fromDays(100))',
      );
      checkResult(runtime, 100);
    });
  });

  group('Duration Compare', () {
    test('duration.compare returns -1 for less than', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.compare(duration.fromHours(1), duration.fromHours(2))',
      );
      checkResult(runtime, -1);
    });

    test('duration.compare returns 0 for equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.compare(duration.fromHours(1), duration.fromMinutes(60))',
      );
      checkResult(runtime, 0);
    });

    test('duration.compare returns 1 for greater than', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.compare(duration.fromHours(2), duration.fromHours(1))',
      );
      checkResult(runtime, 1);
    });

    test('duration.compare with same duration via different constructors', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.compare(duration.fromHours(1), duration.fromMinutes(60))',
      );
      checkResult(runtime, 0);
    });
  });

  group('Duration Format', () {
    test('duration.format with HH:mm:ss pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.from(0, 5, 30, 45, 0), "HH:mm:ss")',
      );
      checkResult(runtime, '"05:30:45"');
    });

    test('duration.format with HH:mm:ss.SSS pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.from(0, 5, 30, 45, 500), "HH:mm:ss.SSS")',
      );
      checkResult(runtime, '"05:30:45.500"');
    });

    test('duration.format with d days HH hours pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.fromHours(50), "d days HH hours")',
      );
      checkResult(runtime, '"2 days 02 hours"');
    });

    test('duration.format with dd zero-pads days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.fromDays(5), "dd")',
      );
      checkResult(runtime, '"05"');
    });

    test('duration.format with large days', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.fromDays(100), "d")',
      );
      checkResult(runtime, '"100"');
    });

    test('duration.format uses component values not totals', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.fromHours(50), "HH:mm")',
      );
      // 50 hours = 2 days + 2 hours, so HH should be 02
      checkResult(runtime, '"02:00"');
    });
  });

  group('Duration Arithmetic', () {
    test('duration + duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMinutes(duration.fromHours(2) + duration.fromMinutes(30))',
      );
      checkResult(runtime, 150);
    });

    test('duration + zero duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toHours(duration.fromHours(2) + duration.fromMilliseconds(0))',
      );
      checkResult(runtime, 2);
    });

    test('duration - duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMinutes(duration.fromHours(2) - duration.fromMinutes(30))',
      );
      checkResult(runtime, 90);
    });

    test('duration - duration resulting in zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromHours(1) - duration.fromHours(1))',
      );
      checkResult(runtime, 0);
    });

    test('duration - duration resulting in negative throws', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) - duration.fromHours(2)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeDurationError>()));
    });
  });

  group('Duration Comparison Operators', () {
    test('duration < duration returns true when less', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) < duration.fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration < duration returns false when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(2) < duration.fromHours(1)',
      );
      checkResult(runtime, false);
    });

    test('duration < duration returns false when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) < duration.fromMinutes(60)',
      );
      checkResult(runtime, false);
    });

    test('duration > duration returns true when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(2) > duration.fromHours(1)',
      );
      checkResult(runtime, true);
    });

    test('duration <= duration returns true when less', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) <= duration.fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration <= duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) <= duration.fromMinutes(60)',
      );
      checkResult(runtime, true);
    });

    test('duration >= duration returns true when greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(2) >= duration.fromHours(1)',
      );
      checkResult(runtime, true);
    });

    test('duration >= duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) >= duration.fromMinutes(60)',
      );
      checkResult(runtime, true);
    });
  });

  group('Duration Equality Operators', () {
    test('duration == duration returns true when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) == duration.fromMinutes(60)',
      );
      checkResult(runtime, true);
    });

    test('duration == duration returns false when not equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) == duration.fromHours(2)',
      );
      checkResult(runtime, false);
    });

    test('duration != duration returns true when not equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) != duration.fromHours(2)',
      );
      checkResult(runtime, true);
    });

    test('duration != duration returns false when equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromHours(1) != duration.fromMinutes(60)',
      );
      checkResult(runtime, false);
    });
  });

  group('Duration Type Errors', () {
    test('duration.fromMilliseconds throws for string argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromMilliseconds("100")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.fromMilliseconds throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.fromMilliseconds(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.toMilliseconds throws for number argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(1000)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.toMilliseconds throws for timestamp argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(time.now())',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.compare throws for non-duration arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.compare(1, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.format throws for number first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(123, "HH:mm")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('duration.format throws for number second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.format(duration.fromHours(1), 123)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Duration Edge Cases', () {
    test('fractional milliseconds roundtrip', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = duration.toMilliseconds(duration.fromMilliseconds(1.5))',
      );
      checkResult(runtime, 1.5);
    });
  });

  group('Duration Hashable', () {
    test('duration as map key', () {
      final RuntimeFacade runtime = getRuntime('''
m() = {duration.fromHours(1): "one hour", duration.fromHours(2): "two hours"}
main() = map.at(m(), duration.fromMinutes(60))
''');
      checkResult(runtime, '"one hour"');
    });

    test('equal durations hash to same value in set', () {
      final RuntimeFacade runtime = getRuntime('''
s() = set.new([duration.fromHours(1), duration.fromMinutes(60), duration.fromHours(2)])
main() = set.length(s())
''');
      // duration.fromHours(1) == duration.fromMinutes(60), so set has 2 elements
      checkResult(runtime, 2);
    });

    test('zero duration as map key', () {
      final RuntimeFacade runtime = getRuntime('''
m() = {duration.fromMilliseconds(0): "zero"}
main() = map.at(m(), duration.from(0, 0, 0, 0, 0))
''');
      checkResult(runtime, '"zero"');
    });
  });

  group('Duration Integration', () {
    test('list.reduce with duration addition', () {
      final RuntimeFacade runtime = getRuntime('''
shifts() = [
  duration.from(0, 8, 30, 0, 0),
  duration.from(0, 7, 45, 0, 0),
  duration.from(0, 9, 0, 0, 0)
]
total() = list.reduce(shifts(), duration.fromMilliseconds(0), (a, b) -> a + b)
main() = duration.toHours(total())
''');
      // 8.5 + 7.75 + 9 = 25.25
      checkResult(runtime, 25.25);
    });

    test('list.map with duration function', () {
      final RuntimeFacade runtime = getRuntime('''
hours() = [1, 2, 3]
durations() = list.map(hours(), (h) -> duration.fromHours(h))
main() = duration.toMinutes(list.at(durations(), 1))
''');
      checkResult(runtime, 120);
    });

    test('list.filter with duration comparison', () {
      final RuntimeFacade runtime = getRuntime('''
durations() = [
  duration.fromHours(1),
  duration.fromHours(2),
  duration.fromHours(3)
]
longDurations() = list.filter(durations(), (d) -> d > duration.fromMinutes(90))
main() = list.length(longDurations())
''');
      checkResult(runtime, 2);
    });

    test('duration in conditional expression', () {
      final RuntimeFacade runtime = getRuntime('''
elapsed() = duration.fromHours(2)
threshold() = duration.fromHours(1)
main() = if (elapsed() > threshold()) "overtime" else "ok"
''');
      checkResult(runtime, '"overtime"');
    });
  });
}
