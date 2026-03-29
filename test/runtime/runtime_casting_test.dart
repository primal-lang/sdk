import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('To', () {
    test('to.number 1', () {
      final Runtime runtime = getRuntime('main = to.number("12.5")');
      checkResult(runtime, 12.5);
    });

    test('to.number 2', () {
      final Runtime runtime = getRuntime('main = to.number(12.5)');
      checkResult(runtime, 12.5);
    });

    test('to.number 3', () {
      final Runtime runtime = getRuntime('main = to.number(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.integer 1', () {
      final Runtime runtime = getRuntime('main = to.integer("12")');
      checkResult(runtime, 12);
    });

    test('to.integer 2', () {
      final Runtime runtime = getRuntime('main = to.integer(12)');
      checkResult(runtime, 12);
    });

    test('to.integer 3', () {
      final Runtime runtime = getRuntime('main = to.integer(12.4)');
      checkResult(runtime, 12);
    });

    test('to.integer 4', () {
      final Runtime runtime = getRuntime('main = to.integer(12.5)');
      checkResult(runtime, 12);
    });

    test('to.integer 5', () {
      final Runtime runtime = getRuntime('main = to.integer(12.6)');
      checkResult(runtime, 12);
    });

    test('to.integer 6', () {
      final Runtime runtime = getRuntime('main = to.integer(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.decimal 1', () {
      final Runtime runtime = getRuntime('main = to.decimal("12")');
      checkResult(runtime, 12.0);
    });

    test('to.decimal 2', () {
      final Runtime runtime = getRuntime('main = to.decimal(12)');
      checkResult(runtime, 12.0);
    });

    test('to.decimal 3', () {
      final Runtime runtime = getRuntime('main = to.decimal(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.string 1', () {
      final Runtime runtime = getRuntime('main = to.string("12")');
      checkResult(runtime, '"12"');
    });

    test('to.string 2', () {
      final Runtime runtime = getRuntime('main = to.string(12)');
      checkResult(runtime, '"12"');
    });

    test('to.string 3', () {
      final Runtime runtime = getRuntime('main = to.string(true)');
      checkResult(runtime, '"true"');
    });

    test('to.boolean 1', () {
      final Runtime runtime = getRuntime('main = to.boolean("hello")');
      checkResult(runtime, true);
    });

    test('to.boolean 2', () {
      final Runtime runtime = getRuntime('main = to.boolean("")');
      checkResult(runtime, false);
    });

    test('to.boolean 3', () {
      final Runtime runtime = getRuntime('main = to.boolean(0)');
      checkResult(runtime, false);
    });

    test('to.boolean 4', () {
      final Runtime runtime = getRuntime('main = to.boolean(12)');
      checkResult(runtime, true);
    });

    test('to.boolean 5', () {
      final Runtime runtime = getRuntime('main = to.boolean(-1)');
      checkResult(runtime, true);
    });

    test('to.boolean 6', () {
      final Runtime runtime = getRuntime('main = to.boolean(true)');
      checkResult(runtime, true);
    });

    test('to.boolean 7', () {
      final Runtime runtime = getRuntime('main = to.boolean(false)');
      checkResult(runtime, false);
    });

    test('to.list 1', () {
      final Runtime runtime = getRuntime('main = to.list(set.new([1, 2, 3]))');
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list 2', () {
      final Runtime runtime = getRuntime(
        'main = to.list(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list 3', () {
      final Runtime runtime = getRuntime(
        'main = to.list(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list 4', () {
      final Runtime runtime = getRuntime(
        'main = to.list(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('Is', () {
    test('is.number 1', () {
      final Runtime runtime = getRuntime('main = is.number(42)');
      checkResult(runtime, true);
    });

    test('is.number 2', () {
      final Runtime runtime = getRuntime('main = is.number(12.5)');
      checkResult(runtime, true);
    });

    test('is.number 3', () {
      final Runtime runtime = getRuntime('main = is.number("12.5")');
      checkResult(runtime, false);
    });

    test('is.number 4', () {
      final Runtime runtime = getRuntime('main = is.number(true)');
      checkResult(runtime, false);
    });

    test('is.number 5', () {
      final Runtime runtime = getRuntime('main = is.number([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.number 6', () {
      final Runtime runtime = getRuntime('main = is.number({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.number 7', () {
      final Runtime runtime = getRuntime(
        'main = is.number(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number 8', () {
      final Runtime runtime = getRuntime(
        'main = is.number(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number 9', () {
      final Runtime runtime = getRuntime(
        'main = is.number(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number 10', () {
      final Runtime runtime = getRuntime(
        'main = is.number(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.number 11', () {
      final Runtime runtime = getRuntime('main = is.number(num.abs)');
      checkResult(runtime, false);
    });

    test('is.number 12', () {
      final Runtime runtime = getRuntime('main = is.number(time.now())');
      checkResult(runtime, false);
    });

    test('is.number 13', () {
      final Runtime runtime = getRuntime(
        'main = is.number(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.number 14', () {
      final Runtime runtime = getRuntime(
        'main = is.number(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.integer 1', () {
      final Runtime runtime = getRuntime('main = is.integer(12)');
      checkResult(runtime, true);
    });

    test('is.integer 2', () {
      final Runtime runtime = getRuntime('main = is.integer(12.0)');
      checkResult(runtime, false);
    });

    test('is.integer 3', () {
      final Runtime runtime = getRuntime('main = is.integer(12.1)');
      checkResult(runtime, false);
    });

    test('is.integer 4', () {
      final Runtime runtime = getRuntime('main = is.integer("12")');
      checkResult(runtime, false);
    });

    test('is.integer 5', () {
      final Runtime runtime = getRuntime('main = is.integer(true)');
      checkResult(runtime, false);
    });

    test('is.decimal 1', () {
      final Runtime runtime = getRuntime('main = is.decimal(12)');
      checkResult(runtime, false);
    });

    test('is.decimal 2', () {
      final Runtime runtime = getRuntime('main = is.decimal(12.5)');
      checkResult(runtime, true);
    });

    test('is.decimal 3', () {
      final Runtime runtime = getRuntime('main = is.decimal("12.5")');
      checkResult(runtime, false);
    });

    test('is.decimal 4', () {
      final Runtime runtime = getRuntime('main = is.decimal(true)');
      checkResult(runtime, false);
    });

    test('is.infinite 1', () {
      final Runtime runtime = getRuntime('main = is.infinite(12)');
      checkResult(runtime, false);
    });

    test('is.infinite 2', () {
      final Runtime runtime = getRuntime('main = is.infinite(1/0)');
      checkResult(runtime, true);
    });

    test('is.string 1', () {
      final Runtime runtime = getRuntime('main = is.string("Hey")');
      checkResult(runtime, true);
    });

    test('is.string 2', () {
      final Runtime runtime = getRuntime('main = is.string(12)');
      checkResult(runtime, false);
    });

    test('is.string 3', () {
      final Runtime runtime = getRuntime('main = is.string(true)');
      checkResult(runtime, false);
    });

    test('is.string 4', () {
      final Runtime runtime = getRuntime('main = is.string([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.string 5', () {
      final Runtime runtime = getRuntime('main = is.string({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.string 6', () {
      final Runtime runtime = getRuntime(
        'main = is.string(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string 7', () {
      final Runtime runtime = getRuntime(
        'main = is.string(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string 8', () {
      final Runtime runtime = getRuntime(
        'main = is.string(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string 9', () {
      final Runtime runtime = getRuntime(
        'main = is.string(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.string 10', () {
      final Runtime runtime = getRuntime('main = is.string(num.abs)');
      checkResult(runtime, false);
    });

    test('is.string 11', () {
      final Runtime runtime = getRuntime('main = is.string(time.now())');
      checkResult(runtime, false);
    });

    test('is.string 12', () {
      final Runtime runtime = getRuntime(
        'main = is.string(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.string 13', () {
      final Runtime runtime = getRuntime(
        'main = is.string(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 1', () {
      final Runtime runtime = getRuntime('main = is.boolean(12)');
      checkResult(runtime, false);
    });

    test('is.boolean 2', () {
      final Runtime runtime = getRuntime('main = is.boolean("true")');
      checkResult(runtime, false);
    });

    test('is.boolean 3', () {
      final Runtime runtime = getRuntime('main = is.boolean(true)');
      checkResult(runtime, true);
    });

    test('is.boolean 4', () {
      final Runtime runtime = getRuntime('main = is.boolean([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.boolean 5', () {
      final Runtime runtime = getRuntime('main = is.boolean({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.boolean 6', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 7', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 8', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 9', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 10', () {
      final Runtime runtime = getRuntime('main = is.boolean(num.abs)');
      checkResult(runtime, false);
    });

    test('is.boolean 11', () {
      final Runtime runtime = getRuntime('main = is.boolean(time.now())');
      checkResult(runtime, false);
    });

    test('is.boolean 12', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.boolean 13', () {
      final Runtime runtime = getRuntime(
        'main = is.boolean(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.list 1', () {
      final Runtime runtime = getRuntime('main = is.list(true)');
      checkResult(runtime, false);
    });

    test('is.list 2', () {
      final Runtime runtime = getRuntime('main = is.list(1)');
      checkResult(runtime, false);
    });

    test('is.list 3', () {
      final Runtime runtime = getRuntime('main = is.list("Hello")');
      checkResult(runtime, false);
    });

    test('is.list 4', () {
      final Runtime runtime = getRuntime('main = is.list([])');
      checkResult(runtime, true);
    });

    test('is.list 5', () {
      final Runtime runtime = getRuntime('main = is.list([1, 2, 3])');
      checkResult(runtime, true);
    });

    test('is.list 6', () {
      final Runtime runtime = getRuntime('main = is.list({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.list 7', () {
      final Runtime runtime = getRuntime(
        'main = is.list(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list 8', () {
      final Runtime runtime = getRuntime('main = is.list(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.list 9', () {
      final Runtime runtime = getRuntime(
        'main = is.list(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list 10', () {
      final Runtime runtime = getRuntime(
        'main = is.list(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.list 11', () {
      final Runtime runtime = getRuntime('main = is.list(num.abs)');
      checkResult(runtime, false);
    });

    test('is.list 12', () {
      final Runtime runtime = getRuntime('main = is.list(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.list 13', () {
      final Runtime runtime = getRuntime(
        'main = is.list(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.list 14', () {
      final Runtime runtime = getRuntime('main = is.list(time.now())');
      checkResult(runtime, false);
    });

    test('is.map 1', () {
      final Runtime runtime = getRuntime('main = is.map(true)');
      checkResult(runtime, false);
    });

    test('is.map 2', () {
      final Runtime runtime = getRuntime('main = is.map(1)');
      checkResult(runtime, false);
    });

    test('is.map 3', () {
      final Runtime runtime = getRuntime('main = is.list("map")');
      checkResult(runtime, false);
    });

    test('is.map 4', () {
      final Runtime runtime = getRuntime('main = is.map({})');
      checkResult(runtime, true);
    });

    test('is.map 5', () {
      final Runtime runtime = getRuntime('main = is.map([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.map 6', () {
      final Runtime runtime = getRuntime('main = is.map({"foo": 1})');
      checkResult(runtime, true);
    });

    test('is.map 7', () {
      final Runtime runtime = getRuntime(
        'main = is.map(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.map 8', () {
      final Runtime runtime = getRuntime('main = is.map(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map 9', () {
      final Runtime runtime = getRuntime('main = is.map(stack.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map 10', () {
      final Runtime runtime = getRuntime('main = is.map(queue.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map 11', () {
      final Runtime runtime = getRuntime('main = is.map(num.abs)');
      checkResult(runtime, false);
    });

    test('is.map 12', () {
      final Runtime runtime = getRuntime('main = is.map(time.now())');
      checkResult(runtime, false);
    });

    test('is.map 13', () {
      final Runtime runtime = getRuntime('main = is.map(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.map 14', () {
      final Runtime runtime = getRuntime(
        'main = is.map(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.vector 1', () {
      final Runtime runtime = getRuntime('main = is.vector(true)');
      checkResult(runtime, false);
    });

    test('is.vector 2', () {
      final Runtime runtime = getRuntime('main = is.vector(1)');
      checkResult(runtime, false);
    });

    test('is.vector 3', () {
      final Runtime runtime = getRuntime('main = is.vector("Hello")');
      checkResult(runtime, false);
    });

    test('is.vector 4', () {
      final Runtime runtime = getRuntime('main = is.vector([])');
      checkResult(runtime, false);
    });

    test('is.vector 5', () {
      final Runtime runtime = getRuntime('main = is.vector([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.vector 6', () {
      final Runtime runtime = getRuntime('main = is.vector({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.vector 7', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.vector 8', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector 9', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector 10', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.vector 11', () {
      final Runtime runtime = getRuntime('main = is.vector(num.abs)');
      checkResult(runtime, false);
    });

    test('is.vector 12', () {
      final Runtime runtime = getRuntime('main = is.vector(time.now())');
      checkResult(runtime, false);
    });

    test('is.vector 13', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.vector 14', () {
      final Runtime runtime = getRuntime(
        'main = is.vector(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.set 1', () {
      final Runtime runtime = getRuntime('main = is.set(true)');
      checkResult(runtime, false);
    });

    test('is.set 2', () {
      final Runtime runtime = getRuntime('main = is.set(1)');
      checkResult(runtime, false);
    });

    test('is.set 3', () {
      final Runtime runtime = getRuntime('main = is.set("Hello")');
      checkResult(runtime, false);
    });

    test('is.set 4', () {
      final Runtime runtime = getRuntime('main = is.set([])');
      checkResult(runtime, false);
    });

    test('is.set 5', () {
      final Runtime runtime = getRuntime('main = is.set([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.set 6', () {
      final Runtime runtime = getRuntime('main = is.set({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.set 7', () {
      final Runtime runtime = getRuntime(
        'main = is.set(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.set 8', () {
      final Runtime runtime = getRuntime('main = is.set(set.new([1, 2, 3]))');
      checkResult(runtime, true);
    });

    test('is.set 9', () {
      final Runtime runtime = getRuntime('main = is.set(stack.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.set 10', () {
      final Runtime runtime = getRuntime('main = is.set(queue.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.set 11', () {
      final Runtime runtime = getRuntime('main = is.set(num.abs)');
      checkResult(runtime, false);
    });

    test('is.set 12', () {
      final Runtime runtime = getRuntime('main = is.set(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.set 13', () {
      final Runtime runtime = getRuntime(
        'main = is.set(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.set 14', () {
      final Runtime runtime = getRuntime('main = is.set(time.now())');
      checkResult(runtime, false);
    });

    test('is.stack 1', () {
      final Runtime runtime = getRuntime('main = is.stack(true)');
      checkResult(runtime, false);
    });

    test('is.stack 2', () {
      final Runtime runtime = getRuntime('main = is.stack(1)');
      checkResult(runtime, false);
    });

    test('is.stack 3', () {
      final Runtime runtime = getRuntime('main = is.stack("Hello")');
      checkResult(runtime, false);
    });

    test('is.stack 4', () {
      final Runtime runtime = getRuntime('main = is.stack([])');
      checkResult(runtime, false);
    });

    test('is.stack 5', () {
      final Runtime runtime = getRuntime('main = is.stack([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.stack 6', () {
      final Runtime runtime = getRuntime('main = is.stack({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.stack 7', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.stack 8', () {
      final Runtime runtime = getRuntime('main = is.stack(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.stack 9', () {
      final Runtime runtime = getRuntime('main = is.stack(stack.new([]))');
      checkResult(runtime, true);
    });

    test('is.stack 10', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.stack 11', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.stack 12', () {
      final Runtime runtime = getRuntime('main = is.stack(num.abs)');
      checkResult(runtime, false);
    });

    test('is.stack 13', () {
      final Runtime runtime = getRuntime('main = is.stack(time.now())');
      checkResult(runtime, false);
    });

    test('is.stack 14', () {
      final Runtime runtime = getRuntime('main = is.stack(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.stack 15', () {
      final Runtime runtime = getRuntime(
        'main = is.stack(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.queue 1', () {
      final Runtime runtime = getRuntime('main = is.queue(true)');
      checkResult(runtime, false);
    });

    test('is.queue 2', () {
      final Runtime runtime = getRuntime('main = is.queue(1)');
      checkResult(runtime, false);
    });

    test('is.queue 3', () {
      final Runtime runtime = getRuntime('main = is.queue("Hello")');
      checkResult(runtime, false);
    });

    test('is.queue 4', () {
      final Runtime runtime = getRuntime('main = is.queue([])');
      checkResult(runtime, false);
    });

    test('is.queue 5', () {
      final Runtime runtime = getRuntime('main = is.queue([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is.queue 6', () {
      final Runtime runtime = getRuntime('main = is.queue({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.queue 7', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.queue 8', () {
      final Runtime runtime = getRuntime('main = is.queue(set.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.queue 9', () {
      final Runtime runtime = getRuntime('main = is.queue(stack.new([]))');
      checkResult(runtime, false);
    });

    test('is.queue 10', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.queue 11', () {
      final Runtime runtime = getRuntime('main = is.queue(queue.new([]))');
      checkResult(runtime, true);
    });

    test('is.queue 12', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is.queue 13', () {
      final Runtime runtime = getRuntime('main = is.queue(num.abs)');
      checkResult(runtime, false);
    });

    test('is.queue 14', () {
      final Runtime runtime = getRuntime('main = is.queue(time.now())');
      checkResult(runtime, false);
    });

    test('is.queue 15', () {
      final Runtime runtime = getRuntime('main = is.queue(file.fromPath("."))');
      checkResult(runtime, false);
    });

    test('is.queue 16', () {
      final Runtime runtime = getRuntime(
        'main = is.queue(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.function 1', () {
      final Runtime runtime = getRuntime('main = is.function(true)');
      checkResult(runtime, false);
    });

    test('is.function 2', () {
      final Runtime runtime = getRuntime('main = is.function(1)');
      checkResult(runtime, false);
    });

    test('is.function 3', () {
      final Runtime runtime = getRuntime('main = is.function("Hello")');
      checkResult(runtime, false);
    });

    test('is.function 4', () {
      final Runtime runtime = getRuntime('main = is.function([])');
      checkResult(runtime, false);
    });

    test('is.function 5', () {
      final Runtime runtime = getRuntime('main = is.function({"foo": 1})');
      checkResult(runtime, false);
    });

    test('is.function 6', () {
      final Runtime runtime = getRuntime(
        'main = is.function(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function 7', () {
      final Runtime runtime = getRuntime(
        'main = is.function(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function 8', () {
      final Runtime runtime = getRuntime(
        'main = is.function(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function 9', () {
      final Runtime runtime = getRuntime(
        'main = is.function(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('is.function 10', () {
      final Runtime runtime = getRuntime('main = is.function(num.abs)');
      checkResult(runtime, true);
    });

    test('is.function 11', () {
      final Runtime runtime = getRuntime('main = is.function(time.now())');
      checkResult(runtime, false);
    });

    test('is.function 12', () {
      final Runtime runtime = getRuntime(
        'main = is.function(file.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.function 13', () {
      final Runtime runtime = getRuntime(
        'main = is.function(directory.fromPath("."))',
      );
      checkResult(runtime, false);
    });

    test('is.timestamp 1', () {
      final Runtime runtime = getRuntime('main = is.timestamp(true)');
      checkResult(runtime, false);
    });

    test('is.timestamp 2', () {
      final Runtime runtime = getRuntime('main = is.timestamp(1)');
      checkResult(runtime, false);
    });

    test('is.timestamp 3', () {
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
