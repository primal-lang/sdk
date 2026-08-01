@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('String', () {
    test('String indexing', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"[1]');
      checkResult(runtime, '"e"');
    });

    test('str_substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("hola", 1, 3)',
      );
      checkResult(runtime, '"ol"');
    });

    test('str_startsWith returns true for matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("hola", "ho")',
      );
      checkResult(runtime, true);
    });

    test('str_startsWith returns false for non-matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("hola", "hoy")',
      );
      checkResult(runtime, false);
    });

    test('str_endsWith returns true for matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("hola", "la")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith returns false for non-matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("hola", "lol")',
      );
      checkResult(runtime, false);
    });

    test('str_replace replaces all occurrences of a substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("banana", "na", "to")',
      );
      checkResult(runtime, '"batoto"');
    });

    test('str_replace returns original when pattern not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("banana", "bon", "to")',
      );
      checkResult(runtime, '"banana"');
    });

    test('str_replace replaces characters matching a regex pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("aaa123BBB", "[a-z]", "x")',
      );
      checkResult(runtime, '"xxx123BBB"');
    });

    test('str_uppercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_uppercase("Primal")',
      );
      checkResult(runtime, '"PRIMAL"');
    });

    test('str_lowercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lowercase("Primal")',
      );
      checkResult(runtime, '"primal"');
    });

    test('str_trim', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('str_match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("identifier42", "[a-zA-Z]+[0-9]+")',
      );
      checkResult(runtime, true);
    });

    test('str_length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length("primal")');
      checkResult(runtime, 6);
    });

    test('str_concat', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("Hello", ", world!")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('str_first', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('str_last', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('str_init', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('str_rest returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("")');
      checkResult(runtime, '""');
    });

    test('str_rest returns string without first character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str_at', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str_isEmpty returns true for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty("")');
      checkResult(runtime, true);
    });

    test('str_isEmpty returns false for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str_isEmpty returns false for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str_isNotEmpty returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str_isNotEmpty returns true for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str_isNotEmpty returns true for non-empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isNotEmpty("Hello")',
      );
      checkResult(runtime, true);
    });

    test('str_contains returns true when substring is present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("Hello", "ell")',
      );
      checkResult(runtime, true);
    });

    test('str_contains returns false for case-sensitive mismatch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("Hello", "hell")',
      );
      checkResult(runtime, false);
    });

    test('str_take returns empty string when taking zero characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str_take returns first n characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str_drop returns full string when dropping zero characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str_drop returns string after dropping first n characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str_removeAt', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("Hello", 4)',
      );
      checkResult(runtime, '"Hell"');
    });

    test('str_reverse', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('str_bytes', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes("Hello")');
      checkResult(runtime, [72, 101, 108, 108, 111]);
    });

    test('str_indexOf returns negative one when substring not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("Hello", "x")',
      );
      checkResult(runtime, -1);
    });

    test('str_indexOf returns index of first occurrence', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("Hello", "l")',
      );
      checkResult(runtime, 2);
    });

    test('str_padLeft does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str_padLeft does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str_padLeft pads string to target width on the left', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("12345", 8, "0")',
      );
      checkResult(runtime, '"00012345"');
    });

    test('str_padLeft pads an empty subject to the full width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("", 3, "x")',
      );
      checkResult(runtime, '"xxx"');
    });

    test('str_padRight pads an empty subject to the full width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("", 3, "x")',
      );
      checkResult(runtime, '"xxx"');
    });

    test('str_replace on an empty subject returns an empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("", "a", "b")',
      );
      checkResult(runtime, '""');
    });

    test('str_lastIndexOf on an empty subject returns -1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("", "a")',
      );
      checkResult(runtime, -1);
    });

    test('str_padRight does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str_padRight does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str_padRight pads string to target width on the right', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("12345", 8, "0")',
      );
      checkResult(runtime, '"12345000"');
    });

    test('str_split returns single-element list when delimiter not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("aa,bb,cc", "x")',
      );
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test(
      'str_split splits into individual characters with empty delimiter',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_split("aa,bb,cc", "")',
        );
        checkResult(runtime, [
          '"a"',
          '"a"',
          '","',
          '"b"',
          '"b"',
          '","',
          '"c"',
          '"c"',
        ]);
      },
    );

    test('str_split splits string by delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("aa,bb,cc", ",")',
      );
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str_compare returns negative one when first string is lesser', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_compare("hello", "mountain")',
      );
      checkResult(runtime, -1);
    });

    test('str_compare returns zero for equal strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_compare("table", "table")',
      );
      checkResult(runtime, 0);
    });

    test('str_compare returns one when first string is greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_compare("monkey", "cat")',
      );
      checkResult(runtime, 1);
    });

    test('str_length counts graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str_at with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_at("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str_first with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_first("👨‍👩‍👧abc")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str_last with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_last("abc👨‍👩‍👧")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str_reverse preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_reverse("a👨‍👩‍👧b")',
      );
      checkResult(runtime, '"b👨‍👩‍👧a"');
    });

    test('str_take with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_take("a👨‍👩‍👧b", 2)',
      );
      checkResult(runtime, '"a👨‍👩‍👧"');
    });

    test('str_drop with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_drop("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧b"');
    });

    test('str_substring with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("a👨‍👩‍👧b", 1, 2)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str_indexOf with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("a👨‍👩‍👧b", "b")',
      );
      checkResult(runtime, 2);
    });

    test('str_split with empty delimiter preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("a👨‍👩‍👧b", "")',
      );
      checkResult(runtime, ['"a"', '"👨‍👩‍👧"', '"b"']);
    });

    test('str_init with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_init("abc👨‍👩‍👧")',
      );
      checkResult(runtime, '"abc"');
    });

    test('str_rest with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_rest("👨‍👩‍👧abc")',
      );
      checkResult(runtime, '"abc"');
    });

    test('str_removeAt with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"ab"');
    });

    test('String indexing with grapheme', () {
      final RuntimeFacade runtime = getRuntime('main() = "a👨‍👩‍👧b"[1]');
      checkResult(runtime, '"👨‍👩‍👧"');
    });
  });

  group('String Edge Cases', () {
    test('str_reverse empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("")');
      checkResult(runtime, '""');
    });

    test('str_bytes empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes("")');
      checkResult(runtime, []);
    });

    test('str_split empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split("", ",")');
      checkResult(runtime, ['""']);
    });

    test('list_join single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_match negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello123", "^[0-9]+\$")',
      );
      checkResult(runtime, false);
    });

    test('str_match throws ParseError for invalid regex', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello", "[invalid")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('str_contains empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("Hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_replace empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("abc", "", "x")',
      );
      checkResult(runtime, '"xaxbxcx"');
    });

    test('str_indexOf empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("Hello", "")',
      );
      checkResult(runtime, 0);
    });

    test('str_take clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("Hi", 10)');
      checkResult(runtime, '"Hi"');
    });

    test('str_drop clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("Hi", 10)');
      checkResult(runtime, '""');
    });

    test('str_init returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("")');
      checkResult(runtime, '""');
    });

    test('str_init returns empty string for single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("a")');
      checkResult(runtime, '""');
    });

    test('str_uppercase returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_uppercase("")');
      checkResult(runtime, '""');
    });

    test('str_lowercase returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lowercase("")');
      checkResult(runtime, '""');
    });

    test('str_trim returns empty string for whitespace-only input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trim("   ")');
      checkResult(runtime, '""');
    });

    test('str_concat with empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str_concat("", "")');
      checkResult(runtime, '""');
    });

    test('str_compare with empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str_compare("", "")');
      checkResult(runtime, 0);
    });

    test('str_startsWith returns true for empty prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith returns true for empty suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_length returns zero for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length("")');
      checkResult(runtime, 0);
    });

    test('str_padLeft with empty padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("ab", 5, "")',
      );
      checkResult(runtime, '"ab"');
    });

    test('str_padRight with empty padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("ab", 5, "")',
      );
      checkResult(runtime, '"ab"');
    });

    test('str_removeAt removes first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("Hello", 0)',
      );
      checkResult(runtime, '"ello"');
    });

    test('str_substring returns empty string for equal indices', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 2, 2)',
      );
      checkResult(runtime, '""');
    });

    test('str_substring returns full string with zero and length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 0, 5)',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_take returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("", 5)');
      checkResult(runtime, '""');
    });

    test('str_drop returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("", 5)');
      checkResult(runtime, '""');
    });

    test('str_match returns true for empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_match returns true for empty string with empty pattern', () {
      final RuntimeFacade runtime = getRuntime('main() = str_match("", "")');
      checkResult(runtime, true);
    });

    test('str_reverse returns single character unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("a")');
      checkResult(runtime, '"a"');
    });

    test('str_indexOf returns zero for empty pattern in non-empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("abc", "")',
      );
      checkResult(runtime, 0);
    });

    test('str_contains returns true for empty pattern in empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_contains("", "")');
      checkResult(runtime, true);
    });

    test('str_startsWith returns true for empty string with empty prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("", "")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith returns true for empty string with empty suffix', () {
      final RuntimeFacade runtime = getRuntime('main() = str_endsWith("", "")');
      checkResult(runtime, true);
    });

    test('str_split empty string with empty delimiter returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split("", "")');
      checkResult(runtime, []);
    });

    test('str_padLeft pads with multi-character padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("x", 4, "ab")',
      );
      checkResult(runtime, '"abababx"');
    });

    test('str_padRight pads with multi-character padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("x", 4, "ab")',
      );
      checkResult(runtime, '"xababab"');
    });

    test('str_bytes for multi-byte character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes("€")');
      checkResult(runtime, [226, 130, 172]);
    });

    test('str_compare returns negative one for empty string vs non-empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_compare("", "a")');
      checkResult(runtime, -1);
    });

    test('str_compare returns one for non-empty string vs empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_compare("a", "")');
      checkResult(runtime, 1);
    });

    test('str_concat with first empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("", "hello")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_concat with second empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("hello", "")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_trim returns same string when no whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trim("hello")');
      checkResult(runtime, '"hello"');
    });

    test('str_trim with tabs and newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trim("\\t\\nhello\\n\\t")',
      );
      checkResult(runtime, '"hello"');
    });
  });

  group('String Type Errors', () {
    test('str_length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_uppercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_uppercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_lowercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lowercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_contains throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_split throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split(42, ",")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_replace throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace(42, "a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_reverse throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str_trim throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trim(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test(
      'str_at throws InvalidArgumentTypesError for wrong first argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = str_at(42, 0)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_at throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_at("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test('str_bytes throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_concat throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_concat(42, "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_compare throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_compare(42, "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_startsWith throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_endsWith throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_padLeft throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft(42, 5, "0")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_padRight throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight(42, 5, "0")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_match throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match(42, "[a-z]+")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_first throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_last throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_init throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_rest throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_isEmpty throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_isNotEmpty throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_take throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take(42, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_drop throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop(42, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_removeAt throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_removeAt(42, 0)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'str_contains throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_contains("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_split throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_split("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_substring throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring("Hello", "x", 3)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_substring throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring("Hello", 0, "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_replace throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_replace("Hello", 42, "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_replace throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_replace("Hello", "l", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_padLeft throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_padLeft("Hello", "x", "0")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_padLeft throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_padLeft("Hello", 10, 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_padRight throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_padRight("Hello", "x", "0")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_padRight throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_padRight("Hello", 10, 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_take throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_take("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_drop throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_drop("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_removeAt throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_removeAt("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_match throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_match("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_compare throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_compare("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_startsWith throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_startsWith("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_endsWith throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_endsWith("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_concat throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_concat("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('Unicode Escape Sequences', () {
    test('\\xXX escape produces correct character', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\x48\\x69"');
      checkResult(runtime, '"Hi"');
    });

    test('\\xXX escape for special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "Say \\x22hello\\x22"',
      );
      checkResult(runtime, '"Say "hello""');
    });

    test('\\uXXXX escape produces correct character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "\\u0048\\u0065\\u006C\\u006C\\u006F"',
      );
      checkResult(runtime, '"Hello"');
    });

    test('\\uXXXX escape for Greek letter', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u03B1"');
      checkResult(runtime, '"α"');
    });

    test('\\u{...} escape short form', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{48}ello"');
      checkResult(runtime, '"Hello"');
    });

    test('\\u{...} escape for emoji', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{1F600}"');
      checkResult(runtime, '"😀"');
    });

    test('\\u{...} escape for max code point', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{10FFFF}"');
      checkResult(runtime, '"\u{10FFFF}"');
    });

    test('Mixed unicode escapes in one string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "\\x41\\u0042\\u{43}"',
      );
      checkResult(runtime, '"ABC"');
    });

    test('Unicode escapes in single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main() = '\\u{1F600}'");
      checkResult(runtime, '"😀"');
    });

    test('Unicode escape with str_length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("\\u{1F600}")',
      );
      checkResult(runtime, 1);
    });

    test('Unicode escape with str_first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_first("\\u{1F600}abc")',
      );
      checkResult(runtime, '"😀"');
    });

    test('Unicode escape with str_reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_reverse("a\\u{1F600}b")',
      );
      checkResult(runtime, '"b😀a"');
    });

    test('Unicode escape with string comparison', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{41}" == "A"');
      checkResult(runtime, true);
    });

    test('Unicode escape with string concatenation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("\\u{48}", "\\u{69}")',
      );
      checkResult(runtime, '"Hi"');
    });

    test('Unicode escape in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = ["\\u{41}", "\\u{42}"]',
      );
      checkResult(runtime, ['"A"', '"B"']);
    });

    test('Unicode escape in map key', () {
      final RuntimeFacade runtime = getRuntime('main() = {"\\u{6B}": 1}["k"]');
      checkResult(runtime, 1);
    });

    test('Unicode escape in map value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"k": "\\u{76}"}["k"]',
      );
      checkResult(runtime, '"v"');
    });

    test('Combining unicode escapes with regular escapes', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\n\\u{41}\\t"');
      checkResult(runtime, '"\nA\t"');
    });
  });

  group('String Error Cases', () {
    test('str_at throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", 10)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('10'),
              contains('length: 5'),
              contains('str_at'),
            ),
          ),
        ),
      );
    });

    test('str_at throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", -1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_at'),
            ),
          ),
        ),
      );
    });

    test(
      'str_substring throws InvalidArgumentTypesError for number instead of string',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring(123, 0, 2)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'str_substring throws IndexOutOfBoundsError when start exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring("ab", 5, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('5'),
                contains('length: 2'),
                contains('str_substring'),
              ),
            ),
          ),
        );
      },
    );

    test('str_length throws InvalidArgumentTypesError for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'str_indexOf throws InvalidArgumentTypesError for number first argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_indexOf(42, "x")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'str_indexOf throws InvalidArgumentTypesError for number second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_indexOf("Hello", 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str_first throws EmptyCollectionError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('string'),
              contains('str_first'),
            ),
          ),
        ),
      );
    });

    test('str_last throws EmptyCollectionError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('string'),
              contains('str_last'),
            ),
          ),
        ),
      );
    });

    test('str_take throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_take("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_take'),
            ),
          ),
        ),
      );
    });

    test('str_drop throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_drop("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_drop'),
            ),
          ),
        ),
      );
    });

    test('str_removeAt throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_removeAt'),
            ),
          ),
        ),
      );
    });

    test(
      'str_removeAt throws IndexOutOfBoundsError for out-of-bounds index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_removeAt("Hello", 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 5'),
                contains('str_removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('str_substring throws NegativeIndexError for negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", -1, 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_substring'),
            ),
          ),
        ),
      );
    });

    test(
      'str_substring throws IndexOutOfBoundsError when end is less than start',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring("Hello", 3, 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('1'),
                contains('str_substring'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'str_substring throws IndexOutOfBoundsError when end exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_substring("Hello", 0, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 5'),
                contains('str_substring'),
              ),
            ),
          ),
        );
      },
    );

    test('str_replace throws ParseError for invalid regex pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("hello", "[invalid", "x")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test(
      'str_removeAt throws IndexOutOfBoundsError when removing from empty string',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_removeAt("", 0)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('0'),
                contains('length: 0'),
                contains('str_removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('str_at throws IndexOutOfBoundsError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("", 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('str_at'),
            ),
          ),
        ),
      );
    });

    test('str_substring throws NegativeIndexError for negative end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str_substring'),
            ),
          ),
        ),
      );
    });
  });

  group('String Indexing Error Cases', () {
    test('String indexing throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"[-1]');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            contains('-1'),
          ),
        ),
      );
    });

    test(
      'String indexing throws IndexOutOfBoundsError for out-of-bounds index',
      () {
        final RuntimeFacade runtime = getRuntime('main() = "Hello"[10]');
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 5'),
              ),
            ),
          ),
        );
      },
    );

    test('String indexing throws IndexOutOfBoundsError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = ""[0]');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
            ),
          ),
        ),
      );
    });
  });

  group('String Additional Edge Cases', () {
    test('str_length with single grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str_at at index zero returns first character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", 0)');
      checkResult(runtime, '"H"');
    });

    test('str_at at last index returns last character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", 4)');
      checkResult(runtime, '"o"');
    });

    test('str_indexOf returns correct index for last character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("Hello", "o")',
      );
      checkResult(runtime, 4);
    });

    test('str_indexOf returns first occurrence with multiple matches', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("banana", "a")',
      );
      checkResult(runtime, 1);
    });

    test('str_contains is case sensitive', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("Hello", "HELLO")',
      );
      checkResult(runtime, false);
    });

    test('str_startsWith with prefix longer than string returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("Hi", "Hello")',
      );
      checkResult(runtime, false);
    });

    test('str_endsWith with suffix longer than string returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("Hi", "Hello")',
      );
      checkResult(runtime, false);
    });

    test('str_startsWith with same string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("Hello", "Hello")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith with same string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("Hello", "Hello")',
      );
      checkResult(runtime, true);
    });

    test('str_split with delimiter at start and end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split(",a,b,", ",")',
      );
      checkResult(runtime, ['""', '"a"', '"b"', '""']);
    });

    test('str_split with consecutive delimiters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("a,,b", ",")',
      );
      checkResult(runtime, ['"a"', '""', '"b"']);
    });

    test('str_replace with empty replacement', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("hello", "l", "")',
      );
      checkResult(runtime, '"heo"');
    });

    test('str_uppercase with mixed case and numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_uppercase("Hello123World")',
      );
      checkResult(runtime, '"HELLO123WORLD"');
    });

    test('str_lowercase with mixed case and numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lowercase("Hello123World")',
      );
      checkResult(runtime, '"hello123world"');
    });

    test('str_padLeft with negative width returns original string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("Hello", -5, "x")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_padRight with negative width returns original string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("Hello", -5, "x")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_bytes for emoji character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes("😀")');
      checkResult(runtime, [240, 159, 152, 128]);
    });

    test('str_match with anchored regex', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello", "^hello\$")',
      );
      checkResult(runtime, true);
    });

    test('str_match with anchored regex fails for partial match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello world", "^hello\$")',
      );
      checkResult(runtime, false);
    });

    test('str_init preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_init("a👨‍👩‍👧")',
      );
      checkResult(runtime, '"a"');
    });

    test('str_rest preserves graphemes in remaining string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_rest("a👨‍👩‍👧b")',
      );
      checkResult(runtime, '"👨‍👩‍👧b"');
    });

    test('str_removeAt preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("👨‍👩‍👧ab", 0)',
      );
      checkResult(runtime, '"ab"');
    });

    test('str_substring from zero to zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 0, 0)',
      );
      checkResult(runtime, '""');
    });

    test('str_take zero from non-empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("abc", 0)');
      checkResult(runtime, '""');
    });

    test('str_drop more than length returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("abc", 100)');
      checkResult(runtime, '""');
    });

    test('str_compare with unicode strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_compare("äpfel", "banane")',
      );
      // Unicode code point of 'ä' (228) > 'b' (98), so äpfel > banane
      checkResult(runtime, 1);
    });

    test('str_length with multiple graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("👨‍👩‍👧👨‍👩‍👧")',
      );
      checkResult(runtime, 2);
    });

    test('str_rest with single character returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("a")');
      checkResult(runtime, '""');
    });

    test('str_substring with start equal to length returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 5, 5)',
      );
      checkResult(runtime, '""');
    });

    test('str_indexOf with grapheme pattern finds correct position', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("a👨‍👩‍👧bc", "👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str_bytes with grapheme cluster returns all bytes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_bytes("👨‍👩‍👧")',
      );
      // Family grapheme: man + ZWJ + woman + ZWJ + girl
      checkResult(runtime, [
        240,
        159,
        145,
        168,
        226,
        128,
        141,
        240,
        159,
        145,
        169,
        226,
        128,
        141,
        240,
        159,
        145,
        167,
      ]);
    });

    test('str_contains with grapheme returns true when present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("a👨‍👩‍👧b", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str_contains with grapheme returns false when not present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("abc", "👨‍👩‍👧")',
      );
      checkResult(runtime, false);
    });

    test('str_startsWith with grapheme prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("👨‍👩‍👧abc", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith with grapheme suffix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("abc👨‍👩‍👧", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str_split with grapheme delimiter splits correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("a👨‍👩‍👧b👨‍👩‍👧c", "👨‍👩‍👧")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_replace with grapheme pattern replaces correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("a👨‍👩‍👧b", "👨‍👩‍👧", "X")',
      );
      checkResult(runtime, '"aXb"');
    });

    test('str_concat with grapheme strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("👨‍👩‍👧", "abc")',
      );
      checkResult(runtime, '"👨‍👩‍👧abc"');
    });

    test('str_match with digit character class', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("test123", "\\\\d+")',
      );
      checkResult(runtime, true);
    });

    test('str_match with word boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello world", "\\\\bworld\\\\b")',
      );
      checkResult(runtime, true);
    });

    test('str_match returns false when pattern not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello", "\\\\d+")',
      );
      checkResult(runtime, false);
    });

    test('String indexing at last valid index', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"[4]');
      checkResult(runtime, '"o"');
    });

    test('str_uppercase with special characters preserves them', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_uppercase("hello!@#123")',
      );
      checkResult(runtime, '"HELLO!@#123"');
    });

    test('str_lowercase with special characters preserves them', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lowercase("HELLO!@#123")',
      );
      checkResult(runtime, '"hello!@#123"');
    });

    test('str_trim preserves internal whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trim("  hello world  ")',
      );
      checkResult(runtime, '"hello world"');
    });

    test('str_reverse with whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("a b c")');
      checkResult(runtime, '"c b a"');
    });

    test('str_compare case sensitivity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_compare("A", "a")',
      );
      checkResult(runtime, -1);
    });

    test('str_indexOf returns negative one for empty string search', () {
      final RuntimeFacade runtime = getRuntime('main() = str_indexOf("", "a")');
      checkResult(runtime, -1);
    });

    test('str_contains with larger substring than source returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("hi", "hello")',
      );
      checkResult(runtime, false);
    });

    test(
      'str_startsWith returns false for empty source with non-empty prefix',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_startsWith("", "a")',
        );
        checkResult(runtime, false);
      },
    );

    test(
      'str_endsWith returns false for empty source with non-empty suffix',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_endsWith("", "a")',
        );
        checkResult(runtime, false);
      },
    );

    test('str_split with multi-character delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("aXXbXXc", "XX")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_replace replaces overlapping patterns correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("aaa", "aa", "b")',
      );
      // Regex replaceAll is non-overlapping, so first "aa" is replaced
      checkResult(runtime, '"ba"');
    });

    test('str_padLeft with grapheme padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("x", 3, "👨‍👩‍👧")',
      );
      checkResult(runtime, '"👨‍👩‍👧👨‍👩‍👧x"');
    });

    test('str_padRight with grapheme padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("x", 3, "👨‍👩‍👧")',
      );
      checkResult(runtime, '"x👨‍👩‍👧👨‍👩‍👧"');
    });

    test('str_length with combining characters counts graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("e\\u0301")',
      );
      // e followed by combining acute accent should be counted as single grapheme
      checkResult(runtime, 1);
    });

    test('str_at with combining characters returns full grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_at("ae\\u0301b", 1)',
      );
      // Should return the composed character
      checkResult(runtime, '"e\u0301"');
    });
  });

  group('String Large Input Tests', () {
    test('str_length with long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_length("${"a" * 1000}")',
      );
      checkResult(runtime, 1000);
    });

    test('str_reverse with long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_reverse("abc")',
      );
      checkResult(runtime, '"cba"');
    });

    test('str_take with count larger than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_take("abc", 1000)',
      );
      checkResult(runtime, '"abc"');
    });

    test('str_drop with count larger than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_drop("abc", 1000)',
      );
      checkResult(runtime, '""');
    });

    test('str_substring spanning entire string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("hello", 0, 5)',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_concat multiple times', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat(str_concat("a", "b"), "c")',
      );
      checkResult(runtime, '"abc"');
    });
  });

  group('str_repeat', () {
    test('str_repeat repeats string n times', () {
      final RuntimeFacade runtime = getRuntime('main() = str_repeat("ab", 3)');
      checkResult(runtime, '"ababab"');
    });

    test('str_repeat with zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_repeat("ab", 0)');
      checkResult(runtime, '""');
    });

    test('str_repeat with one returns original string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_repeat("ab", 1)');
      checkResult(runtime, '"ab"');
    });

    test('str_repeat with empty string returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_repeat("", 5)');
      checkResult(runtime, '""');
    });

    test('str_repeat throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_repeat("ab", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_repeat throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_repeat(42, 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'str_repeat throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_repeat("ab", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_trimLeft', () {
    test('str_trimLeft removes leading whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimLeft("  hello  ")',
      );
      checkResult(runtime, '"hello  "');
    });

    test('str_trimLeft returns same string when no leading whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimLeft("hello  ")',
      );
      checkResult(runtime, '"hello  "');
    });

    test('str_trimLeft returns empty string for whitespace only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimLeft("   ")',
      );
      checkResult(runtime, '""');
    });

    test('str_trimLeft throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trimLeft(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_trimRight', () {
    test('str_trimRight removes trailing whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimRight("  hello  ")',
      );
      checkResult(runtime, '"  hello"');
    });

    test('str_trimRight returns same string when no trailing whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimRight("  hello")',
      );
      checkResult(runtime, '"  hello"');
    });

    test('str_trimRight returns empty string for whitespace only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trimRight("   ")',
      );
      checkResult(runtime, '""');
    });

    test('str_trimRight throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trimRight(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_capitalize', () {
    test('str_capitalize capitalizes first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_capitalize("hello")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_capitalize returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_capitalize("")');
      checkResult(runtime, '""');
    });

    test('str_capitalize preserves rest of string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_capitalize("hELLO")',
      );
      checkResult(runtime, '"HELLO"');
    });

    test('str_capitalize with single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_capitalize("a")');
      checkResult(runtime, '"A"');
    });

    test('str_capitalize with already capitalized string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_capitalize("Hello")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_capitalize capitalizes a non-ASCII first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_capitalize("émile")',
      );
      checkResult(runtime, '"Émile"');
    });

    test('str_capitalize leaves a grapheme cluster intact', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_capitalize("👨‍👩‍👧 family")',
      );
      checkResult(runtime, '"👨‍👩‍👧 family"');
    });

    test('str_capitalize throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_capitalize(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_lastIndexOf', () {
    test('str_lastIndexOf returns last occurrence index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("hello", "l")',
      );
      checkResult(runtime, 3);
    });

    test('str_lastIndexOf returns negative one when not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("hello", "x")',
      );
      checkResult(runtime, -1);
    });

    test('str_lastIndexOf returns index for single occurrence', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("hello", "h")',
      );
      checkResult(runtime, 0);
    });

    test('str_lastIndexOf with empty pattern returns last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("hello", "")',
      );
      checkResult(runtime, 5);
    });

    test('str_lastIndexOf with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lastIndexOf("a👨‍👩‍👧b👨‍👩‍👧c", "👨‍👩‍👧")',
      );
      checkResult(runtime, 3);
    });

    test(
      'str_lastIndexOf throws InvalidArgumentTypesError for wrong type',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_lastIndexOf(42, "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str_lastIndexOf throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_lastIndexOf("hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_count', () {
    test('str_count counts occurrences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_count("banana", "a")',
      );
      checkResult(runtime, 3);
    });

    test('str_count returns zero when not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_count("hello", "x")',
      );
      checkResult(runtime, 0);
    });

    test('str_count with overlapping pattern counts non-overlapping', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_count("aaa", "aa")',
      );
      checkResult(runtime, 1);
    });

    test('str_count with empty string and pattern', () {
      final RuntimeFacade runtime = getRuntime('main() = str_count("", "a")');
      checkResult(runtime, 0);
    });

    test('str_count counts multi-codepoint grapheme clusters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_count("a👨‍👩‍👧b👨‍👩‍👧c", "👨‍👩‍👧")',
      );
      checkResult(runtime, 2);
    });

    test('str_count with empty pattern counts positions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_count("abc", "")',
      );
      checkResult(runtime, 4);
    });

    test('str_count throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_count(42, "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'str_count throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_count("hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_isUppercase', () {
    test('str_isUppercase returns true for uppercase string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isUppercase("HELLO")',
      );
      checkResult(runtime, true);
    });

    test('str_isUppercase returns false for mixed case', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isUppercase("Hello")',
      );
      checkResult(runtime, false);
    });

    test('str_isUppercase returns false for lowercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isUppercase("hello")',
      );
      checkResult(runtime, false);
    });

    test('str_isUppercase returns true for uppercase with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isUppercase("HELLO123")',
      );
      checkResult(runtime, true);
    });

    test('str_isUppercase returns false for numbers only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isUppercase("123")',
      );
      checkResult(runtime, false);
    });

    test('str_isUppercase returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isUppercase("")');
      checkResult(runtime, false);
    });

    test(
      'str_isUppercase throws InvalidArgumentTypesError for wrong type',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_isUppercase(42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_isLowercase', () {
    test('str_isLowercase returns true for lowercase string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isLowercase("hello")',
      );
      checkResult(runtime, true);
    });

    test('str_isLowercase returns false for mixed case', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isLowercase("Hello")',
      );
      checkResult(runtime, false);
    });

    test('str_isLowercase returns false for uppercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isLowercase("HELLO")',
      );
      checkResult(runtime, false);
    });

    test('str_isLowercase returns true for lowercase with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isLowercase("hello123")',
      );
      checkResult(runtime, true);
    });

    test('str_isLowercase returns false for numbers only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isLowercase("123")',
      );
      checkResult(runtime, false);
    });

    test('str_isLowercase returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isLowercase("")');
      checkResult(runtime, false);
    });

    test(
      'str_isLowercase throws InvalidArgumentTypesError for wrong type',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_isLowercase(42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_isAlpha', () {
    test('str_isAlpha returns true for letters only', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isAlpha("hello")');
      checkResult(runtime, true);
    });

    test('str_isAlpha returns true for mixed case letters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isAlpha("HeLLo")');
      checkResult(runtime, true);
    });

    test('str_isAlpha returns false for alphanumeric', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlpha("hello123")',
      );
      checkResult(runtime, false);
    });

    test('str_isAlpha returns false for numbers only', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isAlpha("123")');
      checkResult(runtime, false);
    });

    test('str_isAlpha returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isAlpha("")');
      checkResult(runtime, false);
    });

    test('str_isAlpha returns false for string with spaces', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlpha("hello world")',
      );
      checkResult(runtime, false);
    });

    test('str_isAlpha throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isAlpha(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_isNumeric', () {
    test('str_isNumeric returns true for digits only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isNumeric("12345")',
      );
      checkResult(runtime, true);
    });

    test('str_isNumeric returns false for decimal numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isNumeric("123.45")',
      );
      checkResult(runtime, false);
    });

    test('str_isNumeric returns false for negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isNumeric("-123")',
      );
      checkResult(runtime, false);
    });

    test('str_isNumeric returns false for letters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isNumeric("hello")',
      );
      checkResult(runtime, false);
    });

    test('str_isNumeric returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNumeric("")');
      checkResult(runtime, false);
    });

    test('str_isNumeric throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNumeric(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_isAlphaNumeric', () {
    test('str_isAlphaNumeric returns true for letters and digits', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("hello123")',
      );
      checkResult(runtime, true);
    });

    test('str_isAlphaNumeric returns true for letters only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("hello")',
      );
      checkResult(runtime, true);
    });

    test('str_isAlphaNumeric returns true for digits only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("123")',
      );
      checkResult(runtime, true);
    });

    test('str_isAlphaNumeric returns false for special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("hello-123")',
      );
      checkResult(runtime, false);
    });

    test('str_isAlphaNumeric returns false for spaces', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("hello 123")',
      );
      checkResult(runtime, false);
    });

    test('str_isAlphaNumeric returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isAlphaNumeric("")',
      );
      checkResult(runtime, false);
    });

    test(
      'str_isAlphaNumeric throws InvalidArgumentTypesError for wrong type',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_isAlphaNumeric(42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );
  });

  group('str_fromBytes', () {
    test('str_fromBytes converts bytes to string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_fromBytes([72, 101, 108, 108, 111])',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_fromBytes returns empty string for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = str_fromBytes([])');
      checkResult(runtime, '""');
    });

    test('str_fromBytes handles multi-byte characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_fromBytes([226, 130, 172])',
      );
      checkResult(runtime, '"€"');
    });

    test('str_fromBytes roundtrips with str_bytes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_fromBytes(str_bytes("Hello"))',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str_fromBytes throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_fromBytes(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'str_fromBytes throws InvalidArgumentTypesError for non-number list',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_fromBytes(["a", "b"])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test('str_fromBytes throws ParseError for invalid UTF-8 sequence', () {
      final RuntimeFacade runtime = getRuntime('main() = str_fromBytes([255])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            contains('str_fromBytes'),
          ),
        ),
      );
    });
  });

  group('str_isBlank', () {
    test('str_isBlank returns true for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isBlank("")');
      checkResult(runtime, true);
    });

    test('str_isBlank returns true for whitespace only', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isBlank("   ")');
      checkResult(runtime, true);
    });

    test('str_isBlank returns true for tabs and newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isBlank("\\t\\n")',
      );
      checkResult(runtime, true);
    });

    test('str_isBlank returns false for non-whitespace content', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_isBlank("  hello  ")',
      );
      checkResult(runtime, false);
    });

    test('str_isBlank returns false for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isBlank("hello")');
      checkResult(runtime, false);
    });

    test('str_isBlank throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isBlank(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('str_lines', () {
    test('str_lines splits by newline', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lines("a\\nb\\nc")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_lines splits by carriage return', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lines("a\\x0Db\\x0Dc")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_lines splits by carriage return newline', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lines("a\\x0D\\nb\\x0D\\nc")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_lines returns single element for no line breaks', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lines("hello")');
      checkResult(runtime, ['"hello"']);
    });

    test('str_lines returns empty strings for consecutive breaks', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_lines("a\\n\\nb")',
      );
      checkResult(runtime, ['"a"', '""', '"b"']);
    });

    test('str_lines returns single empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lines("")');
      checkResult(runtime, ['""']);
    });

    test('str_lines throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lines(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('String Whitespace Edge Cases', () {
    test('str_trim with only newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trim("\\n\\n\\n")',
      );
      checkResult(runtime, '""');
    });

    test('str_trim with multiple newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_trim("\\n\\nhello\\n\\n")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_split with newline delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("a\\nb\\nc", "\\n")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_contains with whitespace pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("hello world", " ")',
      );
      checkResult(runtime, true);
    });

    test('str_indexOf with whitespace finds first space', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("hello world", " ")',
      );
      checkResult(runtime, 5);
    });

    test('str_replace removes all whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("a b c", " ", "")',
      );
      checkResult(runtime, '"abc"');
    });
  });

  group('String Numeric Boundary Tests', () {
    test('str_take with zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("hello", 0)');
      checkResult(runtime, '""');
    });

    test('str_drop with zero returns full string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("hello", 0)');
      checkResult(runtime, '"hello"');
    });

    test('str_padLeft with width equal to string length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft("hello", 5, "x")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_padRight with width equal to string length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight("hello", 5, "x")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_at with zero index on single character string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("x", 0)');
      checkResult(runtime, '"x"');
    });

    test('str_removeAt with last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("hello", 4)',
      );
      checkResult(runtime, '"hell"');
    });

    test('str_substring from start to middle', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("hello", 0, 3)',
      );
      checkResult(runtime, '"hel"');
    });

    test('str_substring from middle to end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("hello", 2, 5)',
      );
      checkResult(runtime, '"llo"');
    });
  });

  group('String Special Character Tests', () {
    test('str_length with backslash', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length("a\\\\b")');
      checkResult(runtime, 3);
    });

    test('str_contains with backslash', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("a\\\\b", "\\\\")',
      );
      checkResult(runtime, true);
    });

    test('str_replace with dollar sign', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("price: \$100", "\\\\d+", "X")',
      );
      checkResult(runtime, '"price: \$X"');
    });

    test('str_split with pipe character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_split("a|b|c", "|")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_match with escaped special regex characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("[test]", "\\\\[test\\\\]")',
      );
      checkResult(runtime, true);
    });

    test('str_concat with quotes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("\\"hello", " world\\"")',
      );
      checkResult(runtime, '""hello world""');
    });
  });
}
