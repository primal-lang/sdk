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

    test('map.removeAt removes entry with boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({true: "yes", false: "no"}, true)',
      );
      checkResult(runtime, {false: '"no"'});
    });

    test('map.containsKey returns true for boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({true: "yes", false: "no"}, true)',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey returns false for missing boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({false: "no"}, true)',
      );
      checkResult(runtime, false);
    });

    test('map.set adds entry with boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({}, true, "yes")',
      );
      checkResult(runtime, {true: '"yes"'});
    });

    test('map.set overwrites value for existing boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({true: "yes"}, true, "YES")',
      );
      checkResult(runtime, {true: '"YES"'});
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

    test('map.removeAt removing last key returns empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({"only": 1}, "only")',
      );
      checkResult(runtime, {});
    });

    test('map.keys returns single key for single-entry map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.keys({"single": 42})',
      );
      checkResult(runtime, ['"single"']);
    });

    test('map.values returns single value for single-entry map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.values({"single": 42})',
      );
      checkResult(runtime, [42]);
    });

    test('Map indexing with expression-computed key returns value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {(1 + 2): "three"}[3]',
      );
      checkResult(runtime, '"three"');
    });

    test('Map indexing with string concatenation key returns value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {("na" + "me"): "John"}["name"]',
      );
      checkResult(runtime, '"John"');
    });

    test('multiple chained map.set operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set(map.set(map.set({}, "a", 1), "b", 2), "c", 3)',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2, '"c"': 3});
    });

    test('multiple chained map.removeAt operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt(map.removeAt({"a": 1, "b": 2, "c": 3}, "a"), "c")',
      );
      checkResult(runtime, {'"b"': 2});
    });

    test('map.isEmpty returns true after removing all entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isEmpty(map.removeAt({"a": 1}, "a"))',
      );
      checkResult(runtime, true);
    });

    test('map.isNotEmpty returns true after adding entry to empty map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isNotEmpty(map.set({}, "key", "value"))',
      );
      checkResult(runtime, true);
    });

    test('map.length after set operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.length(map.set({"a": 1}, "b", 2))',
      );
      checkResult(runtime, 2);
    });

    test('map.length after removeAt operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.length(map.removeAt({"a": 1, "b": 2}, "a"))',
      );
      checkResult(runtime, 1);
    });

    test('map.containsKey after set operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey(map.set({}, "new", 1), "new")',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey returns false after removeAt operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey(map.removeAt({"a": 1}, "a"), "a")',
      );
      checkResult(runtime, false);
    });

    test('map.at on result of map.set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at(map.set({}, "key", 42), "key")',
      );
      checkResult(runtime, 42);
    });

    test('map.keys on result of map.set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.keys(map.set({"a": 1}, "b", 2))',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('map.values on result of map.set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.values(map.set({"a": 1}, "b", 2))',
      );
      checkResult(runtime, [1, 2]);
    });
  });

  group('Map Additional Type Errors', () {
    test('map.length throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.length([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.length throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.length throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.keys throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.keys throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.keys throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.values throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.values([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.values throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.values(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.values throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.values(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isEmpty throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.isEmpty([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isEmpty throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isEmpty throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isNotEmpty throws for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.isNotEmpty([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isNotEmpty throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isNotEmpty throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.isNotEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.at throws for list as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.at([1, 2, 3], "a")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.at throws for number as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.at(42, "a")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.at throws for boolean as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.at(true, "a")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set throws for number as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.set(42, "a", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set throws for boolean as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.set(true, "a", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set throws for string as first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set("hello", "a", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt throws for number as first argument', () {
      final RuntimeFacade runtime = getRuntime('main = map.removeAt(42, "a")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt throws for boolean as first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt(true, "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt throws for string as first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt("hello", "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.at throws for function as key argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.at({"a": 1}, identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set throws for function as key argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.set({"a": 1}, identity, 2)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.containsKey throws for function as key argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.containsKey({"a": 1}, identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt throws for function as key argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.removeAt({"a": 1}, identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.length throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.length(identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.keys throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.keys(identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.values throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.values(identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isEmpty throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.isEmpty(identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isNotEmpty throws for function argument', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = map.isNotEmpty(identity)
''');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Map with Function Values', () {
    test('Map constructor stores function as value', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = {"fn": double}
''');
      // Just check it doesn't throw - function values are allowed
      expect(runtime.executeMain, returnsNormally);
    });

    test('map.set stores function as value', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = map.set({}, "fn", double)
''');
      // Just check it doesn't throw - function values are allowed
      expect(runtime.executeMain, returnsNormally);
    });

    test('map.values returns list containing function', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = list.length(map.values({"fn": double}))
''');
      checkResult(runtime, 1);
    });

    test('map.keys returns keys when map has function values', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = map.keys({"fn": double})
''');
      checkResult(runtime, ['"fn"']);
    });

    test('map.containsKey returns true for key with function value', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = map.containsKey({"fn": double}, "fn")
''');
      checkResult(runtime, true);
    });

    test('map.length returns correct count for map with function values', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main = map.length({"double": double, "triple": triple})
''');
      checkResult(runtime, 2);
    });
  });

  group('Map Deeply Nested', () {
    test('three-level nested map access via indexing', () {
      final RuntimeFacade runtime = getRuntime(
        'main = (({"a": {"b": {"c": 42}}}["a"])["b"])["c"]',
      );
      checkResult(runtime, 42);
    });

    test('three-level nested map access via map.at', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at(map.at(map.at({"a": {"b": {"c": 42}}}, "a"), "b"), "c")',
      );
      checkResult(runtime, 42);
    });

    test('nested map with list value access', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.at(map.at({"outer": {"inner": [1, 2, 3]}}, "outer")["inner"], 1)',
      );
      checkResult(runtime, 2);
    });

    test('map.set on nested map preserves outer structure', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at(map.at(map.set({"outer": {"inner": 1}}, "outer", {"inner": 2}), "outer"), "inner")',
      );
      checkResult(runtime, 2);
    });
  });

  group('Map Special Key Cases', () {
    test('map with empty string key', () {
      final RuntimeFacade runtime = getRuntime('main = {"": "empty key"}');
      checkResult(runtime, {'""': '"empty key"'});
    });

    test('map.at with empty string key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"": "empty key value"}, "")',
      );
      checkResult(runtime, '"empty key value"');
    });

    test('map.containsKey with empty string key returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({"": 1}, "")',
      );
      checkResult(runtime, true);
    });

    test('map.set with empty string key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set({}, "", "value")',
      );
      checkResult(runtime, {'""': '"value"'});
    });

    test('map.removeAt with empty string key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt({"": 1, "a": 2}, "")',
      );
      checkResult(runtime, {'"a"': 2});
    });

    test('map with zero as key', () {
      final RuntimeFacade runtime = getRuntime('main = {0: "zero"}');
      checkResult(runtime, {0: '"zero"'});
    });

    test('map.at with zero key', () {
      final RuntimeFacade runtime = getRuntime('main = map.at({0: "zero"}, 0)');
      checkResult(runtime, '"zero"');
    });

    test('map.containsKey with zero key returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({0: "zero"}, 0)',
      );
      checkResult(runtime, true);
    });

    test('map with negative number key', () {
      final RuntimeFacade runtime = getRuntime('main = {-1: "negative"}');
      checkResult(runtime, {-1: '"negative"'});
    });

    test('map.at with negative number key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({-1: "negative"}, -1)',
      );
      checkResult(runtime, '"negative"');
    });

    test('map with decimal number key', () {
      final RuntimeFacade runtime = getRuntime('main = {3.14: "pi"}');
      checkResult(runtime, {3.14: '"pi"'});
    });

    test('map.at with decimal number key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({3.14: "pi"}, 3.14)',
      );
      checkResult(runtime, '"pi"');
    });
  });

  group('Map Composition Operations', () {
    test('map.keys followed by list.length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.length(map.keys({"a": 1, "b": 2, "c": 3}))',
      );
      checkResult(runtime, 3);
    });

    test('map.values followed by list.reduce', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.reduce(map.values({"a": 1, "b": 2, "c": 3}), 0, add)
''');
      checkResult(runtime, 6);
    });

    test('map.keys followed by list.filter', () {
      final RuntimeFacade runtime = getRuntime('''
startsWithA(s) = str.startsWith(s, "a")
main = list.filter(map.keys({"apple": 1, "banana": 2, "avocado": 3}), startsWithA)
''');
      checkResult(runtime, ['"apple"', '"avocado"']);
    });

    test('map built from two list.map operations', () {
      final RuntimeFacade runtime = getRuntime('''
makeEntry(x) = {x: x * x}
main = makeEntry(3)
''');
      checkResult(runtime, {3: 9});
    });

    test('map.containsKey with computed key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey({"ab": 1}, "a" + "b")',
      );
      checkResult(runtime, true);
    });

    test('map.at with computed key from function', () {
      final RuntimeFacade runtime = getRuntime('''
getKey(x) = x + "ey"
main = map.at({"key": 42}, getKey("k"))
''');
      checkResult(runtime, 42);
    });
  });

  group('Map Variable Binding', () {
    test('map passed as function argument', () {
      final RuntimeFacade runtime = getRuntime('''
getValue(m, k) = map.at(m, k)
main = getValue({"x": 10, "y": 20}, "y")
''');
      checkResult(runtime, 20);
    });

    test('map returned from function', () {
      final RuntimeFacade runtime = getRuntime('''
makeMap(k, v) = {k: v}
main = map.at(makeMap("test", 99), "test")
''');
      checkResult(runtime, 99);
    });

    test('map modified through multiple function calls', () {
      final RuntimeFacade runtime = getRuntime('''
addEntry(m, k, v) = map.set(m, k, v)
main = map.length(addEntry(addEntry(addEntry({}, "a", 1), "b", 2), "c", 3))
''');
      checkResult(runtime, 3);
    });

    test('map used in conditional expression', () {
      final RuntimeFacade runtime = getRuntime('''
getOrDefault(m, k, d) = if (map.containsKey(m, k)) (map.at(m, k)) else d
main = getOrDefault({"a": 1}, "b", 42)
''');
      checkResult(runtime, 42);
    });

    test('map used in conditional expression when key exists', () {
      final RuntimeFacade runtime = getRuntime('''
getOrDefault(m, k, d) = if (map.containsKey(m, k)) (map.at(m, k)) else d
main = getOrDefault({"a": 1}, "a", 42)
''');
      checkResult(runtime, 1);
    });
  });

  group('Map Large Operations', () {
    test('map with many entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.length({"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8, "i": 9, "j": 10})',
      );
      checkResult(runtime, 10);
    });

    test('map.keys returns all keys for large map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.length(map.keys({"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8, "i": 9, "j": 10}))',
      );
      checkResult(runtime, 10);
    });

    test('map.values returns all values for large map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.length(map.values({"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8, "i": 9, "j": 10}))',
      );
      checkResult(runtime, 10);
    });

    test('chained map.set builds large map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.length(map.set(map.set(map.set(map.set(map.set({}, "a", 1), "b", 2), "c", 3), "d", 4), "e", 5))',
      );
      checkResult(runtime, 5);
    });
  });
}
