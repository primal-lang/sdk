@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Map', () {
    test('Map constructor creates empty map', () {
      final RuntimeFacade runtime = getRuntime('main = {}');
      checkResult(runtime, {});
    });

    test('Map constructor creates single-entry map', () {
      final RuntimeFacade runtime = getRuntime('main = {"foo": 1}');
      checkResult(runtime, {'"foo"': 1});
    });

    test('Map constructor creates nested map', () {
      final RuntimeFacade runtime = getRuntime('main = {"foo": {"bar": 2}}');
      checkResult(runtime, {
        '"foo"': {'"bar"': 2},
      });
    });

    test('Map constructor reduces value expressions', () {
      final RuntimeFacade runtime = getRuntime('main = {"foo": 1 + 2}');
      checkResult(runtime, {'"foo"': 3});
    });

    test('Map constructor creates map with mixed value types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"name": "John", "age": 42, "married": true}',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
      });
    });

    test('Map indexing returns value for existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"name": "John", "age": 42, "married": true}["age"]',
      );
      checkResult(runtime, 42);
    });

    test('Map indexing returns list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"]',
      );
      checkResult(runtime, [42, 99, 201]);
    });

    test('Map indexing chains with list indexing', () {
      final RuntimeFacade runtime = getRuntime(
        'main = ({"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"])[1]',
      );
      checkResult(runtime, 99);
    });

    test('Map indexing works inside function with map argument', () {
      final RuntimeFacade runtime = getRuntime('''
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

    test('map.at returns value for existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"name": "John", "age": 42, "married": true}, "age")',
      );
      checkResult(runtime, 42);
    });

    test('map.at returns reduced expression value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"name": "John", "age": 42 + 1, "married": true}, "age")',
      );
      checkResult(runtime, 43);
    });

    test('map.set adds entry to empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.set({}, "foo", 1)');
      checkResult(runtime, {'"foo"': 1});
    });

    test('map.set overwrites existing key value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({"name": "John", "age": 42, "married": true}, "age", 30)',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 30,
        '"married"': true,
      });
    });

    test('map.keys returns empty list for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys({})');
      checkResult(runtime, []);
    });

    test('map.keys returns all keys including mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.keys({"name": "John", "age": 42, "married": true, 3: 2})',
      );
      checkResult(runtime, ['"name"', '"age"', '"married"', 3]);
    });

    test('map.values returns empty list for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.values({})');
      checkResult(runtime, []);
    });

    test('map.values returns all values including mixed types', () {
      final RuntimeFacade runtime = getRuntime(
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

    test('map.containsKey returns false for empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({}, "name")',
      );
      checkResult(runtime, false);
    });

    test('map.containsKey returns true for existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({"name": "John"}, "name")',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey matches key built from expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({("na" + "me"): "John"}, "name")',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey returns false for missing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({"name": "John"}, "age")',
      );
      checkResult(runtime, false);
    });

    test('map.isEmpty returns true for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.isEmpty({})');
      checkResult(runtime, true);
    });

    test('map.isEmpty returns false for non-empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isEmpty({"name": "John"})',
      );
      checkResult(runtime, false);
    });

    test('map.isNotEmpty returns false for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.isNotEmpty({})');
      checkResult(runtime, false);
    });

    test('map.isNotEmpty returns true for non-empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isNotEmpty({"name": "John"})',
      );
      checkResult(runtime, true);
    });

    test('map.removeAt removes existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({"name": "John", "age": 42, "married": true}, "age")',
      );
      checkResult(runtime, {'"name"': '"John"', '"married"': true});
    });

    test('map.removeAt returns unchanged map for missing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({"name": "John", "age": 42, "married": true}, "foo")',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
      });
    });

    test('map.length returns zero for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.length({})');
      checkResult(runtime, 0);
    });

    test('map.length returns entry count for non-empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.length({"name": "John", "age": 42, "married": true})',
      );
      checkResult(runtime, 3);
    });
  });

  group('Map Missing Key', () {
    test('map.at missing key throws', () {
      final RuntimeFacade runtime = getRuntime('main = map.at({"a": 1}, "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('map indexing missing key throws', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1}["b"]');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.set adds new key to non-empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({"a": 1}, "b", 2)',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2});
    });
  });

  group('Map Type Errors', () {
    test('map.length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = map.length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.keys throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.values throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = map.values("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.isEmpty throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = map.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.containsKey throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey("hello", "a")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('map.at throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = map.at("hello", "a")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('Map Error Cases', () {
    test('map.at throws InvalidMapIndexError for non-existent key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"name": "John", "age": 42}, "missing")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidMapIndexError>()),
      );
    });

    test(
      'map.containsKey throws InvalidArgumentTypesError for non-map first argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = map.containsKey([1, 2], "a")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'map.set throws InvalidArgumentTypesError for non-map first argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = map.set([1, 2], "a", 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'map.removeAt throws InvalidArgumentTypesError for non-map first argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = map.removeAt([1, 2], "a")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('map.isNotEmpty throws InvalidArgumentTypesError for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map indexing throws ElementNotFoundError for missing key', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1}["missing"]');
      expect(runtime.executeMain, throwsA(isA<ElementNotFoundError>()));
    });
  });

  group('Map with Non-String Keys', () {
    test('Map constructor creates map with numeric key', () {
      final RuntimeFacade runtime = getRuntime('main = {1: "one", 2: "two"}');
      checkResult(runtime, {1: '"one"', 2: '"two"'});
    });

    test('Map constructor creates map with boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {true: "yes", false: "no"}',
      );
      checkResult(runtime, {true: '"yes"', false: '"no"'});
    });

    test('Map constructor creates map with expression-computed key', () {
      final RuntimeFacade runtime = getRuntime('main = {(1 + 2): "three"}');
      checkResult(runtime, {3: '"three"'});
    });

    test('Map indexing with numeric key returns value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {1: "one", 2: "two"}[2]',
      );
      checkResult(runtime, '"two"');
    });

    test('Map indexing with boolean key returns value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {true: "yes", false: "no"}[true]',
      );
      checkResult(runtime, '"yes"');
    });

    test('map.at returns value for numeric key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({1: "one", 2: "two"}, 2)',
      );
      checkResult(runtime, '"two"');
    });

    test('map.at returns value for boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({true: "yes", false: "no"}, false)',
      );
      checkResult(runtime, '"no"');
    });

    test('map.containsKey returns true for numeric key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({1: "one"}, 1)',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey returns false for missing numeric key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({1: "one"}, 2)',
      );
      checkResult(runtime, false);
    });

    test('map.set adds entry with numeric key', () {
      final RuntimeFacade runtime = getRuntime('main = map.set({}, 1, "one")');
      checkResult(runtime, {1: '"one"'});
    });

    test('map.set overwrites value for existing numeric key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({1: "one"}, 1, "ONE")',
      );
      checkResult(runtime, {1: '"ONE"'});
    });

    test('map.removeAt removes entry with numeric key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({1: "one", 2: "two"}, 1)',
      );
      checkResult(runtime, {2: '"two"'});
    });
  });

  group('Map Edge Cases', () {
    test('map.removeAt on empty map returns empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({}, "key")',
      );
      checkResult(runtime, {});
    });

    test('map.set with map value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({}, "nested", {"inner": 42})',
      );
      checkResult(runtime, {
        '"nested"': {'"inner"': 42},
      });
    });

    test('map.set with list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({}, "numbers", [1, 2, 3])',
      );
      checkResult(runtime, {
        '"numbers"': [1, 2, 3],
      });
    });

    test('map.keys preserves insertion order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.keys({"z": 1, "a": 2, "m": 3})',
      );
      checkResult(runtime, ['"z"', '"a"', '"m"']);
    });

    test('map.values preserves insertion order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.values({"first": 1, "second": 2, "third": 3})',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('map.length returns 1 for single-entry map', () {
      final RuntimeFacade runtime = getRuntime('main = map.length({"a": 1})');
      checkResult(runtime, 1);
    });

    test('nested map access via indexing', () {
      final RuntimeFacade runtime = getRuntime(
        'main = ({"outer": {"inner": 42}}["outer"])["inner"]',
      );
      checkResult(runtime, 42);
    });

    test('nested map access via map.at', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at(map.at({"outer": {"inner": 42}}, "outer"), "inner")',
      );
      checkResult(runtime, 42);
    });

    test('map.set preserves other entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({"a": 1, "b": 2, "c": 3}, "b", 20)',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 20, '"c"': 3});
    });

    test('map.removeAt preserves other entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({"a": 1, "b": 2, "c": 3}, "b")',
      );
      checkResult(runtime, {'"a"': 1, '"c"': 3});
    });
  });
}
