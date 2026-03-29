import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

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

    test('str.startsWith 1', () {
      final Runtime runtime = getRuntime('main = str.startsWith("hola", "ho")');
      checkResult(runtime, true);
    });

    test('str.startsWith 2', () {
      final Runtime runtime = getRuntime(
        'main = str.startsWith("hola", "hoy")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith 1', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "la")');
      checkResult(runtime, true);
    });

    test('str.endsWith 2', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "lol")');
      checkResult(runtime, false);
    });

    test('str.replace 1', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("banana", "na", "to")',
      );
      checkResult(runtime, '"batoto"');
    });

    test('str.replace 2', () {
      final Runtime runtime = getRuntime(
        'main = str.replace("banana", "bon", "to")',
      );
      checkResult(runtime, '"banana"');
    });

    test('str.replace 3', () {
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

    test('str.rest 1', () {
      final Runtime runtime = getRuntime('main = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.rest 2', () {
      final Runtime runtime = getRuntime('main = str.rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str.at', () {
      final Runtime runtime = getRuntime('main = str.at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty 2', () {
      final Runtime runtime = getRuntime('main = str.isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str.isEmpty 3', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty 2', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str.isNotEmpty 3', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("Hello")');
      checkResult(runtime, true);
    });

    test('str.contains 1', () {
      final Runtime runtime = getRuntime('main = str.contains("Hello", "ell")');
      checkResult(runtime, true);
    });

    test('str.contains 2', () {
      final Runtime runtime = getRuntime(
        'main = str.contains("Hello", "hell")',
      );
      checkResult(runtime, false);
    });

    test('str.take 1', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.take 2', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop 1', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str.drop 2', () {
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

    test('str.indexOf 1', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "x")');
      checkResult(runtime, -1);
    });

    test('str.indexOf 2', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "l")');
      checkResult(runtime, 2);
    });

    test('str.padLeft 1', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 0, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft 2', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 5, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft 3', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 8, "0")');
      checkResult(runtime, '"00012345"');
    });

    test('str.padRight 1', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 0, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight 2', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 5, "0")',
      );
      checkResult(runtime, '"12345"');
    });

    test('str.padRight 3', () {
      final Runtime runtime = getRuntime(
        'main = str.padRight("12345", 8, "0")',
      );
      checkResult(runtime, '"12345000"');
    });

    test('str.split 1', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", "x")');
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test('str.split 2', () {
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
    });

    test('str.split 3', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", ",")');
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str.compare 1', () {
      final Runtime runtime = getRuntime(
        'main = str.compare("hello", "mountain")',
      );
      checkResult(runtime, -1);
    });

    test('str.compare 2', () {
      final Runtime runtime = getRuntime(
        'main = str.compare("table", "table")',
      );
      checkResult(runtime, 0);
    });

    test('str.compare 3', () {
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
}
