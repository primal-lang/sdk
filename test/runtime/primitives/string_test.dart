@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('String', () {
    test('String indexing', () {
      final Runtime runtime = getRuntime('main = "Hello"[1]');
      checkResult(runtime, '"e"');
    });

    test('str.substring', () {
      final Runtime runtime = getRuntime('main = str.substring("hola", 1, 3)');
      checkResult(runtime, '"ol"');
    });

    test('str.startsWith returns true for matching prefix', () {
      final Runtime runtime = getRuntime('main = str.startsWith("hola", "ho")');
      checkResult(runtime, true);
    });

    test('str.startsWith returns false for non-matching prefix', () {
      final Runtime runtime = getRuntime(
        'main = str.startsWith("hola", "hoy")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith returns true for matching suffix', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "la")');
      checkResult(runtime, true);
    });

    test('str.endsWith returns false for non-matching suffix', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "lol")');
      checkResult(runtime, false);
    });

    test('str.replace replaces all occurrences of a substring', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("banana", "na", "to")',
      );
      checkResult(runtime, '"batoto"');
    });

    test('str.replace returns original when pattern not found', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("banana", "bon", "to")',
      );
      checkResult(runtime, '"banana"');
    });

    test('str.replace replaces characters matching a regex pattern', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("aaa123BBB", "[a-z]", "x")',
      );
      checkResult(runtime, '"xxx123BBB"');
    });

    test('str.uppercase', () {
      final Runtime runtime = getRuntime('main = str.uppercase("Primal")');
      checkResult(runtime, '"PRIMAL"');
    });

    test('str.lowercase', () {
      final Runtime runtime = getRuntime('main = str.lowercase("Primal")');
      checkResult(runtime, '"primal"');
    });

    test('str.trim', () {
      final Runtime runtime = getRuntime('main = str.trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('str.match', () {
      final Runtime runtime = getRuntime(
        'main = str.match("identifier42", "[a-zA-Z]+[0-9]+")',
      );
      checkResult(runtime, true);
    });

    test('str.length', () {
      final Runtime runtime = getRuntime('main = str.length("primal")');
      checkResult(runtime, 6);
    });

    test('str.concat', () {
      final Runtime runtime = getRuntime(
        'main = str.concat("Hello", ", world!")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('str.first', () {
      final Runtime runtime = getRuntime('main = str.first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('str.last', () {
      final Runtime runtime = getRuntime('main = str.last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('str.init', () {
      final Runtime runtime = getRuntime('main = str.init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('str.rest returns empty string for empty input', () {
      final Runtime runtime = getRuntime('main = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.rest returns string without first character', () {
      final Runtime runtime = getRuntime('main = str.rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str.at', () {
      final Runtime runtime = getRuntime('main = str.at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str.isEmpty returns true for empty string', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty returns false for whitespace-only string', () {
      final Runtime runtime = getRuntime('main = str.isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str.isEmpty returns false for non-empty string', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns false for empty string', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns true for whitespace-only string', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str.isNotEmpty returns true for non-empty string', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("Hello")');
      checkResult(runtime, true);
    });

    test('str.contains returns true when substring is present', () {
      final Runtime runtime = getRuntime('main = str.contains("Hello", "ell")');
      checkResult(runtime, true);
    });

    test('str.contains returns false for case-sensitive mismatch', () {
      final Runtime runtime = getRuntime(
        'main = str.contains("Hello", "hell")',
      );
      checkResult(runtime, false);
    });

    test('str.take returns empty string when taking zero characters', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.take returns first n characters', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop returns full string when dropping zero characters', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str.drop returns string after dropping first n characters', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str.removeAt', () {
      final Runtime runtime = getRuntime('main = str.removeAt("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.reverse', () {
      final Runtime runtime = getRuntime('main = str.reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('str.bytes', () {
      final Runtime runtime = getRuntime('main = str.bytes("Hello")');
      checkResult(runtime, [72, 101, 108, 108, 111]);
    });

    test('str.indexOf returns negative one when substring not found', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "x")');
      checkResult(runtime, -1);
    });

    test('str.indexOf returns index of first occurrence', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "l")');
      checkResult(runtime, 2);
    });

    test('str.padLeft does not pad when target width is zero', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 0, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft does not pad when string already meets width', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 5, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft pads string to target width on the left', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 8, "0")');
      checkResult(runtime, '"00012345"');
    });

    test('str.padRight does not pad when target width is zero', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight does not pad when string already meets width', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight pads string to target width on the right', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 8, "0")',
      );
      checkResult(runtime, '"12345000"');
    });

    test('str.split returns single-element list when delimiter not found', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", "x")');
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test(
      'str.split splits into individual characters with empty delimiter',
      () {
        final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", "")');
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
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", ",")');
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str.compare returns negative one when first string is lesser', () {
      final Runtime runtime = getRuntime(
        'main = str.compare("hello", "mountain")',
      );
      checkResult(runtime, -1);
    });

    test('str.compare returns zero for equal strings', () {
      final Runtime runtime = getRuntime(
        'main = str.compare("table", "table")',
      );
      checkResult(runtime, 0);
    });

    test('str.compare returns one when first string is greater', () {
      final Runtime runtime = getRuntime('main = str.compare("monkey", "cat")');
      checkResult(runtime, 1);
    });
  });

  group('String Edge Cases', () {
    test('str.reverse empty', () {
      final Runtime runtime = getRuntime('main = str.reverse("")');
      checkResult(runtime, '""');
    });

    test('str.bytes empty', () {
      final Runtime runtime = getRuntime('main = str.bytes("")');
      checkResult(runtime, []);
    });

    test('str.split empty string', () {
      final Runtime runtime = getRuntime('main = str.split("", ",")');
      checkResult(runtime, ['""']);
    });

    test('str.join single element', () {
      final Runtime runtime = getRuntime(
        'main = list.join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.match negative', () {
      final Runtime runtime = getRuntime(
        'main = str.match("hello123", "^[0-9]+\$")',
      );
      checkResult(runtime, false);
    });

    test('str.contains empty pattern', () {
      final Runtime runtime = getRuntime('main = str.contains("Hello", "")');
      checkResult(runtime, true);
    });

    test('str.replace empty pattern', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("abc", "", "x")',
      );
      checkResult(runtime, '"xaxbxcx"');
    });

    test('str.indexOf empty pattern', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "")');
      checkResult(runtime, 0);
    });

    test('str.take beyond length throws', () {
      final Runtime runtime = getRuntime('main = str.take("Hi", 10)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.drop beyond length throws', () {
      final Runtime runtime = getRuntime('main = str.drop("Hi", 10)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });
  });

  group('String Type Errors', () {
    test('str.length throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.length(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.uppercase throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.uppercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.lowercase throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.lowercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.contains throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.contains(42, "x")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.split throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.split(42, ",")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.replace throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.replace(42, "a", "b")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.reverse throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.reverse(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.trim throws for wrong type', () {
      final Runtime runtime = getRuntime('main = str.trim(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('String Error Cases', () {
    test('str.at throws RangeError for out-of-bounds index', () {
      final Runtime runtime = getRuntime('main = str.at("Hello", 10)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.at throws RangeError for negative index', () {
      final Runtime runtime = getRuntime('main = str.at("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test(
      'str.substring throws InvalidArgumentTypesError for number instead of string',
      () {
        final Runtime runtime = getRuntime('main = str.substring(123, 0, 2)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str.length throws InvalidArgumentTypesError for number argument', () {
      final Runtime runtime = getRuntime('main = str.length(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'str.indexOf throws InvalidArgumentTypesError for number first argument',
      () {
        final Runtime runtime = getRuntime('main = str.indexOf(42, "x")');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'str.indexOf throws InvalidArgumentTypesError for number second argument',
      () {
        final Runtime runtime = getRuntime('main = str.indexOf("Hello", 42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });
}
