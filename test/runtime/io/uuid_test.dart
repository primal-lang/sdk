@Tags(['runtime', 'io'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('UUID V4', () {
    test('uuid.v4 returns a string of length 36', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length(uuid.v4())',
      );
      checkResult(runtime, 36);
    });

    test('uuid.v4 returns a quoted string', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      // Result should be quoted like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      expect(result.startsWith('"'), isTrue);
      expect(result.endsWith('"'), isTrue);
    });

    test('uuid.v4 has correct format with dashes', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      // Remove quotes and split by dashes
      final String uuid = result.substring(1, result.length - 1);
      final List<String> parts = uuid.split('-');
      expect(parts.length, equals(5));
      expect(parts[0].length, equals(8));
      expect(parts[1].length, equals(4));
      expect(parts[2].length, equals(4));
      expect(parts[3].length, equals(4));
      expect(parts[4].length, equals(12));
    });

    test('uuid.v4 has version 4 indicator', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      final String uuid = result.substring(1, result.length - 1);
      // The 13th character (index 14 with dashes) should be '4'
      expect(uuid[14], equals('4'));
    });

    test('uuid.v4 has correct variant bits', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      final String uuid = result.substring(1, result.length - 1);
      // The 17th character (index 19 with dashes) should be 8, 9, a, or b
      expect(['8', '9', 'a', 'b'], contains(uuid[19]));
    });

    test('uuid.v4 contains only valid hex characters and dashes', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      final String uuid = result.substring(1, result.length - 1);
      final RegExp validPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      );
      expect(validPattern.hasMatch(uuid), isTrue);
    });

    test('uuid.v4 generates unique values', () {
      final RuntimeFacade runtime1 = getRuntime('main() = uuid.v4()');
      final RuntimeFacade runtime2 = getRuntime('main() = uuid.v4()');
      final String result1 = runtime1.executeMain();
      final String result2 = runtime2.executeMain();
      expect(result1, isNot(equals(result2)));
    });

    test('uuid.v4 multiple calls return different values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.distinct([uuid.v4(), uuid.v4(), uuid.v4()])',
      );
      final String result = runtime.executeMain();
      // If all three are unique, list.distinct returns a list of 3 elements
      // Count the commas to verify we have 3 elements
      final int commaCount = ','.allMatches(result).length;
      expect(commaCount, equals(2)); // 3 elements separated by 2 commas
    });

    test('uuid.v4 result can be used in string operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains(uuid.v4(), "-")',
      );
      checkResult(runtime, true);
    });

    test('uuid.v4 result can be compared as not equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = comp.neq(uuid.v4(), uuid.v4())',
      );
      checkResult(runtime, true);
    });

    test('uuid.v4 matches RFC 4122 v4 pattern', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      final String uuid = result.substring(1, result.length - 1);
      // RFC 4122 version 4 UUID pattern
      final RegExp rfc4122V4Pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(rfc4122V4Pattern.hasMatch(uuid), isTrue);
    });

    test('uuid.v4 can be concatenated with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith(str.concat("id:", uuid.v4()), "id:")',
      );
      checkResult(runtime, true);
    });

    test('uuid.v4 result has correct total length including quotes', () {
      final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
      final String result = runtime.executeMain();
      // 36 characters for UUID + 2 for quotes = 38
      expect(result.length, equals(38));
    });
  });

  group('UUID V4 Consistency', () {
    test('uuid.v4 generates many valid UUIDs', () {
      for (int i = 0; i < 100; i++) {
        final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
        final String result = runtime.executeMain();
        final String uuid = result.substring(1, result.length - 1);
        expect(uuid.length, equals(36));
        expect(uuid[14], equals('4'));
        expect(['8', '9', 'a', 'b'], contains(uuid[19]));
      }
    });

    test('uuid.v4 always produces lowercase hex', () {
      for (int i = 0; i < 50; i++) {
        final RuntimeFacade runtime = getRuntime('main() = uuid.v4()');
        final String result = runtime.executeMain();
        final String uuid = result.substring(1, result.length - 1);
        expect(uuid, equals(uuid.toLowerCase()));
      }
    });
  });
}
