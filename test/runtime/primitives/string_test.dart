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

    test('str.substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("hola", 1, 3)',
      );
      checkResult(runtime, '"ol"');
    });

    test('str.startsWith returns true for matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("hola", "ho")',
      );
      checkResult(runtime, true);
    });

    test('str.startsWith returns false for non-matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("hola", "hoy")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith returns true for matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("hola", "la")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith returns false for non-matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("hola", "lol")',
      );
      checkResult(runtime, false);
    });

    test('str.replace replaces all occurrences of a substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("banana", "na", "to")',
      );
      checkResult(runtime, '"batoto"');
    });

    test('str.replace returns original when pattern not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("banana", "bon", "to")',
      );
      checkResult(runtime, '"banana"');
    });

    test('str.replace replaces characters matching a regex pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("aaa123BBB", "[a-z]", "x")',
      );
      checkResult(runtime, '"xxx123BBB"');
    });

    test('str.uppercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.uppercase("Primal")',
      );
      checkResult(runtime, '"PRIMAL"');
    });

    test('str.lowercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.lowercase("Primal")',
      );
      checkResult(runtime, '"primal"');
    });

    test('str.trim', () {
      final RuntimeFacade runtime = getRuntime('main() = str.trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('str.match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("identifier42", "[a-zA-Z]+[0-9]+")',
      );
      checkResult(runtime, true);
    });

    test('str.length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length("primal")');
      checkResult(runtime, 6);
    });

    test('str.concat', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("Hello", ", world!")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('str.first', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('str.last', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('str.init', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('str.rest returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.rest returns string without first character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str.at', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str.isEmpty returns true for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty returns false for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str.isEmpty returns false for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns true for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str.isNotEmpty returns true for non-empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.isNotEmpty("Hello")',
      );
      checkResult(runtime, true);
    });

    test('str.contains returns true when substring is present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("Hello", "ell")',
      );
      checkResult(runtime, true);
    });

    test('str.contains returns false for case-sensitive mismatch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("Hello", "hell")',
      );
      checkResult(runtime, false);
    });

    test('str.take returns empty string when taking zero characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.take returns first n characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop returns full string when dropping zero characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str.drop returns string after dropping first n characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str.removeAt', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("Hello", 4)',
      );
      checkResult(runtime, '"Hell"');
    });

    test('str.reverse', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('str.bytes', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes("Hello")');
      checkResult(runtime, [72, 101, 108, 108, 111]);
    });

    test('str.indexOf returns negative one when substring not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("Hello", "x")',
      );
      checkResult(runtime, -1);
    });

    test('str.indexOf returns index of first occurrence', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("Hello", "l")',
      );
      checkResult(runtime, 2);
    });

    test('str.padLeft does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft pads string to target width on the left', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("12345", 8, "0")',
      );
      checkResult(runtime, '"00012345"');
    });

    test('str.padRight does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight pads string to target width on the right', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("12345", 8, "0")',
      );
      checkResult(runtime, '"12345000"');
    });

    test('str.split returns single-element list when delimiter not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("aa,bb,cc", "x")',
      );
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test(
      'str.split splits into individual characters with empty delimiter',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.split("aa,bb,cc", "")',
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

    test('str.split splits string by delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("aa,bb,cc", ",")',
      );
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str.compare returns negative one when first string is lesser', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.compare("hello", "mountain")',
      );
      checkResult(runtime, -1);
    });

    test('str.compare returns zero for equal strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.compare("table", "table")',
      );
      checkResult(runtime, 0);
    });

    test('str.compare returns one when first string is greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.compare("monkey", "cat")',
      );
      checkResult(runtime, 1);
    });

    test('str.length counts graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str.at with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.at("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.first with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.first("👨‍👩‍👧abc")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.last with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.last("abc👨‍👩‍👧")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.reverse preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.reverse("a👨‍👩‍👧b")',
      );
      checkResult(runtime, '"b👨‍👩‍👧a"');
    });

    test('str.take with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.take("a👨‍👩‍👧b", 2)',
      );
      checkResult(runtime, '"a👨‍👩‍👧"');
    });

    test('str.drop with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.drop("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧b"');
    });

    test('str.substring with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("a👨‍👩‍👧b", 1, 2)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.indexOf with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("a👨‍👩‍👧b", "b")',
      );
      checkResult(runtime, 2);
    });

    test('str.split with empty delimiter preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("a👨‍👩‍👧b", "")',
      );
      checkResult(runtime, ['"a"', '"👨‍👩‍👧"', '"b"']);
    });

    test('str.init with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.init("abc👨‍👩‍👧")',
      );
      checkResult(runtime, '"abc"');
    });

    test('str.rest with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.rest("👨‍👩‍👧abc")',
      );
      checkResult(runtime, '"abc"');
    });

    test('str.removeAt with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"ab"');
    });

    test('String indexing with grapheme', () {
      final RuntimeFacade runtime = getRuntime('main() = "a👨‍👩‍👧b"[1]');
      checkResult(runtime, '"👨‍👩‍👧"');
    });
  });

  group('String Edge Cases', () {
    test('str.reverse empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("")');
      checkResult(runtime, '""');
    });

    test('str.bytes empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes("")');
      checkResult(runtime, []);
    });

    test('str.split empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split("", ",")');
      checkResult(runtime, ['""']);
    });

    test('str.join single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.match negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello123", "^[0-9]+\$")',
      );
      checkResult(runtime, false);
    });

    test('str.match throws ParseError for invalid regex', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello", "[invalid")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('str.contains empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("Hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.replace empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("abc", "", "x")',
      );
      checkResult(runtime, '"xaxbxcx"');
    });

    test('str.indexOf empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("Hello", "")',
      );
      checkResult(runtime, 0);
    });

    test('str.take clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("Hi", 10)');
      checkResult(runtime, '"Hi"');
    });

    test('str.drop clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("Hi", 10)');
      checkResult(runtime, '""');
    });

    test('str.init returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init("")');
      checkResult(runtime, '""');
    });

    test('str.init returns empty string for single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init("a")');
      checkResult(runtime, '""');
    });

    test('str.uppercase returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.uppercase("")');
      checkResult(runtime, '""');
    });

    test('str.lowercase returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.lowercase("")');
      checkResult(runtime, '""');
    });

    test('str.trim returns empty string for whitespace-only input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.trim("   ")');
      checkResult(runtime, '""');
    });

    test('str.concat with empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str.concat("", "")');
      checkResult(runtime, '""');
    });

    test('str.compare with empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str.compare("", "")');
      checkResult(runtime, 0);
    });

    test('str.startsWith returns true for empty prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith returns true for empty suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.length returns zero for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length("")');
      checkResult(runtime, 0);
    });

    test('str.padLeft with empty padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("ab", 5, "")',
      );
      checkResult(runtime, '"ab"');
    });

    test('str.padRight with empty padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("ab", 5, "")',
      );
      checkResult(runtime, '"ab"');
    });

    test('str.removeAt removes first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("Hello", 0)',
      );
      checkResult(runtime, '"ello"');
    });

    test('str.substring returns empty string for equal indices', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 2, 2)',
      );
      checkResult(runtime, '""');
    });

    test('str.substring returns full string with zero and length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 0, 5)',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str.take returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("", 5)');
      checkResult(runtime, '""');
    });

    test('str.drop returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("", 5)');
      checkResult(runtime, '""');
    });

    test('str.match returns true for empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.match returns true for empty string with empty pattern', () {
      final RuntimeFacade runtime = getRuntime('main() = str.match("", "")');
      checkResult(runtime, true);
    });

    test('str.reverse returns single character unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("a")');
      checkResult(runtime, '"a"');
    });

    test('str.indexOf returns zero for empty pattern in non-empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("abc", "")',
      );
      checkResult(runtime, 0);
    });

    test('str.contains returns true for empty pattern in empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.contains("", "")');
      checkResult(runtime, true);
    });

    test('str.startsWith returns true for empty string with empty prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("", "")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith returns true for empty string with empty suffix', () {
      final RuntimeFacade runtime = getRuntime('main() = str.endsWith("", "")');
      checkResult(runtime, true);
    });

    test('str.split empty string with empty delimiter returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split("", "")');
      checkResult(runtime, []);
    });

    test('str.padLeft pads with multi-character padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("x", 4, "ab")',
      );
      checkResult(runtime, '"abababx"');
    });

    test('str.padRight pads with multi-character padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("x", 4, "ab")',
      );
      checkResult(runtime, '"xababab"');
    });

    test('str.bytes for multi-byte character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes("€")');
      checkResult(runtime, [226, 130, 172]);
    });

    test('str.compare returns negative one for empty string vs non-empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.compare("", "a")');
      checkResult(runtime, -1);
    });

    test('str.compare returns one for non-empty string vs empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.compare("a", "")');
      checkResult(runtime, 1);
    });

    test('str.concat with first empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("", "hello")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.concat with second empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("hello", "")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.trim returns same string when no whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = str.trim("hello")');
      checkResult(runtime, '"hello"');
    });

    test('str.trim with tabs and newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.trim("\\t\\nhello\\n\\t")',
      );
      checkResult(runtime, '"hello"');
    });
  });

  group('String Type Errors', () {
    test('str.length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.uppercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.uppercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.lowercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.lowercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.contains throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.split throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split(42, ",")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.replace throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace(42, "a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.reverse throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.trim throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.trim(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test(
      'str.at throws InvalidArgumentTypesError for wrong first argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = str.at(42, 0)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.at throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.at("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test('str.bytes throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.concat throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.concat(42, "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.compare throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.compare(42, "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.startsWith throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.endsWith throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith(42, "x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padLeft throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft(42, 5, "0")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padRight throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight(42, 5, "0")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.match throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match(42, "[a-z]+")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.first throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.last throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.init throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.rest throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isEmpty throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isNotEmpty throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.take throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take(42, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.drop throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop(42, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.removeAt throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = str.removeAt(42, 0)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'str.contains throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.contains("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.split throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.split("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.substring throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("Hello", "x", 3)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.substring throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("Hello", 0, "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.replace throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.replace("Hello", 42, "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.replace throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.replace("Hello", "l", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.padLeft throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.padLeft("Hello", "x", "0")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.padLeft throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.padLeft("Hello", 10, 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.padRight throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.padRight("Hello", "x", "0")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.padRight throws InvalidArgumentTypesError for wrong third argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.padRight("Hello", 10, 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.take throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.take("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.drop throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.drop("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.removeAt throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.removeAt("Hello", "x")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.match throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.match("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.compare throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.compare("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.startsWith throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.startsWith("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.endsWith throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.endsWith("Hello", 42)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      },
    );

    test(
      'str.concat throws InvalidArgumentTypesError for wrong second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.concat("Hello", 42)',
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

    test('Unicode escape with str.length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("\\u{1F600}")',
      );
      checkResult(runtime, 1);
    });

    test('Unicode escape with str.first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.first("\\u{1F600}abc")',
      );
      checkResult(runtime, '"😀"');
    });

    test('Unicode escape with str.reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.reverse("a\\u{1F600}b")',
      );
      checkResult(runtime, '"b😀a"');
    });

    test('Unicode escape with string comparison', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{41}" == "A"');
      checkResult(runtime, true);
    });

    test('Unicode escape with string concatenation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("\\u{48}", "\\u{69}")',
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
    test('str.at throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", 10)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('10'),
              contains('length: 5'),
              contains('str.at'),
            ),
          ),
        ),
      );
    });

    test('str.at throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", -1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.at'),
            ),
          ),
        ),
      );
    });

    test(
      'str.substring throws InvalidArgumentTypesError for number instead of string',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring(123, 0, 2)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'str.substring throws IndexOutOfBoundsError when start exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("ab", 5, 10)',
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
                contains('str.substring'),
              ),
            ),
          ),
        );
      },
    );

    test('str.length throws InvalidArgumentTypesError for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'str.indexOf throws InvalidArgumentTypesError for number first argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.indexOf(42, "x")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'str.indexOf throws InvalidArgumentTypesError for number second argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.indexOf("Hello", 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str.first throws EmptyCollectionError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('string'),
              contains('str.first'),
            ),
          ),
        ),
      );
    });

    test('str.last throws EmptyCollectionError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('string'),
              contains('str.last'),
            ),
          ),
        ),
      );
    });

    test('str.take throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.take("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.take'),
            ),
          ),
        ),
      );
    });

    test('str.drop throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.drop("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.drop'),
            ),
          ),
        ),
      );
    });

    test('str.removeAt throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("Hello", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.removeAt'),
            ),
          ),
        ),
      );
    });

    test(
      'str.removeAt throws IndexOutOfBoundsError for out-of-bounds index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.removeAt("Hello", 10)',
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
                contains('str.removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('str.substring throws NegativeIndexError for negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", -1, 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.substring'),
            ),
          ),
        ),
      );
    });

    test(
      'str.substring throws IndexOutOfBoundsError when end is less than start',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("Hello", 3, 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('1'),
                contains('str.substring'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'str.substring throws IndexOutOfBoundsError when end exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("Hello", 0, 10)',
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
                contains('str.substring'),
              ),
            ),
          ),
        );
      },
    );

    test('str.replace throws FormatException for invalid regex pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("hello", "[invalid", "x")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'str.removeAt throws IndexOutOfBoundsError when removing from empty string',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.removeAt("", 0)',
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
                contains('str.removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('str.at throws IndexOutOfBoundsError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("", 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('str.at'),
            ),
          ),
        ),
      );
    });

    test('str.substring throws NegativeIndexError for negative end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('str.substring'),
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
    test('str.length with single grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str.at at index zero returns first character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", 0)');
      checkResult(runtime, '"H"');
    });

    test('str.at at last index returns last character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", 4)');
      checkResult(runtime, '"o"');
    });

    test('str.indexOf returns correct index for last character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("Hello", "o")',
      );
      checkResult(runtime, 4);
    });

    test('str.indexOf returns first occurrence with multiple matches', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("banana", "a")',
      );
      checkResult(runtime, 1);
    });

    test('str.contains is case sensitive', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("Hello", "HELLO")',
      );
      checkResult(runtime, false);
    });

    test('str.startsWith with prefix longer than string returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("Hi", "Hello")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith with suffix longer than string returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("Hi", "Hello")',
      );
      checkResult(runtime, false);
    });

    test('str.startsWith with same string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("Hello", "Hello")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith with same string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("Hello", "Hello")',
      );
      checkResult(runtime, true);
    });

    test('str.split with delimiter at start and end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split(",a,b,", ",")',
      );
      checkResult(runtime, ['""', '"a"', '"b"', '""']);
    });

    test('str.split with consecutive delimiters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("a,,b", ",")',
      );
      checkResult(runtime, ['"a"', '""', '"b"']);
    });

    test('str.replace with empty replacement', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("hello", "l", "")',
      );
      checkResult(runtime, '"heo"');
    });

    test('str.uppercase with mixed case and numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.uppercase("Hello123World")',
      );
      checkResult(runtime, '"HELLO123WORLD"');
    });

    test('str.lowercase with mixed case and numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.lowercase("Hello123World")',
      );
      checkResult(runtime, '"hello123world"');
    });

    test('str.padLeft with negative width returns original string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("Hello", -5, "x")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str.padRight with negative width returns original string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("Hello", -5, "x")',
      );
      checkResult(runtime, '"Hello"');
    });

    test('str.bytes for emoji character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes("😀")');
      checkResult(runtime, [240, 159, 152, 128]);
    });

    test('str.match with anchored regex', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello", "^hello\$")',
      );
      checkResult(runtime, true);
    });

    test('str.match with anchored regex fails for partial match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello world", "^hello\$")',
      );
      checkResult(runtime, false);
    });

    test('str.init preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.init("a👨‍👩‍👧")',
      );
      checkResult(runtime, '"a"');
    });

    test('str.rest preserves graphemes in remaining string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.rest("a👨‍👩‍👧b")',
      );
      checkResult(runtime, '"👨‍👩‍👧b"');
    });

    test('str.removeAt preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("👨‍👩‍👧ab", 0)',
      );
      checkResult(runtime, '"ab"');
    });

    test('str.substring from zero to zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 0, 0)',
      );
      checkResult(runtime, '""');
    });

    test('str.take zero from non-empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("abc", 0)');
      checkResult(runtime, '""');
    });

    test('str.drop more than length returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("abc", 100)');
      checkResult(runtime, '""');
    });

    test('str.compare with unicode strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.compare("äpfel", "banane")',
      );
      // Unicode code point of 'ä' (228) > 'b' (98), so äpfel > banane
      checkResult(runtime, 1);
    });

    test('str.length with multiple graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("👨‍👩‍👧👨‍👩‍👧")',
      );
      checkResult(runtime, 2);
    });

    test('str.rest with single character returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest("a")');
      checkResult(runtime, '""');
    });

    test('str.substring with start equal to length returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 5, 5)',
      );
      checkResult(runtime, '""');
    });

    test('str.indexOf with grapheme pattern finds correct position', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("a👨‍👩‍👧bc", "👨‍👩‍👧")',
      );
      checkResult(runtime, 1);
    });

    test('str.bytes with grapheme cluster returns all bytes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.bytes("👨‍👩‍👧")',
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

    test('str.contains with grapheme returns true when present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("a👨‍👩‍👧b", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str.contains with grapheme returns false when not present', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("abc", "👨‍👩‍👧")',
      );
      checkResult(runtime, false);
    });

    test('str.startsWith with grapheme prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("👨‍👩‍👧abc", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith with grapheme suffix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("abc👨‍👩‍👧", "👨‍👩‍👧")',
      );
      checkResult(runtime, true);
    });

    test('str.split with grapheme delimiter splits correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("a👨‍👩‍👧b👨‍👩‍👧c", "👨‍👩‍👧")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str.replace with grapheme pattern replaces correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("a👨‍👩‍👧b", "👨‍👩‍👧", "X")',
      );
      checkResult(runtime, '"aXb"');
    });

    test('str.concat with grapheme strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("👨‍👩‍👧", "abc")',
      );
      checkResult(runtime, '"👨‍👩‍👧abc"');
    });

    test('str.match with digit character class', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("test123", "\\\\d+")',
      );
      checkResult(runtime, true);
    });

    test('str.match with word boundary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello world", "\\\\bworld\\\\b")',
      );
      checkResult(runtime, true);
    });

    test('str.match returns false when pattern not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello", "\\\\d+")',
      );
      checkResult(runtime, false);
    });

    test('String indexing at last valid index', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"[4]');
      checkResult(runtime, '"o"');
    });

    test('str.uppercase with special characters preserves them', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.uppercase("hello!@#123")',
      );
      checkResult(runtime, '"HELLO!@#123"');
    });

    test('str.lowercase with special characters preserves them', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.lowercase("HELLO!@#123")',
      );
      checkResult(runtime, '"hello!@#123"');
    });

    test('str.trim preserves internal whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.trim("  hello world  ")',
      );
      checkResult(runtime, '"hello world"');
    });

    test('str.reverse with whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("a b c")');
      checkResult(runtime, '"c b a"');
    });

    test('str.compare case sensitivity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.compare("A", "a")',
      );
      checkResult(runtime, -1);
    });

    test('str.indexOf returns negative one for empty string search', () {
      final RuntimeFacade runtime = getRuntime('main() = str.indexOf("", "a")');
      checkResult(runtime, -1);
    });

    test('str.contains with larger substring than source returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("hi", "hello")',
      );
      checkResult(runtime, false);
    });

    test(
      'str.startsWith returns false for empty source with non-empty prefix',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.startsWith("", "a")',
        );
        checkResult(runtime, false);
      },
    );

    test(
      'str.endsWith returns false for empty source with non-empty suffix',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.endsWith("", "a")',
        );
        checkResult(runtime, false);
      },
    );

    test('str.split with multi-character delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("aXXbXXc", "XX")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str.replace replaces overlapping patterns correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("aaa", "aa", "b")',
      );
      // Regex replaceAll is non-overlapping, so first "aa" is replaced
      checkResult(runtime, '"ba"');
    });

    test('str.padLeft with grapheme padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("x", 3, "👨‍👩‍👧")',
      );
      checkResult(runtime, '"👨‍👩‍👧👨‍👩‍👧x"');
    });

    test('str.padRight with grapheme padding string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("x", 3, "👨‍👩‍👧")',
      );
      checkResult(runtime, '"x👨‍👩‍👧👨‍👩‍👧"');
    });

    test('str.length with combining characters counts graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("e\\u0301")',
      );
      // e followed by combining acute accent should be counted as single grapheme
      checkResult(runtime, 1);
    });

    test('str.at with combining characters returns full grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.at("ae\\u0301b", 1)',
      );
      // Should return the composed character
      checkResult(runtime, '"e\u0301"');
    });
  });

  group('String Large Input Tests', () {
    test('str.length with long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.length("${"a" * 1000}")',
      );
      checkResult(runtime, 1000);
    });

    test('str.reverse with long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.reverse("abc")',
      );
      checkResult(runtime, '"cba"');
    });

    test('str.take with count larger than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.take("abc", 1000)',
      );
      checkResult(runtime, '"abc"');
    });

    test('str.drop with count larger than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.drop("abc", 1000)',
      );
      checkResult(runtime, '""');
    });

    test('str.substring spanning entire string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("hello", 0, 5)',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.concat multiple times', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat(str.concat("a", "b"), "c")',
      );
      checkResult(runtime, '"abc"');
    });
  });

  group('String Whitespace Edge Cases', () {
    test('str.trim with only newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.trim("\\n\\n\\n")',
      );
      checkResult(runtime, '""');
    });

    test('str.trim with multiple newlines', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.trim("\\n\\nhello\\n\\n")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.split with newline delimiter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("a\\nb\\nc", "\\n")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str.contains with whitespace pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("hello world", " ")',
      );
      checkResult(runtime, true);
    });

    test('str.indexOf with whitespace finds first space', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("hello world", " ")',
      );
      checkResult(runtime, 5);
    });

    test('str.replace removes all whitespace', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("a b c", " ", "")',
      );
      checkResult(runtime, '"abc"');
    });
  });

  group('String Numeric Boundary Tests', () {
    test('str.take with zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.drop with zero returns full string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("hello", 0)');
      checkResult(runtime, '"hello"');
    });

    test('str.padLeft with width equal to string length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft("hello", 5, "x")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.padRight with width equal to string length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight("hello", 5, "x")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.at with zero index on single character string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("x", 0)');
      checkResult(runtime, '"x"');
    });

    test('str.removeAt with last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("hello", 4)',
      );
      checkResult(runtime, '"hell"');
    });

    test('str.substring from start to middle', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("hello", 0, 3)',
      );
      checkResult(runtime, '"hel"');
    });

    test('str.substring from middle to end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("hello", 2, 5)',
      );
      checkResult(runtime, '"llo"');
    });
  });

  group('String Special Character Tests', () {
    test('str.length with backslash', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length("a\\\\b")');
      checkResult(runtime, 3);
    });

    test('str.contains with backslash', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("a\\\\b", "\\\\")',
      );
      checkResult(runtime, true);
    });

    test('str.replace with dollar sign', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.replace("price: \$100", "\\\\d+", "X")',
      );
      checkResult(runtime, '"price: \$X"');
    });

    test('str.split with pipe character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.split("a|b|c", "|")',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str.match with escaped special regex characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("[test]", "\\\\[test\\\\]")',
      );
      checkResult(runtime, true);
    });

    test('str.concat with quotes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("\\"hello", " world\\"")',
      );
      checkResult(runtime, '""hello world""');
    });
  });
}
