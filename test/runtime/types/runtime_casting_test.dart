import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('To', () {
    test('to.number converts string to number', () {
      final Runtime runtime = getRuntime('main = to.number("12.5")');
      checkResult(runtime, 12.5);
    });

    test('to.number returns number unchanged', () {
      final Runtime runtime = getRuntime('main = to.number(12.5)');
      checkResult(runtime, 12.5);
    });

    test('to.number throws for boolean argument', () {
      final Runtime runtime = getRuntime('main = to.number(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.integer converts string to integer', () {
      final Runtime runtime = getRuntime('main = to.integer("12")');
      checkResult(runtime, 12);
    });

    test('to.integer returns integer unchanged', () {
      final Runtime runtime = getRuntime('main = to.integer(12)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal below .5', () {
      final Runtime runtime = getRuntime('main = to.integer(12.4)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal at .5', () {
      final Runtime runtime = getRuntime('main = to.integer(12.5)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal above .5', () {
      final Runtime runtime = getRuntime('main = to.integer(12.6)');
      checkResult(runtime, 12);
    });

    test('to.integer throws for boolean argument', () {
      final Runtime runtime = getRuntime('main = to.integer(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.decimal converts string to decimal', () {
      final Runtime runtime = getRuntime('main = to.decimal("12")');
      checkResult(runtime, 12.0);
    });

    test('to.decimal converts integer to decimal', () {
      final Runtime runtime = getRuntime('main = to.decimal(12)');
      checkResult(runtime, 12.0);
    });

    test('to.decimal throws for boolean argument', () {
      final Runtime runtime = getRuntime('main = to.decimal(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.string returns string unchanged', () {
      final Runtime runtime = getRuntime('main = to.string("12")');
      checkResult(runtime, '"12"');
    });

    test('to.string converts number to string', () {
      final Runtime runtime = getRuntime('main = to.string(12)');
      checkResult(runtime, '"12"');
    });

    test('to.string converts boolean to string', () {
      final Runtime runtime = getRuntime('main = to.string(true)');
      checkResult(runtime, '"true"');
    });

    test('to.boolean returns true for non-empty string', () {
      final Runtime runtime = getRuntime('main = to.boolean("hello")');
      checkResult(runtime, true);
    });

    test('to.boolean returns false for empty string', () {
      final Runtime runtime = getRuntime('main = to.boolean("")');
      checkResult(runtime, false);
    });

    test('to.boolean returns false for zero', () {
      final Runtime runtime = getRuntime('main = to.boolean(0)');
      checkResult(runtime, false);
    });

    test('to.boolean returns true for positive number', () {
      final Runtime runtime = getRuntime('main = to.boolean(12)');
      checkResult(runtime, true);
    });

    test('to.boolean returns true for negative number', () {
      final Runtime runtime = getRuntime('main = to.boolean(-1)');
      checkResult(runtime, true);
    });

    test('to.boolean returns true unchanged', () {
      final Runtime runtime = getRuntime('main = to.boolean(true)');
      checkResult(runtime, true);
    });

    test('to.boolean returns false unchanged', () {
      final Runtime runtime = getRuntime('main = to.boolean(false)');
      checkResult(runtime, false);
    });

    test('to.list converts set to list', () {
      final Runtime runtime = getRuntime('main = to.list(set.new([1, 2, 3]))');
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts vector to list', () {
      final Runtime runtime = getRuntime(
        'main = to.list(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts stack to list', () {
      final Runtime runtime = getRuntime(
        'main = to.list(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts queue to list', () {
      final Runtime runtime = getRuntime(
        'main = to.list(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('Is', () {
    test('is.number returns true for integer', () {
      final Runtime runtime = getRuntime('main = is.number(42)');
      checkResult(runtime, true);
    });

    test('is.number returns true for decimal', () {
      final Runtime runtime = getRuntime('main = is.number(12.5)');
      checkResult(runtime, true);
    });

    test('is.number returns false for numeric string', () {
      final Runtime runtime = getRuntime('main = is.number("12.5")');
      checkResult(runtime, false);
    });

    test('is.number returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.number(true)');
      checkResult(runtime, false);
    });

    test('is.number returns false for list', () {
      final Runtime runtime = getRuntime('main = is.number([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.number returns false for map', () {
      final Runtime runtime = getRuntime('main = is.number({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.number returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.number(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number returns false for set', () {
      final Runtime runtime = getRuntime(
        'main = is.number(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.number(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.number(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number returns false for function', () {
      final Runtime runtime = getRuntime('main = is.number(num.abs)');
      checkResult(runtime, false);
    });

    test('is.number returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.number(time.now())');
      checkResult(runtime, false);
    });

    test('is.number returns false for file', () {
      final Runtime runtime = getRuntime(
        'main = is.number(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.number returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.number(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.integer returns true for integer', () {
      final Runtime runtime = getRuntime('main = is.integer(12)');
      checkResult(runtime, true);
    });

    test('is.integer returns false for whole decimal', () {
      final Runtime runtime = getRuntime('main = is.integer(12.0)');
      checkResult(runtime, false);
    });

    test('is.integer returns false for fractional decimal', () {
      final Runtime runtime = getRuntime('main = is.integer(12.1)');
      checkResult(runtime, false);
    });

    test('is.integer returns false for string', () {
      final Runtime runtime = getRuntime('main = is.integer("12")');
      checkResult(runtime, false);
    });

    test('is.integer returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.integer(true)');
      checkResult(runtime, false);
    });

    test('is.decimal returns false for integer', () {
      final Runtime runtime = getRuntime('main = is.decimal(12)');
      checkResult(runtime, false);
    });

    test('is.decimal returns true for decimal', () {
      final Runtime runtime = getRuntime('main = is.decimal(12.5)');
      checkResult(runtime, true);
    });

    test('is.decimal returns false for numeric string', () {
      final Runtime runtime = getRuntime('main = is.decimal("12.5")');
      checkResult(runtime, false);
    });

    test('is.decimal returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.decimal(true)');
      checkResult(runtime, false);
    });

    test('is.infinite returns false for finite number', () {
      final Runtime runtime = getRuntime('main = is.infinite(12)');
      checkResult(runtime, false);
    });

    test('is.infinite returns true for division by zero', () {
      final Runtime runtime = getRuntime('main = is.infinite(1/0)');
      checkResult(runtime, true);
    });

    test('is.string returns true for string', () {
      final Runtime runtime = getRuntime('main = is.string("Hey")');
      checkResult(runtime, true);
    });

    test('is.string returns false for number', () {
      final Runtime runtime = getRuntime('main = is.string(12)');
      checkResult(runtime, false);
    });

    test('is.string returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.string(true)');
      checkResult(runtime, false);
    });

    test('is.string returns false for list', () {
      final Runtime runtime = getRuntime('main = is.string([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.string returns false for map', () {
      final Runtime runtime = getRuntime('main = is.string({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.string returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.string(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string returns false for set', () {
      final Runtime runtime = getRuntime(
        'main = is.string(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.string(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.string(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string returns false for function', () {
      final Runtime runtime = getRuntime('main = is.string(num.abs)');
      checkResult(runtime, false);
    });

    test('is.string returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.string(time.now())');
      checkResult(runtime, false);
    });

    test('is.string returns false for file', () {
      final Runtime runtime = getRuntime(
        'main = is.string(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.string returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.string(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for number', () {
      final Runtime runtime = getRuntime('main = is.boolean(12)');
      checkResult(runtime, false);
    });

    test('is.boolean returns false for string "true"', () {
      final Runtime runtime = getRuntime('main = is.boolean("true")');
      checkResult(runtime, false);
    });

    test('is.boolean returns true for boolean value', () {
      final Runtime runtime = getRuntime('main = is.boolean(true)');
      checkResult(runtime, true);
    });

    test('is.boolean returns false for list', () {
      final Runtime runtime = getRuntime('main = is.boolean([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.boolean returns false for map', () {
      final Runtime runtime = getRuntime('main = is.boolean({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.boolean returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for set', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for function', () {
      final Runtime runtime = getRuntime('main = is.boolean(num.abs)');
      checkResult(runtime, false);
    });

    test('is.boolean returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.boolean(time.now())');
      checkResult(runtime, false);
    });

    test('is.boolean returns false for file', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.list returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.list(true)');
      checkResult(runtime, false);
    });

    test('is.list returns false for number', () {
      final Runtime runtime = getRuntime('main = is.list(1)');
      checkResult(runtime, false);
    });

    test('is.list returns false for string', () {
      final Runtime runtime = getRuntime('main = is.list("Hello")');
      checkResult(runtime, false);
    });

    test('is.list returns true for empty list', () {
      final Runtime runtime = getRuntime('main = is.list([])');
      checkResult(runtime, true);
    });

    test('is.list returns true for non-empty list', () {
      final Runtime runtime = getRuntime('main = is.list([1, 2, 3])');
      checkResult(runtime, true);
    });

    test('is.list returns false for map', () {
      final Runtime runtime = getRuntime('main = is.list({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.list returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.list(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list returns false for set', () {
      final Runtime runtime = getRuntime('main = is.list(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.list returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.list(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.list(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list returns false for function', () {
      final Runtime runtime = getRuntime('main = is.list(num.abs)');
      checkResult(runtime, false);
    });

    test('is.list returns false for file', () {
      final Runtime runtime = getRuntime('main = is.list(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.list returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.list(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.list returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.list(time.now())');
      checkResult(runtime, false);
    });

    test('is.map returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.map(true)');
      checkResult(runtime, false);
    });

    test('is.map returns false for number', () {
      final Runtime runtime = getRuntime('main = is.map(1)');
      checkResult(runtime, false);
    });

    test('is.map returns false for string', () {
      final Runtime runtime = getRuntime('main = is.list("map")');
      checkResult(runtime, false);
    });

    test('is.map returns true for empty map', () {
      final Runtime runtime = getRuntime('main = is.map({})');
      checkResult(runtime, true);
    });

    test('is.map returns false for list', () {
      final Runtime runtime = getRuntime('main = is.map([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.map returns true for non-empty map', () {
      final Runtime runtime = getRuntime('main = is.map({"foo": 1})');
      checkResult(runtime, true);
    });

    test('is.map returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.map(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.map returns false for set', () {
      final Runtime runtime = getRuntime('main = is.map(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map returns false for stack', () {
      final Runtime runtime = getRuntime('main = is.map(stack.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map returns false for queue', () {
      final Runtime runtime = getRuntime('main = is.map(queue.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map returns false for function', () {
      final Runtime runtime = getRuntime('main = is.map(num.abs)');
      checkResult(runtime, false);
    });

    test('is.map returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.map(time.now())');
      checkResult(runtime, false);
    });

    test('is.map returns false for file', () {
      final Runtime runtime = getRuntime('main = is.map(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.map returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.map(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.vector returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.vector(true)');
      checkResult(runtime, false);
    });

    test('is.vector returns false for number', () {
      final Runtime runtime = getRuntime('main = is.vector(1)');
      checkResult(runtime, false);
    });

    test('is.vector returns false for string', () {
      final Runtime runtime = getRuntime('main = is.vector("Hello")');
      checkResult(runtime, false);
    });

    test('is.vector returns false for empty list', () {
      final Runtime runtime = getRuntime('main = is.vector([])');
      checkResult(runtime, false);
    });

    test('is.vector returns false for list', () {
      final Runtime runtime = getRuntime('main = is.vector([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.vector returns false for map', () {
      final Runtime runtime = getRuntime('main = is.vector({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.vector returns true for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.vector returns false for set', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector returns false for function', () {
      final Runtime runtime = getRuntime('main = is.vector(num.abs)');
      checkResult(runtime, false);
    });

    test('is.vector returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.vector(time.now())');
      checkResult(runtime, false);
    });

    test('is.vector returns false for file', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.vector returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.set returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.set(true)');
      checkResult(runtime, false);
    });

    test('is.set returns false for number', () {
      final Runtime runtime = getRuntime('main = is.set(1)');
      checkResult(runtime, false);
    });

    test('is.set returns false for string', () {
      final Runtime runtime = getRuntime('main = is.set("Hello")');
      checkResult(runtime, false);
    });

    test('is.set returns false for empty list', () {
      final Runtime runtime = getRuntime('main = is.set([])');
      checkResult(runtime, false);
    });

    test('is.set returns false for list', () {
      final Runtime runtime = getRuntime('main = is.set([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.set returns false for map', () {
      final Runtime runtime = getRuntime('main = is.set({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.set returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.set(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.set returns true for set', () {
      final Runtime runtime = getRuntime('main = is.set(set.new([1, 2, 3]))');
      checkResult(runtime, true);
    });

    test('is.set returns false for stack', () {
      final Runtime runtime = getRuntime('main = is.set(stack.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.set returns false for queue', () {
      final Runtime runtime = getRuntime('main = is.set(queue.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.set returns false for function', () {
      final Runtime runtime = getRuntime('main = is.set(num.abs)');
      checkResult(runtime, false);
    });

    test('is.set returns false for file', () {
      final Runtime runtime = getRuntime('main = is.set(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.set returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.set(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.set returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.set(time.now())');
      checkResult(runtime, false);
    });

    test('is.stack returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.stack(true)');
      checkResult(runtime, false);
    });

    test('is.stack returns false for number', () {
      final Runtime runtime = getRuntime('main = is.stack(1)');
      checkResult(runtime, false);
    });

    test('is.stack returns false for string', () {
      final Runtime runtime = getRuntime('main = is.stack("Hello")');
      checkResult(runtime, false);
    });

    test('is.stack returns false for empty list', () {
      final Runtime runtime = getRuntime('main = is.stack([])');
      checkResult(runtime, false);
    });

    test('is.stack returns false for list', () {
      final Runtime runtime = getRuntime('main = is.stack([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.stack returns false for map', () {
      final Runtime runtime = getRuntime('main = is.stack({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.stack returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.stack returns false for set', () {
      final Runtime runtime = getRuntime('main = is.stack(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.stack returns true for empty stack', () {
      final Runtime runtime = getRuntime('main = is.stack(stack.new([]))');
      checkResult(runtime, true);
    });

    test('is.stack returns true for non-empty stack', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.stack returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.stack returns false for function', () {
      final Runtime runtime = getRuntime('main = is.stack(num.abs)');
      checkResult(runtime, false);
    });

    test('is.stack returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.stack(time.now())');
      checkResult(runtime, false);
    });

    test('is.stack returns false for file', () {
      final Runtime runtime = getRuntime('main = is.stack(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.stack returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.queue returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.queue(true)');
      checkResult(runtime, false);
    });

    test('is.queue returns false for number', () {
      final Runtime runtime = getRuntime('main = is.queue(1)');
      checkResult(runtime, false);
    });

    test('is.queue returns false for string', () {
      final Runtime runtime = getRuntime('main = is.queue("Hello")');
      checkResult(runtime, false);
    });

    test('is.queue returns false for empty list', () {
      final Runtime runtime = getRuntime('main = is.queue([])');
      checkResult(runtime, false);
    });

    test('is.queue returns false for list', () {
      final Runtime runtime = getRuntime('main = is.queue([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.queue returns false for map', () {
      final Runtime runtime = getRuntime('main = is.queue({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.queue returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.queue returns false for set', () {
      final Runtime runtime = getRuntime('main = is.queue(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.queue returns false for empty stack', () {
      final Runtime runtime = getRuntime('main = is.queue(stack.new([]))');
      checkResult(runtime, false);
    });

    test('is.queue returns false for non-empty stack', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.queue returns true for empty queue', () {
      final Runtime runtime = getRuntime('main = is.queue(queue.new([]))');
      checkResult(runtime, true);
    });

    test('is.queue returns true for non-empty queue', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.queue returns false for function', () {
      final Runtime runtime = getRuntime('main = is.queue(num.abs)');
      checkResult(runtime, false);
    });

    test('is.queue returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.queue(time.now())');
      checkResult(runtime, false);
    });

    test('is.queue returns false for file', () {
      final Runtime runtime = getRuntime('main = is.queue(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.queue returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.function(true)');
      checkResult(runtime, false);
    });

    test('is.function returns false for number', () {
      final Runtime runtime = getRuntime('main = is.function(1)');
      checkResult(runtime, false);
    });

    test('is.function returns false for string', () {
      final Runtime runtime = getRuntime('main = is.function("Hello")');
      checkResult(runtime, false);
    });

    test('is.function returns false for list', () {
      final Runtime runtime = getRuntime('main = is.function([])');
      checkResult(runtime, false);
    });

    test('is.function returns false for map', () {
      final Runtime runtime = getRuntime('main = is.function({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.function returns false for vector', () {
      final Runtime runtime = getRuntime(
        'main = is.function(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns false for set', () {
      final Runtime runtime = getRuntime(
        'main = is.function(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns false for stack', () {
      final Runtime runtime = getRuntime(
        'main = is.function(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns false for queue', () {
      final Runtime runtime = getRuntime(
        'main = is.function(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns true for function reference', () {
      final Runtime runtime = getRuntime('main = is.function(num.abs)');
      checkResult(runtime, true);
    });

    test('is.function returns false for timestamp', () {
      final Runtime runtime = getRuntime('main = is.function(time.now())');
      checkResult(runtime, false);
    });

    test('is.function returns false for file', () {
      final Runtime runtime = getRuntime(
        'main = is.function(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.function returns false for directory', () {
      final Runtime runtime = getRuntime(
        'main = is.function(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp returns false for boolean', () {
      final Runtime runtime = getRuntime('main = is.timestamp(true)');
      checkResult(runtime, false);
    });

    test('is.timestamp returns false for number', () {
      final Runtime runtime = getRuntime('main = is.timestamp(1)');
      checkResult(runtime, false);
    });

    test('is.timestamp returns false for string', () {
      final Runtime runtime = getRuntime('main = is.timestamp("Hello")');
      checkResult(runtime, false);
    });

    test('is.timestamp 4', () {
      final Runtime runtime = getRuntime('main = is.timestamp([])');
      checkResult(runtime, false);
    });

    test('is.timestamp 5', () {
      final Runtime runtime = getRuntime('main = is.timestamp({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.timestamp 6', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 7', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 8', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 9', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 10', () {
      final Runtime runtime = getRuntime('main = is.timestamp(num.abs)');
      checkResult(runtime, false);
    });

    test('is.timestamp 11', () {
      final Runtime runtime = getRuntime('main = is.timestamp(time.now())');
      checkResult(runtime, true);
    });

    test('is.timestamp 12', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 13', () {
      final Runtime runtime = getRuntime(
        'main = is.timestamp(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.file 1', () {
      final Runtime runtime = getRuntime('main = is.file(true)');
      checkResult(runtime, false);
    });

    test('is.file 2', () {
      final Runtime runtime = getRuntime('main = is.file(1)');
      checkResult(runtime, false);
    });

    test('is.file 3', () {
      final Runtime runtime = getRuntime('main = is.file("Hello")');
      checkResult(runtime, false);
    });

    test('is.file 4', () {
      final Runtime runtime = getRuntime('main = is.file([])');
      checkResult(runtime, false);
    });

    test('is.file 5', () {
      final Runtime runtime = getRuntime('main = is.file({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.file 6', () {
      final Runtime runtime = getRuntime(
        'main = is.file(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.file 7', () {
      final Runtime runtime = getRuntime('main = is.file(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.file 8', () {
      final Runtime runtime = getRuntime(
        'main = is.file(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.file 9', () {
      final Runtime runtime = getRuntime(
        'main = is.file(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.file 10', () {
      final Runtime runtime = getRuntime('main = is.file(num.abs)');
      checkResult(runtime, false);
    });

    test('is.file 11', () {
      final Runtime runtime = getRuntime('main = is.file(time.now())');
      checkResult(runtime, false);
    });

    test('is.file 12', () {
      final Runtime runtime = getRuntime('main = is.file(file.fromPath("."))');
      checkResult(runtime, true);
    });

    test('is.file 13', () {
      final Runtime runtime = getRuntime(
        'main = is.file(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 1', () {
      final Runtime runtime = getRuntime('main = is.directory(true)');
      checkResult(runtime, false);
    });

    test('is.directory 2', () {
      final Runtime runtime = getRuntime('main = is.directory(1)');
      checkResult(runtime, false);
    });

    test('is.directory 3', () {
      final Runtime runtime = getRuntime('main = is.directory("Hello")');
      checkResult(runtime, false);
    });

    test('is.directory 4', () {
      final Runtime runtime = getRuntime('main = is.directory([])');
      checkResult(runtime, false);
    });

    test('is.directory 5', () {
      final Runtime runtime = getRuntime('main = is.directory({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.directory 6', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 7', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 8', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 9', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 10', () {
      final Runtime runtime = getRuntime('main = is.directory(num.abs)');
      checkResult(runtime, false);
    });

    test('is.directory 11', () {
      final Runtime runtime = getRuntime('main = is.directory(time.now())');
      checkResult(runtime, false);
    });

    test('is.directory 12', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.directory 13', () {
      final Runtime runtime = getRuntime(
        'main = is.directory(directory.fromPath("."))',
      );
      checkResult(runtime, true);
    });
  });

  group('Casting Edge Cases', () {
    test('to.number non-numeric string throws', () {
      final Runtime runtime = getRuntime('main = to.number("hello")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('to.integer non-numeric string throws', () {
      final Runtime runtime = getRuntime('main = to.integer("hello")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('to.list with number throws', () {
      final Runtime runtime = getRuntime('main = to.list(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.boolean with list throws', () {
      final Runtime runtime = getRuntime('main = to.boolean([])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.boolean with map throws', () {
      final Runtime runtime = getRuntime('main = to.boolean({})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.decimal non-numeric string throws', () {
      final Runtime runtime = getRuntime('main = to.decimal("hello")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('to.list with list', () {
      final Runtime runtime = getRuntime('main = to.list([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
