@Tags(['runtime', 'io'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Json', () {
    test('json.decode decodes empty list', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("[]")');
      checkResult(runtime, []);
    });

    test('json.decode decodes list of numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[1, 2, 3]")',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('json.decode decodes list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('[1, \"Hello\", true]')",
      );
      checkResult(runtime, [1, '"Hello"', true]);
    });

    test('json.decode decodes object with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('{\"name\": \"John\", \"age\": 42, \"married\": true, \"numbers\": [1, 2, 3]}')",
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
        '"numbers"': [1, 2, 3],
      });
    });

    test('json.encode encodes empty list', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode([])');
      checkResult(runtime, '"[]"');
    });

    test('json.encode encodes list of numbers', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode([1, 2, 3])');
      checkResult(runtime, '"[1,2,3]"');
    });

    test('json.encode encodes list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode([1, "Hello", true])',
      );
      checkResult(runtime, '"[1,"Hello",true]"');
    });

    test('json.encode encodes nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode([1, 2, [3, 4]])',
      );
      checkResult(runtime, '"[1,2,[3,4]]"');
    });

    test('json.encode encodes empty map', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode({})');
      checkResult(runtime, '"{}"');
    });

    test('json.encode encodes map with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode({"name": "John", "age": 42, "married": true, "numbers": [1, 2, 3]})',
      );
      checkResult(
        runtime,
        '"{"name":"John","age":42,"married":true,"numbers":[1,2,3]}"',
      );
    });
  });

  group('JSON Edge Cases', () {
    test('json.decode throws JsonParseError for invalid JSON string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("not json")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Invalid JSON'),
              contains('not json'),
            ),
          ),
        ),
      );
    });

    test('json.decode empty object', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("{}")');
      checkResult(runtime, {});
    });

    test('json.decode nested', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('{\"a\": {\"b\": 1}}')",
      );
      checkResult(runtime, {
        '"a"': {'"b"': 1},
      });
    });

    test('json.encode then decode roundtrip', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(json.encode([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('JSON Type Errors', () {
    test('json.encode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.decode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Error Cases', () {
    test('json.decode throws JsonParseError for malformed object', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("{invalid}")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws JsonParseError for incomplete array', () {
      final RuntimeFacade runtime = getRuntime(r'main = json.decode("[1, 2,")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test(
      'json.decode throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = json.decode(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('json.decode with null value throws InvalidValueError', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("null")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidValueError>()),
      );
    });
  });
}
