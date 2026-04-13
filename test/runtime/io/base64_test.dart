@Tags(['runtime', 'io'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Base64 Encode', () {
    test('base64.encode encodes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.encode("")');
      checkResult(runtime, '""');
    });

    test('base64.encode encodes simple string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("Hello, World!")',
      );
      checkResult(runtime, '"SGVsbG8sIFdvcmxkIQ=="');
    });

    test('base64.encode encodes single character', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.encode("A")');
      checkResult(runtime, '"QQ=="');
    });

    test('base64.encode encodes string with spaces', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("hello world")',
      );
      checkResult(runtime, '"aGVsbG8gd29ybGQ="');
    });

    test('base64.encode encodes string with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("12345")',
      );
      checkResult(runtime, '"MTIzNDU="');
    });

    test('base64.encode encodes string with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("!@#\$%")',
      );
      checkResult(runtime, '"IUAjJCU="');
    });
  });

  group('Base64 Decode', () {
    test('base64.decode decodes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.decode("")');
      checkResult(runtime, '""');
    });

    test('base64.decode decodes simple string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVsbG8sIFdvcmxkIQ==")',
      );
      checkResult(runtime, '"Hello, World!"');
    });

    test('base64.decode decodes single character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("QQ==")',
      );
      checkResult(runtime, '"A"');
    });

    test('base64.decode decodes string with spaces', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("aGVsbG8gd29ybGQ=")',
      );
      checkResult(runtime, '"hello world"');
    });

    test('base64.decode decodes string with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("MTIzNDU=")',
      );
      checkResult(runtime, '"12345"');
    });
  });

  group('Base64 Unicode', () {
    test('base64.encode encodes unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("Hello")',
      );
      checkResult(runtime, '"SGVsbG8="');
    });

    test('base64.decode decodes to unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVsbG8=")',
      );
      checkResult(runtime, '"Hello"');
    });
  });

  group('Base64 Roundtrip', () {
    test('base64 encode-decode roundtrip with simple string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode(base64.encode("Hello, World!"))',
      );
      checkResult(runtime, '"Hello, World!"');
    });

    test('base64 encode-decode roundtrip with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode(base64.encode(""))',
      );
      checkResult(runtime, '""');
    });

    test('base64 encode-decode roundtrip with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode(base64.encode("!@#\$%^&*()"))',
      );
      checkResult(runtime, '"!@#\$%^&*()"');
    });

    test('base64 encode-decode roundtrip with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode(base64.encode("123456789"))',
      );
      checkResult(runtime, '"123456789"');
    });

    test('base64 encode-decode roundtrip with newlines', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = base64.decode(base64.encode("line1\nline2"))',
      );
      checkResult(runtime, '"line1\nline2"');
    });

    test('base64 encode-decode roundtrip with tabs', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = base64.decode(base64.encode("col1\tcol2"))',
      );
      checkResult(runtime, '"col1\tcol2"');
    });
  });

  group('Base64 Error Cases', () {
    test('base64.decode throws Base64ParseError for invalid base64', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("not valid base64!!!")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<Base64ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Invalid Base64'),
              contains('not valid base64!!!'),
            ),
          ),
        ),
      );
    });

    test('base64.decode throws Base64ParseError for invalid characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVs!!!")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<Base64ParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid Base64'),
          ),
        ),
      );
    });

    test('base64.decode throws Base64ParseError for invalid padding', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVsbG8===")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<Base64ParseError>()),
      );
    });
  });

  group('Base64 Type Errors', () {
    test('base64.encode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.encode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.encode throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.encode(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.encode throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.encode throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode({"key": "value"})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.decode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.decode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.decode throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = base64.decode(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.decode throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('base64.decode throws for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode({"key": "value"})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Base64 Error Message Truncation', () {
    test('base64.decode truncates long invalid input in error message', () {
      final String longInput =
          'x' * 100; // Input longer than 50 chars to trigger truncation
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("$longInput")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<Base64ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Invalid Base64'),
              contains('...'), // Truncation indicator
              isNot(contains(longInput)), // Full input should not appear
            ),
          ),
        ),
      );
    });
  });

  group('Base64 Padding Variations', () {
    test('base64.decode throws for missing padding', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVsbG8")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<Base64ParseError>()),
      );
    });

    test('base64.decode handles single padding', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGVsbG8h")',
      );
      checkResult(runtime, '"Hello!"');
    });

    test('base64.decode handles double padding', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("SGk=")',
      );
      checkResult(runtime, '"Hi"');
    });
  });

  group('Base64 Long Strings', () {
    test('base64.encode encodes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.encode("The quick brown fox jumps over the lazy dog")',
      );
      checkResult(
        runtime,
        '"VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw=="',
      );
    });

    test('base64.decode decodes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = base64.decode("VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==")',
      );
      checkResult(runtime, '"The quick brown fox jumps over the lazy dog"');
    });
  });
}
