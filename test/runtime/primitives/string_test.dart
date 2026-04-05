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
      final RuntimeFacade runtime = getRuntime('main = "Hello"[1]');
      checkResult(runtime, '"e"');
    });

    test('str.substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("hola", 1, 3)',
      );
      checkResult(runtime, '"ol"');
    });

    test('str.startsWith returns true for matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.startsWith("hola", "ho")',
      );
      checkResult(runtime, true);
    });

    test('str.startsWith returns false for non-matching prefix', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.startsWith("hola", "hoy")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith returns true for matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.endsWith("hola", "la")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith returns false for non-matching suffix', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.endsWith("hola", "lol")',
      );
      checkResult(runtime, false);
    });

    test('str.replace replaces all occurrences of a substring', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace("banana", "na", "to")',
      );
      checkResult(runtime, '"batoto"');
    });

    test('str.replace returns original when pattern not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace("banana", "bon", "to")',
      );
      checkResult(runtime, '"banana"');
    });

    test('str.replace replaces characters matching a regex pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace("aaa123BBB", "[a-z]", "x")',
      );
      checkResult(runtime, '"xxx123BBB"');
    });

    test('str.uppercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.uppercase("Primal")',
      );
      checkResult(runtime, '"PRIMAL"');
    });

    test('str.lowercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.lowercase("Primal")',
      );
      checkResult(runtime, '"primal"');
    });

    test('str.trim', () {
      final RuntimeFacade runtime = getRuntime('main = str.trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('str.match', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.match("identifier42", "[a-zA-Z]+[0-9]+")',
      );
      checkResult(runtime, true);
    });

    test('str.length', () {
      final RuntimeFacade runtime = getRuntime('main = str.length("primal")');
      checkResult(runtime, 6);
    });

    test('str.concat', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.concat("Hello", ", world!")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('str.first', () {
      final RuntimeFacade runtime = getRuntime('main = str.first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('str.last', () {
      final RuntimeFacade runtime = getRuntime('main = str.last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('str.init', () {
      final RuntimeFacade runtime = getRuntime('main = str.init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('str.rest returns empty string for empty input', () {
      final RuntimeFacade runtime = getRuntime('main = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.rest returns string without first character', () {
      final RuntimeFacade runtime = getRuntime('main = str.rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str.at', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str.isEmpty returns true for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty returns false for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = str.isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str.isEmpty returns false for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty returns true for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = str.isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str.isNotEmpty returns true for non-empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.isNotEmpty("Hello")',
      );
      checkResult(runtime, true);
    });

    test('str.contains returns true when substring is present', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.contains("Hello", "ell")',
      );
      checkResult(runtime, true);
    });

    test('str.contains returns false for case-sensitive mismatch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.contains("Hello", "hell")',
      );
      checkResult(runtime, false);
    });

    test('str.take returns empty string when taking zero characters', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.take returns first n characters', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop returns full string when dropping zero characters', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str.drop returns string after dropping first n characters', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str.removeAt', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.removeAt("Hello", 4)',
      );
      checkResult(runtime, '"Hell"');
    });

    test('str.reverse', () {
      final RuntimeFacade runtime = getRuntime('main = str.reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('str.bytes', () {
      final RuntimeFacade runtime = getRuntime('main = str.bytes("Hello")');
      checkResult(runtime, [72, 101, 108, 108, 111]);
    });

    test('str.indexOf returns negative one when substring not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.indexOf("Hello", "x")',
      );
      checkResult(runtime, -1);
    });

    test('str.indexOf returns index of first occurrence', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.indexOf("Hello", "l")',
      );
      checkResult(runtime, 2);
    });

    test('str.padLeft does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padLeft("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padLeft("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft pads string to target width on the left', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padLeft("12345", 8, "0")',
      );
      checkResult(runtime, '"00012345"');
    });

    test('str.padRight does not pad when target width is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padRight("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight does not pad when string already meets width', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padRight("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight pads string to target width on the right', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padRight("12345", 8, "0")',
      );
      checkResult(runtime, '"12345000"');
    });

    test('str.split returns single-element list when delimiter not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.split("aa,bb,cc", "x")',
      );
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test(
      'str.split splits into individual characters with empty delimiter',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = str.split("aa,bb,cc", "")',
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
        'main = str.split("aa,bb,cc", ",")',
      );
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str.compare returns negative one when first string is lesser', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.compare("hello", "mountain")',
      );
      checkResult(runtime, -1);
    });

    test('str.compare returns zero for equal strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.compare("table", "table")',
      );
      checkResult(runtime, 0);
    });

    test('str.compare returns one when first string is greater', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.compare("monkey", "cat")',
      );
      checkResult(runtime, 1);
    });

    test('str.length counts graphemes', () {
      final RuntimeFacade runtime = getRuntime('main = str.length("👨‍👩‍👧")');
      checkResult(runtime, 1);
    });

    test('str.at with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.at("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.first with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.first("👨‍👩‍👧abc")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.last with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.last("abc👨‍👩‍👧")',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.reverse preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.reverse("a👨‍👩‍👧b")',
      );
      checkResult(runtime, '"b👨‍👩‍👧a"');
    });

    test('str.take with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.take("a👨‍👩‍👧b", 2)',
      );
      checkResult(runtime, '"a👨‍👩‍👧"');
    });

    test('str.drop with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.drop("a👨‍👩‍👧b", 1)',
      );
      checkResult(runtime, '"👨‍👩‍👧b"');
    });

    test('str.substring with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("a👨‍👩‍👧b", 1, 2)',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('str.indexOf with grapheme', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.indexOf("a👨‍👩‍👧b", "b")',
      );
      checkResult(runtime, 2);
    });

    test('str.split with empty delimiter preserves graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.split("a👨‍👩‍👧b", "")',
      );
      checkResult(runtime, ['"a"', '"👨‍👩‍👧"', '"b"']);
    });
  });

  group('String Edge Cases', () {
    test('str.reverse empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.reverse("")');
      checkResult(runtime, '""');
    });

    test('str.bytes empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.bytes("")');
      checkResult(runtime, []);
    });

    test('str.split empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.split("", ",")');
      checkResult(runtime, ['""']);
    });

    test('str.join single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.match negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.match("hello123", "^[0-9]+\$")',
      );
      checkResult(runtime, false);
    });

    test('str.match throws ParseError for invalid regex', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.match("hello", "[invalid")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('str.contains empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.contains("Hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.replace empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace("abc", "", "x")',
      );
      checkResult(runtime, '"xaxbxcx"');
    });

    test('str.indexOf empty pattern', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.indexOf("Hello", "")',
      );
      checkResult(runtime, 0);
    });

    test('str.take clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("Hi", 10)');
      checkResult(runtime, '"Hi"');
    });

    test('str.drop clamps to length when count exceeds length', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("Hi", 10)');
      checkResult(runtime, '""');
    });
  });

  group('String Type Errors', () {
    test('str.length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.length(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.uppercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.uppercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.lowercase throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.lowercase(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.contains throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.contains(42, "x")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.split throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.split(42, ",")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.replace throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace(42, "a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.reverse throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.reverse(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('str.trim throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = str.trim(42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Unicode Escape Sequences', () {
    test('\\xXX escape produces correct character', () {
      final RuntimeFacade runtime = getRuntime('main = "\\x48\\x69"');
      checkResult(runtime, '"Hi"');
    });

    test('\\xXX escape for special characters', () {
      final RuntimeFacade runtime = getRuntime('main = "Say \\x22hello\\x22"');
      checkResult(runtime, '"Say "hello""');
    });

    test('\\uXXXX escape produces correct character', () {
      final RuntimeFacade runtime = getRuntime(
        'main = "\\u0048\\u0065\\u006C\\u006C\\u006F"',
      );
      checkResult(runtime, '"Hello"');
    });

    test('\\uXXXX escape for Greek letter', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u03B1"');
      checkResult(runtime, '"α"');
    });

    test('\\u{...} escape short form', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u{48}ello"');
      checkResult(runtime, '"Hello"');
    });

    test('\\u{...} escape for emoji', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u{1F600}"');
      checkResult(runtime, '"😀"');
    });

    test('\\u{...} escape for max code point', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u{10FFFF}"');
      checkResult(runtime, '"\u{10FFFF}"');
    });

    test('Mixed unicode escapes in one string', () {
      final RuntimeFacade runtime = getRuntime('main = "\\x41\\u0042\\u{43}"');
      checkResult(runtime, '"ABC"');
    });

    test('Unicode escapes in single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main = '\\u{1F600}'");
      checkResult(runtime, '"😀"');
    });

    test('Unicode escape with str.length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.length("\\u{1F600}")',
      );
      checkResult(runtime, 1);
    });

    test('Unicode escape with str.first', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.first("\\u{1F600}abc")',
      );
      checkResult(runtime, '"😀"');
    });

    test('Unicode escape with str.reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.reverse("a\\u{1F600}b")',
      );
      checkResult(runtime, '"b😀a"');
    });

    test('Unicode escape with string comparison', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u{41}" == "A"');
      checkResult(runtime, true);
    });

    test('Unicode escape with string concatenation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.concat("\\u{48}", "\\u{69}")',
      );
      checkResult(runtime, '"Hi"');
    });

    test('Unicode escape in list', () {
      final RuntimeFacade runtime = getRuntime('main = ["\\u{41}", "\\u{42}"]');
      checkResult(runtime, ['"A"', '"B"']);
    });

    test('Unicode escape in map key', () {
      final RuntimeFacade runtime = getRuntime('main = {"\\u{6B}": 1}["k"]');
      checkResult(runtime, 1);
    });

    test('Unicode escape in map value', () {
      final RuntimeFacade runtime = getRuntime('main = {"k": "\\u{76}"}["k"]');
      checkResult(runtime, '"v"');
    });

    test('Combining unicode escapes with regular escapes', () {
      final RuntimeFacade runtime = getRuntime('main = "\\n\\u{41}\\t"');
      checkResult(runtime, '"\nA\t"');
    });
  });

  group('String Error Cases', () {
    test('str.at throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("Hello", 10)');
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
      final RuntimeFacade runtime = getRuntime('main = str.at("Hello", -1)');
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
          'main = str.substring(123, 0, 2)',
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
          'main = str.substring("ab", 5, 10)',
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
      final RuntimeFacade runtime = getRuntime('main = str.length(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'str.indexOf throws InvalidArgumentTypesError for number first argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = str.indexOf(42, "x")');
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
          'main = str.indexOf("Hello", 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str.first throws EmptyCollectionError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.first("")');
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
      final RuntimeFacade runtime = getRuntime('main = str.last("")');
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
  });
}
