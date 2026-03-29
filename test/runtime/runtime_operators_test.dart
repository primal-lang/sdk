import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('Operators', () {
    test('== 1', () {
      final Runtime runtime = getRuntime('main = "hey" == "hey"');
      checkResult(runtime, true);
    });

    test('== 2', () {
      final Runtime runtime = getRuntime('main = "hey" == "heyo"');
      checkResult(runtime, false);
    });

    test('== 3', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 1)');
      checkResult(runtime, true);
    });

    test('== 4', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 2)');
      checkResult(runtime, false);
    });

    test('== 5', () {
      final Runtime runtime = getRuntime('main = true == (1 >= 1)');
      checkResult(runtime, true);
    });

    test('== 6', () {
      final Runtime runtime = getRuntime('main = true == (1 > 1)');
      checkResult(runtime, false);
    });

    test('== 7', () {
      final Runtime runtime = getRuntime('main = [] == []');
      checkResult(runtime, true);
    });

    test('== 8', () {
      final Runtime runtime = getRuntime('main = [] == [1, 2, 3]');
      checkResult(runtime, false);
    });

    test('== 9', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] == []');
      checkResult(runtime, false);
    });

    test('== 10', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] == [1, 2, 3]');
      checkResult(runtime, true);
    });

    test('== 11', () {
      final Runtime runtime = getRuntime(
        'main = [1, 2, 3] == [4 - 3, 1 + 1, 3 * 1]',
      );
      checkResult(runtime, true);
    });

    test('== 12', () {
      final Runtime runtime = getRuntime('main = {} == {}');
      checkResult(runtime, true);
    });

    test('== 13', () {
      final Runtime runtime = getRuntime('main = {} == {"a": 1}');
      checkResult(runtime, false);
    });

    test('== 14', () {
      final Runtime runtime = getRuntime('main = {"a": 1} == {}');
      checkResult(runtime, false);
    });

    test('== 15', () {
      final Runtime runtime = getRuntime(
        'main = {"a": 1, "b": 2, "c": 3} == {"a": 1, "b": 2, "c": 3}',
      );
      checkResult(runtime, true);
    });

    test('== 16', () {
      final Runtime runtime = getRuntime(
        'main = {"a": 1, "b": 2, "c": 3} == {"a": 3 - 2, "b": 1 + 1, "c": 3 * 1}',
      );
      checkResult(runtime, true);
    });

    test('== 17', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('== 18', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('== 19', () {
      final Runtime runtime = getRuntime('main = set.new([]) == set.new([])');
      checkResult(runtime, true);
    });

    test('== 20', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2, 3]) == set.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== 21', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) == set.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== 22', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([]) == stack.new([])',
      );
      checkResult(runtime, true);
    });

    test('== 23', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2, 3]) == stack.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== 24', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2]) == stack.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== 25', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([]) == queue.new([])',
      );
      checkResult(runtime, true);
    });

    test('== 26', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2, 3]) == queue.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== 27', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2]) == queue.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== 28', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) == vector.new([])',
      );
      checkResult(runtime, true);
    });

    test('== 29', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2, 3]) == vector.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== 30', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) == vector.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== 31', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") == file.fromPath(".")',
      );
      checkResult(runtime, true);
    });

    test('== 32', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") == file.fromPath("..")',
      );
      checkResult(runtime, false);
    });

    test('== 33', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") == directory.fromPath(".")',
      );
      checkResult(runtime, true);
    });

    test('== 34', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") == directory.fromPath("..")',
      );
      checkResult(runtime, false);
    });

    test('!= 1', () {
      final Runtime runtime = getRuntime('main = "hey" != "hey"');
      checkResult(runtime, false);
    });

    test('!= 2', () {
      final Runtime runtime = getRuntime('main = "hey" != "heyo"');
      checkResult(runtime, true);
    });

    test('!= 3', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 1)');
      checkResult(runtime, false);
    });

    test('!= 4', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 2)');
      checkResult(runtime, true);
    });

    test('!= 5', () {
      final Runtime runtime = getRuntime('main = true != (1 >= 1)');
      checkResult(runtime, false);
    });

    test('!= 6', () {
      final Runtime runtime = getRuntime('main = true != (1 > 1)');
      checkResult(runtime, true);
    });

    test('!= 7', () {
      final Runtime runtime = getRuntime('main = [] != []');
      checkResult(runtime, false);
    });

    test('!= 8', () {
      final Runtime runtime = getRuntime('main = [] != [1, 2, 3]');
      checkResult(runtime, true);
    });

    test('!= 9', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != []');
      checkResult(runtime, true);
    });

    test('!= 10', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 4]');
      checkResult(runtime, true);
    });

    test('!= 11', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 3]');
      checkResult(runtime, false);
    });

    test('!= 12', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('!= 13', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('!= 14', () {
      final Runtime runtime = getRuntime('main = set.new([]) != set.new([])');
      checkResult(runtime, false);
    });

    test('!= 15', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2, 3]) != set.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= 16', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) != set.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= 17', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([]) != stack.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= 18', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2, 3]) != stack.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= 19', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2]) != stack.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= 20', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([]) != queue.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= 21', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2, 3]) != queue.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= 22', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2]) != queue.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= 23', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) != vector.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= 24', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2, 3]) != vector.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= 25', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) != vector.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= 26', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") != file.fromPath(".")',
      );
      checkResult(runtime, false);
    });

    test('!= 27', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") != file.fromPath("..")',
      );
      checkResult(runtime, true);
    });

    test('!= 28', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") != directory.fromPath(".")',
      );
      checkResult(runtime, false);
    });

    test('!= 29', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") != directory.fromPath("..")',
      );
      checkResult(runtime, true);
    });

    test('> 1', () {
      final Runtime runtime = getRuntime('main = 10 > 4');
      checkResult(runtime, true);
    });

    test('> 2', () {
      final Runtime runtime = getRuntime('main = 4 > 10');
      checkResult(runtime, false);
    });

    test('> 3', () {
      final Runtime runtime = getRuntime('main = "Hello" > "Bye"');
      checkResult(runtime, true);
    });

    test('> 4', () {
      final Runtime runtime = getRuntime('main = "Bye" > "Hello"');
      checkResult(runtime, false);
    });

    test('> 5', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") > time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('> 6', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") > time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('< 1', () {
      final Runtime runtime = getRuntime('main = 10 < 4');
      checkResult(runtime, false);
    });

    test('< 2', () {
      final Runtime runtime = getRuntime('main = 4 < 10');
      checkResult(runtime, true);
    });

    test('< 3', () {
      final Runtime runtime = getRuntime('main = "Hello" < "Bye"');
      checkResult(runtime, false);
    });

    test('< 4', () {
      final Runtime runtime = getRuntime('main = "Bye" < "Hello"');
      checkResult(runtime, true);
    });

    test('< 5', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") < time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('< 6', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") < time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('>= 1', () {
      final Runtime runtime = getRuntime('main = 10 >= 10');
      checkResult(runtime, true);
    });

    test('>= 2', () {
      final Runtime runtime = getRuntime('main = 11 >= 10');
      checkResult(runtime, true);
    });

    test('>= 3', () {
      final Runtime runtime = getRuntime('main = 10 >= 11');
      checkResult(runtime, false);
    });

    test('>= 4', () {
      final Runtime runtime = getRuntime('main = "Hello" >= "Hello"');
      checkResult(runtime, true);
    });

    test('>= 5', () {
      final Runtime runtime = getRuntime('main = "See you" >= "Hello"');
      checkResult(runtime, true);
    });

    test('>= 6', () {
      final Runtime runtime = getRuntime('main = "Hello" >= "See you"');
      checkResult(runtime, false);
    });

    test('>= 7', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('>= 8', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") >= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('>= 9', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('<= 1', () {
      final Runtime runtime = getRuntime('main = 10 <= 10');
      checkResult(runtime, true);
    });

    test('<= 2', () {
      final Runtime runtime = getRuntime('main = 10 <= 11');
      checkResult(runtime, true);
    });

    test('<= 3', () {
      final Runtime runtime = getRuntime('main = 11 <= 10');
      checkResult(runtime, false);
    });

    test('<= 4', () {
      final Runtime runtime = getRuntime('main = "Hello" <= "Hello"');
      checkResult(runtime, true);
    });

    test('<= 5', () {
      final Runtime runtime = getRuntime('main = "Hello" <= "See you"');
      checkResult(runtime, true);
    });

    test('<= 6', () {
      final Runtime runtime = getRuntime('main = "See you" <= "Hello"');
      checkResult(runtime, false);
    });

    test('<= 7', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('<= 8', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('<= 9', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") <= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('+ 1', () {
      final Runtime runtime = getRuntime('main = 5 + 7');
      checkResult(runtime, 12);
    });

    test('+ 2', () {
      final Runtime runtime = getRuntime('main = 5 + -7');
      checkResult(runtime, -2);
    });

    test('+ 3', () {
      final Runtime runtime = getRuntime('main = "He" + "llo"');
      checkResult(runtime, '"Hello"');
    });

    test('+ 4', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) + vector.new([])',
      );
      checkResult(runtime, []);
    });

    test('+ 5', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) + vector.new([3, 4])',
      );
      checkResult(runtime, [4, 6]);
    });

    test('+ 6', () {
      final Runtime runtime = getRuntime('main = set.new([]) + 1');
      checkResult(runtime, {1});
    });

    test('+ 7', () {
      final Runtime runtime = getRuntime('main = 1 + set.new([])');
      checkResult(runtime, {1});
    });

    test('+ 8', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2]) + 3');
      checkResult(runtime, {1, 2, 3});
    });

    test('+ 9', () {
      final Runtime runtime = getRuntime('main = 3 + set.new([1, 2])');
      checkResult(runtime, {1, 2, 3});
    });

    test('+ 10', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2]) + 2');
      checkResult(runtime, {1, 2});
    });

    test('+ 11', () {
      final Runtime runtime = getRuntime('main = 2 + set.new([1, 2])');
      checkResult(runtime, {1, 2});
    });

    test('+ 12', () {
      final Runtime runtime = getRuntime('main = set.new([]) + set.new([])');
      checkResult(runtime, {});
    });

    test('+ 13', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) + set.new([3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('+ 14', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1]) + set.new([2, 3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('+ 15', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) + set.new([2, 3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('- 1', () {
      final Runtime runtime = getRuntime('main = 5 - 7');
      checkResult(runtime, -2);
    });

    test('- 2', () {
      final Runtime runtime = getRuntime('main = 5 - -7');
      checkResult(runtime, 12);
    });

    test('- 3', () {
      final Runtime runtime = getRuntime('main = -5');
      checkResult(runtime, -5);
    });

    test('- 4', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) - vector.new([])',
      );
      checkResult(runtime, []);
    });

    test('- 5', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) - vector.new([3, 4])',
      );
      checkResult(runtime, [-2, -2]);
    });

    test('*', () {
      final Runtime runtime = getRuntime('main = 5 * 7');
      checkResult(runtime, 35);
    });

    test('/', () {
      final Runtime runtime = getRuntime('main = 5 / 8');
      checkResult(runtime, 0.625);
    });

    test('% 1', () {
      final Runtime runtime = getRuntime('main = 7 % 5');
      checkResult(runtime, 2);
    });

    test('% 2', () {
      final Runtime runtime = getRuntime('main = 7 % 7');
      checkResult(runtime, 0);
    });

    test('% 3', () {
      final Runtime runtime = getRuntime('main = 5 % 7');
      checkResult(runtime, 5);
    });

    test('& 1', () {
      final Runtime runtime = getRuntime('main = true & true');
      checkResult(runtime, true);
    });

    test('& 2', () {
      final Runtime runtime = getRuntime('main = true & false');
      checkResult(runtime, false);
    });

    test('& 3', () {
      final Runtime runtime = getRuntime('main = false & true');
      checkResult(runtime, false);
    });

    test('& 4', () {
      final Runtime runtime = getRuntime('main = false & false');
      checkResult(runtime, false);
    });

    test('& 5', () {
      final Runtime runtime = getRuntime(
        'main = false & error.throw(-1, "Error")',
      );
      checkResult(runtime, false);
    });

    test('| 1', () {
      final Runtime runtime = getRuntime('main = true | true');
      checkResult(runtime, true);
    });

    test('| 2', () {
      final Runtime runtime = getRuntime('main = true | false');
      checkResult(runtime, true);
    });

    test('| 3', () {
      final Runtime runtime = getRuntime('main = false | true');
      checkResult(runtime, true);
    });

    test('| 4', () {
      final Runtime runtime = getRuntime('main = false | false');
      checkResult(runtime, false);
    });

    test('| 5', () {
      final Runtime runtime = getRuntime(
        'main = true | error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });

    test('! 1', () {
      final Runtime runtime = getRuntime('main = !false');
      checkResult(runtime, true);
    });

    test('! 2', () {
      final Runtime runtime = getRuntime('main = !true');
      checkResult(runtime, false);
    });
  });

  group('Operator Precedence', () {
    test('mul before add', () {
      final Runtime runtime = getRuntime('main = 2 + 3 * 4');
      checkResult(runtime, 14);
    });

    test('parentheses override precedence', () {
      final Runtime runtime = getRuntime('main = (2 + 3) * 4');
      checkResult(runtime, 20);
    });

    test('sub with mul', () {
      final Runtime runtime = getRuntime('main = 10 - 2 * 3');
      checkResult(runtime, 4);
    });

    test('add before equality', () {
      final Runtime runtime = getRuntime('main = 1 + 2 == 3');
      checkResult(runtime, true);
    });

    test('div before sub', () {
      final Runtime runtime = getRuntime('main = 10 - 6 / 3');
      checkResult(runtime, 8.0);
    });

    test('mod before add', () {
      final Runtime runtime = getRuntime('main = 1 + 7 % 3');
      checkResult(runtime, 2);
    });

    test('nested parentheses', () {
      final Runtime runtime = getRuntime('main = ((2 + 3) * (4 - 1))');
      checkResult(runtime, 15);
    });
  });

  group('Cross-Type Equality', () {
    test('number equals string throws', () {
      final Runtime runtime = getRuntime('main = 42 == "42"');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('boolean equals number throws', () {
      final Runtime runtime = getRuntime('main = true == 1');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list equals map throws', () {
      final Runtime runtime = getRuntime('main = [] == {}');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('number not-equals string throws', () {
      final Runtime runtime = getRuntime('main = 42 != "42"');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
