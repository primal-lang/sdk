import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('List', () {
    test('List constructor 1', () {
      final Runtime runtime = getRuntime('main = []');
      checkResult(runtime, []);
    });

    test('List constructor 2', () {
      final Runtime runtime = getRuntime('main = [1]');
      checkResult(runtime, [1]);
    });

    test('List constructor 3', () {
      final Runtime runtime = getRuntime('main = [[1]]');
      checkResult(runtime, [
        [1],
      ]);
    });

    test('List constructor 4', () {
      final Runtime runtime = getRuntime('main = [1 + 2]');
      checkResult(runtime, [3]);
    });

    test('List constructor 5', () {
      final Runtime runtime = getRuntime('main = [[1 + 2]]');
      checkResult(runtime, [
        [3],
      ]);
    });

    test('List constructor 6', () {
      final Runtime runtime = getRuntime('main = [1, true, "hello"]');
      checkResult(runtime, [1, true, '"hello"']);
    });

    test('List indexing 1', () {
      final Runtime runtime = getRuntime('main = [1, true, "hello"][1]');
      checkResult(runtime, true);
    });

    test('List indexing 2', () {
      final Runtime runtime = getRuntime(
        'main = [[1, 2, 3], [4, 5, 6], [7, 8, 9]][1]',
      );
      checkResult(runtime, [4, 5, 6]);
    });

    test('List indexing 3', () {
      final Runtime runtime = getRuntime(
        'main = ([[1, 2, 3], [4, 5, 6], [7, 8, 9]][1])[0]',
      );
      checkResult(runtime, 4);
    });

    test('List indexing 4', () {
      final Runtime runtime = getRuntime('''
foo(values) = [values[0]]

main = foo([2])
''');
      checkResult(runtime, [2]);
    });

    test('List concatenation 1', () {
      final Runtime runtime = getRuntime('main = [1, 2] + [3, 4]');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('List concatenation 2', () {
      final Runtime runtime = getRuntime('main = 1 + [2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('List concatenation 3', () {
      final Runtime runtime = getRuntime('main = [1, 2] + 3');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.insertStart 1', () {
      final Runtime runtime = getRuntime('main = list.insertStart([], 42)');
      checkResult(runtime, [42]);
    });

    test('list.insertStart 2', () {
      final Runtime runtime = getRuntime('main = list.insertStart([true], 1)');
      checkResult(runtime, [1, true]);
    });

    test('list.insertEnd 1', () {
      final Runtime runtime = getRuntime('main = list.insertEnd([], 42)');
      checkResult(runtime, [42]);
    });

    test('list.insertEnd 2', () {
      final Runtime runtime = getRuntime('main = list.insertEnd([true], 1)');
      checkResult(runtime, [true, 1]);
    });

    test('list.at 1', () {
      final Runtime runtime = getRuntime('main = list.at([0, 1, 2], 1)');
      checkResult(runtime, 1);
    });

    test('list.at 2', () {
      final Runtime runtime = getRuntime('main = list.at([0, 2 + 3, 4], 1)');
      checkResult(runtime, 5);
    });

    test('list.set 1', () {
      final Runtime runtime = getRuntime('main = list.set([], 0, 1)');
      checkResult(runtime, [1]);
    });

    test('list.set 2', () {
      final Runtime runtime = getRuntime(
        'main = list.set([1, 2, 3, 4, 5], 2, 42)',
      );
      checkResult(runtime, [1, 2, 42, 3, 4, 5]);
    });

    test('list.join 1', () {
      final Runtime runtime = getRuntime(
        'main = list.join(["Hello", "world!"], ", ")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('list.join 2', () {
      final Runtime runtime = getRuntime('main = list.join([], ",")');
      checkResult(runtime, '""');
    });

    test('list.length 1', () {
      final Runtime runtime = getRuntime('main = list.length([])');
      checkResult(runtime, 0);
    });

    test('list.length 2', () {
      final Runtime runtime = getRuntime('main = list.length([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.concat 1', () {
      final Runtime runtime = getRuntime('main = list.concat([], [])');
      checkResult(runtime, []);
    });

    test('list.concat 2', () {
      final Runtime runtime = getRuntime('main = list.concat([1, 2], [])');
      checkResult(runtime, [1, 2]);
    });

    test('list.concat 3', () {
      final Runtime runtime = getRuntime('main = list.concat([], [1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('list.concat 4', () {
      final Runtime runtime = getRuntime('main = list.concat([1, 2], [3, 4])');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = list.isEmpty([])');
      checkResult(runtime, true);
    });

    test('list.isEmpty 2', () {
      final Runtime runtime = getRuntime('main = list.isEmpty([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = list.isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty 2', () {
      final Runtime runtime = getRuntime('main = list.isNotEmpty([1, 2, 3])');
      checkResult(runtime, true);
    });

    test('list.contains 1', () {
      final Runtime runtime = getRuntime('main = list.contains([], 1)');
      checkResult(runtime, false);
    });

    test('list.contains 2', () {
      final Runtime runtime = getRuntime('main = list.contains([1, 2, 3], 1)');
      checkResult(runtime, true);
    });

    test('list.contains 3', () {
      final Runtime runtime = getRuntime(
        'main = list.contains([1, 2 + 2, 3], 4)',
      );
      checkResult(runtime, true);
    });

    test('list.contains 4', () {
      final Runtime runtime = getRuntime('main = list.contains([1, 2, 3], 4)');
      checkResult(runtime, false);
    });

    test('list.first', () {
      final Runtime runtime = getRuntime('main = list.first([1, 2, 3])');
      checkResult(runtime, 1);
    });

    test('list.last', () {
      final Runtime runtime = getRuntime('main = list.last([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.init', () {
      final Runtime runtime = getRuntime('main = list.init([1, 2, 3, 4, 5])');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.rest 1', () {
      final Runtime runtime = getRuntime('main = list.rest([])');
      checkResult(runtime, []);
    });

    test('list.rest 2', () {
      final Runtime runtime = getRuntime('main = list.rest([1, 2, 3, 4, 5])');
      checkResult(runtime, [2, 3, 4, 5]);
    });

    test('list.take 1', () {
      final Runtime runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, []);
    });

    test('list.take 2', () {
      final Runtime runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 4)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.drop 1', () {
      final Runtime runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.drop 2', () {
      final Runtime runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [3, 4, 5]);
    });

    test('list.remove 1', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.remove 2', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 3, 4, 5]);
    });

    test('list.remove 3', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 2, 4, 5], 2)',
      );
      checkResult(runtime, [1, 4, 5]);
    });

    test('list.removeAt', () {
      final Runtime runtime = getRuntime(
        'main = list.removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list.reverse', () {
      final Runtime runtime = getRuntime('main = list.reverse([1, 2, 3])');
      checkResult(runtime, [3, 2, 1]);
    });

    test('list.filled 1', () {
      final Runtime runtime = getRuntime('main = list.filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list.filled 2', () {
      final Runtime runtime = getRuntime('main = list.filled(3, 1)');
      checkResult(runtime, [1, 1, 1]);
    });

    test('list.indexOf 1', () {
      final Runtime runtime = getRuntime('main = list.indexOf([1, 2, 3], 4)');
      checkResult(runtime, -1);
    });

    test('list.indexOf 2', () {
      final Runtime runtime = getRuntime('main = list.indexOf([1, 2, 3], 2)');
      checkResult(runtime, 1);
    });

    test('list.swap', () {
      final Runtime runtime = getRuntime(
        'main = list.swap([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list.sublist', () {
      final Runtime runtime = getRuntime(
        'main = list.sublist([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.map 1 ', () {
      final Runtime runtime = getRuntime('main = list.map([], num.abs)');
      checkResult(runtime, []);
    });

    test('list.map 2', () {
      final Runtime runtime = getRuntime(
        'main = list.map([1, -2 - 6, 3 * -3, -4, num.negative(7)], num.abs)',
      );
      checkResult(runtime, [1, 8, 9, 4, 7]);
    });

    test('list.filter 1', () {
      final Runtime runtime = getRuntime('main = list.filter([], num.isEven)');
      checkResult(runtime, []);
    });

    test('list.filter 2', () {
      final Runtime runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 0, 1, 2, 3], num.isEven)',
      );
      checkResult(runtime, [-2, 0, 2]);
    });

    test('list.filter 3', () {
      final Runtime runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 1, 2, 3], num.isZero)',
      );
      checkResult(runtime, []);
    });

    test('list.reduce 1', () {
      final Runtime runtime = getRuntime('main = list.reduce([], 0, num.add)');
      checkResult(runtime, 0);
    });

    test('list.reduce 2', () {
      final Runtime runtime = getRuntime(
        'main = list.reduce([1, 2, 3, 4, 5], 10, num.add)',
      );
      checkResult(runtime, 25);
    });

    test('list.all 1', () {
      final Runtime runtime = getRuntime('main = list.all([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.all 2', () {
      final Runtime runtime = getRuntime(
        'main = list.all([2, 4, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.all 3', () {
      final Runtime runtime = getRuntime(
        'main = list.all([2, 4, 6], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.none 1', () {
      final Runtime runtime = getRuntime('main = list.none([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.none 2', () {
      final Runtime runtime = getRuntime(
        'main = list.none([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.none 3', () {
      final Runtime runtime = getRuntime(
        'main = list.none([1, 3, 7], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.any 1', () {
      final Runtime runtime = getRuntime('main = list.any([], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.any 2', () {
      final Runtime runtime = getRuntime(
        'main = list.any([1, 3, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.any 3', () {
      final Runtime runtime = getRuntime(
        'main = list.any([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.zip 1', () {
      final Runtime runtime = getRuntime('main = list.zip([], [], num.add)');
      checkResult(runtime, []);
    });

    test('list.zip 2', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4], num.add)',
      );
      checkResult(runtime, [3, 7, 5]);
    });

    test('list.zip 3', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 6]);
    });

    test('list.zip 4', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 11]);
    });

    test('list.zip 5', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1 + 1 + 1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [5, 7, 11]);
    });

    test('list.sort 1', () {
      final Runtime runtime = getRuntime('main = list.sort([], num.compare)');
      checkResult(runtime, []);
    });

    test('list.sort 2', () {
      final Runtime runtime = getRuntime(
        'main = list.sort([3, 1, 5, 2, 4], num.compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.sort 3', () {
      final Runtime runtime = getRuntime(
        'main = list.sort(["Peter", "Alice", "John", "Bob", "Daniel"], str.compare)',
      );
      checkResult(runtime, [
        '"Alice"',
        '"Bob"',
        '"Daniel"',
        '"John"',
        '"Peter"',
      ]);
    });
  });

  group('Empty Collection Operations', () {
    test('list.first empty throws', () {
      final Runtime runtime = getRuntime('main = list.first([])');
      expect(runtime.executeMain, throwsA(isA<StateError>()));
    });

    test('list.last empty throws', () {
      final Runtime runtime = getRuntime('main = list.last([])');
      expect(runtime.executeMain, throwsA(isA<StateError>()));
    });

    test('list.init empty returns empty', () {
      final Runtime runtime = getRuntime('main = list.init([])');
      checkResult(runtime, []);
    });

    test('str.first empty throws', () {
      final Runtime runtime = getRuntime('main = str.first("")');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.last empty throws', () {
      final Runtime runtime = getRuntime('main = str.last("")');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.init empty returns empty', () {
      final Runtime runtime = getRuntime('main = str.init("")');
      checkResult(runtime, '""');
    });

    test('list.at empty throws', () {
      final Runtime runtime = getRuntime('main = list.at([], 0)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.at empty throws', () {
      final Runtime runtime = getRuntime('main = str.at("", 0)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });
  });

  group('Out of Bounds', () {
    test('list indexing out of bounds', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3][5]');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('string indexing out of bounds', () {
      final Runtime runtime = getRuntime('main = "Hello"[10]');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list.at out of bounds', () {
      final Runtime runtime = getRuntime('main = list.at([1, 2], 5)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.at out of bounds', () {
      final Runtime runtime = getRuntime('main = str.at("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list.removeAt out of bounds', () {
      final Runtime runtime = getRuntime(
        'main = list.removeAt([1, 2], 5)',
      );
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list.swap out of bounds', () {
      final Runtime runtime = getRuntime('main = list.swap([1], 0, 5)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list.sublist out of bounds', () {
      final Runtime runtime = getRuntime('main = list.sublist([1, 2], 0, 10)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('str.substring out of bounds', () {
      final Runtime runtime = getRuntime(
        'main = str.substring("Hi", 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list negative index', () {
      final Runtime runtime = getRuntime('main = list.at([1, 2, 3], -1)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });
  });

  group('Nested Collections', () {
    test('nested list equality', () {
      final Runtime runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 3]]',
      );
      checkResult(runtime, true);
    });

    test('nested list inequality', () {
      final Runtime runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 4]]',
      );
      checkResult(runtime, false);
    });

    test('list of maps', () {
      final Runtime runtime = getRuntime(
        'main = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [{'"a"': 1}, {'"b"': 2}]);
    });

    test('map with list value', () {
      final Runtime runtime = getRuntime(
        'main = {"nums": [1, 2, 3]}',
      );
      checkResult(runtime, {'"nums"': [1, 2, 3]});
    });

    test('deeply nested list', () {
      final Runtime runtime = getRuntime('main = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('index into nested list', () {
      final Runtime runtime = getRuntime(
        'main = ([[1, 2], [3, 4]])[1]',
      );
      checkResult(runtime, [3, 4]);
    });

    test('map with nested map equality', () {
      final Runtime runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 1}}',
      );
      checkResult(runtime, true);
    });

    test('map with nested map inequality', () {
      final Runtime runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 2}}',
      );
      checkResult(runtime, false);
    });
  });

  group('List Type Errors', () {
    test('list.length throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.first throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.first("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.last throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.last("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.isEmpty throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.reverse throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.reverse("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sort throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.sort("hello", num.compare)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.contains throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.contains("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.map throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.map("hello", num.abs)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });
}
