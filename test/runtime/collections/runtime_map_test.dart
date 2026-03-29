import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Map', () {
    test('Map constructor 1', () {
      final Runtime runtime = getRuntime('main = {}');
      checkResult(runtime, {});
    });

    test('Map constructor 2', () {
      final Runtime runtime = getRuntime('main = {"foo": 1}');
      checkResult(runtime, {'"foo"': 1});
    });

    test('Map constructor 3', () {
      final Runtime runtime = getRuntime('main = {"foo": {"bar": 2}}');
      checkResult(runtime, {
        '"foo"': {'"bar"': 2},
      });
    });

    test('Map constructor 4', () {
      final Runtime runtime = getRuntime('main = {"foo": 1 + 2}');
      checkResult(runtime, {'"foo"': 3});
    });

    test('Map constructor 5', () {
      final Runtime runtime = getRuntime(
        'main = {"name": "John", "age": 42, "married": true}',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
      });
    });

    test('Map indexing 1', () {
      final Runtime runtime = getRuntime(
        'main = {"name": "John", "age": 42, "married": true}["age"]',
      );
      checkResult(runtime, 42);
    });

    test('Map indexing 2', () {
      final Runtime runtime = getRuntime(
        'main = {"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"]',
      );
      checkResult(runtime, [42, 99, 201]);
    });

    test('Map indexing 3', () {
      final Runtime runtime = getRuntime(
        'main = ({"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"])[1]',
      );
      checkResult(runtime, 99);
    });

    test('Map indexing 4', () {
      final Runtime runtime = getRuntime('''
foo(values) = {
  "name": values["name"],
  "age": values["age"],
  "married": values["married"]
}

main = foo({"name": "John", "age": 42, "married": true})
''');
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
      });
    });

    test('map.at 1', () {
      final Runtime runtime = getRuntime(
        'main = map.at({"name": "John", "age": 42, "married": true}, "age")',
      );
      checkResult(runtime, 42);
    });

    test('map.at 2', () {
      final Runtime runtime = getRuntime(
        'main = map.at({"name": "John", "age": 42 + 1, "married": true}, "age")',
      );
      checkResult(runtime, 43);
    });

    test('map.set 1', () {
      final Runtime runtime = getRuntime('main = map.set({}, "foo", 1)');
      checkResult(runtime, {'"foo"': 1});
    });

    test('map.set 2', () {
      final Runtime runtime = getRuntime(
        'main = map.set({"name": "John", "age": 42, "married": true}, "age", 30)',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 30,
        '"married"': true,
      });
    });

    test('map.keys 1', () {
      final Runtime runtime = getRuntime('main = map.keys({})');
      checkResult(runtime, []);
    });

    test('map.keys 2', () {
      final Runtime runtime = getRuntime(
        'main = map.keys({"name": "John", "age": 42, "married": true, 3: 2})',
      );
      checkResult(runtime, ['"name"', '"age"', '"married"', 3]);
    });

    test('map.values 1', () {
      final Runtime runtime = getRuntime('main = map.values({})');
      checkResult(runtime, []);
    });

    test('map.values 2', () {
      final Runtime runtime = getRuntime(
        'main = map.values({"name": "John", "age": 42, "married": true, 3: 2, "foo": [1, 2, 3]})',
      );
      checkResult(runtime, [
        '"John"',
        42,
        true,
        2,
        [1, 2, 3],
      ]);
    });

    test('map.contains 1', () {
      final Runtime runtime = getRuntime('main = map.containsKey({}, "name")');
      checkResult(runtime, false);
    });

    test('map.contains 2', () {
      final Runtime runtime = getRuntime(
        'main = map.containsKey({"name": "John"}, "name")',
      );
      checkResult(runtime, true);
    });

    test('map.contains 3', () {
      final Runtime runtime = getRuntime(
        'main = map.containsKey({("na" + "me"): "John"}, "name")',
      );
      checkResult(runtime, true);
    });

    test('map.contains 4', () {
      final Runtime runtime = getRuntime(
        'main = map.containsKey({"name": "John"}, "age")',
      );
      checkResult(runtime, false);
    });

    test('map.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = map.isEmpty({})');
      checkResult(runtime, true);
    });

    test('map.isEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = map.isEmpty({"name": "John"})',
      );
      checkResult(runtime, false);
    });

    test('map.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = map.isNotEmpty({})');
      checkResult(runtime, false);
    });

    test('map.isNotEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = map.isNotEmpty({"name": "John"})',
      );
      checkResult(runtime, true);
    });

    test('map.removeAt 1', () {
      final Runtime runtime = getRuntime(
        'main = map.removeAt({"name": "John", "age": 42, "married": true}, "age")',
      );
      checkResult(runtime, {'"name"': '"John"', '"married"': true});
    });

    test('map.removeAt 2', () {
      final Runtime runtime = getRuntime(
        'main = map.removeAt({"name": "John", "age": 42, "married": true}, "foo")',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
      });
    });

    test('map.length 1', () {
      final Runtime runtime = getRuntime('main = map.length({})');
      checkResult(runtime, 0);
    });

    test('map.length 2', () {
      final Runtime runtime = getRuntime(
        'main = map.length({"name": "John", "age": 42, "married": true})',
      );
      checkResult(runtime, 3);
    });
  });

  group('Map Missing Key', () {
    test('map.at missing key throws', () {
      final Runtime runtime = getRuntime('main = map.at({"a": 1}, "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('map indexing missing key throws', () {
      final Runtime runtime = getRuntime('main = {"a": 1}["b"]');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.set adds new key to non-empty map', () {
      final Runtime runtime = getRuntime(
        'main = map.set({"a": 1}, "b", 2)',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2});
    });
  });

  group('Map Type Errors', () {
    test('map.length throws for wrong type', () {
      final Runtime runtime = getRuntime('main = map.length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.keys throws for wrong type', () {
      final Runtime runtime = getRuntime('main = map.keys("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.values throws for wrong type', () {
      final Runtime runtime = getRuntime('main = map.values("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.isEmpty throws for wrong type', () {
      final Runtime runtime = getRuntime('main = map.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.containsKey throws for wrong type', () {
      final Runtime runtime = getRuntime(
        'main = map.containsKey("hello", "a")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.at throws for wrong type', () {
      final Runtime runtime = getRuntime('main = map.at("hello", "a")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });
}
