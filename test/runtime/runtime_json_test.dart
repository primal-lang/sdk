import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('Json', () {
    test('json.decode 1', () {
      final Runtime runtime = getRuntime('main = json.decode("[]")');
      checkResult(runtime, []);
    });

    test('json.decode 2', () {
      final Runtime runtime = getRuntime('main = json.decode("[1, 2, 3]")');
      checkResult(runtime, [1, 2, 3]);
    });

    test('json.decode 3', () {
      final Runtime runtime = getRuntime(
        "main = json.decode('[1, \"Hello\", true]')",
      );
      checkResult(runtime, [1, '"Hello"', true]);
    });

    test('json.decode 4', () {
      final Runtime runtime = getRuntime(
        "main = json.decode('{\"name\": \"John\", \"age\": 42, \"married\": true, \"numbers\": [1, 2, 3]}')",
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
        '"numbers"': [1, 2, 3],
      });
    });

    test('json.encode 1', () {
      final Runtime runtime = getRuntime('main = json.encode([])');
      checkResult(runtime, '"[]"');
    });

    test('json.encode 2', () {
      final Runtime runtime = getRuntime('main = json.encode([1, 2, 3])');
      checkResult(runtime, '"[1,2,3]"');
    });

    test('json.encode 3', () {
      final Runtime runtime = getRuntime(
        'main = json.encode([1, "Hello", true])',
      );
      checkResult(runtime, '"[1,"Hello",true]"');
    });

    test('json.encode 4', () {
      final Runtime runtime = getRuntime('main = json.encode([1, 2, [3, 4]])');
      checkResult(runtime, '"[1,2,[3,4]]"');
    });

    test('json.encode 5', () {
      final Runtime runtime = getRuntime('main = json.encode({})');
      checkResult(runtime, '"{}"');
    });

    test('json.encode 6', () {
      final Runtime runtime = getRuntime(
        'main = json.encode({"name": "John", "age": 42, "married": true, "numbers": [1, 2, 3]})',
      );
      checkResult(
        runtime,
        '"{"name":"John","age":42,"married":true,"numbers":[1,2,3]}"',
      );
    });
  });

  group('JSON Edge Cases', () {
    test('json.decode invalid string throws', () {
      final Runtime runtime = getRuntime('main = json.decode("not json")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('json.decode empty object', () {
      final Runtime runtime = getRuntime('main = json.decode("{}")');
      checkResult(runtime, {});
    });

    test('json.decode nested', () {
      final Runtime runtime = getRuntime(
        "main = json.decode('{\"a\": {\"b\": 1}}')",
      );
      checkResult(runtime, {'"a"': {'"b"': 1}});
    });

    test('json.encode then decode roundtrip', () {
      final Runtime runtime = getRuntime(
        'main = json.decode(json.encode([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('JSON Type Errors', () {
    test('json.encode throws for number argument', () {
      final Runtime runtime = getRuntime('main = json.encode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.decode throws for number argument', () {
      final Runtime runtime = getRuntime('main = json.decode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
