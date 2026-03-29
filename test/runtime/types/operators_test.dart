@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Operators', () {
    test('== returns true for equal strings', () {
      final Runtime runtime = getRuntime('main = "hey" == "hey"');
      checkResult(runtime, true);
    });

    test('== returns false for unequal strings', () {
      final Runtime runtime = getRuntime('main = "hey" == "heyo"');
      checkResult(runtime, false);
    });

    test('== returns true for equal numbers', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 1)');
      checkResult(runtime, true);
    });

    test('== returns false for unequal numbers', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 2)');
      checkResult(runtime, false);
    });

    test('== returns true for equal booleans', () {
      final Runtime runtime = getRuntime('main = true == (1 >= 1)');
      checkResult(runtime, true);
    });

    test('== returns false for unequal booleans', () {
      final Runtime runtime = getRuntime('main = true == (1 > 1)');
      checkResult(runtime, false);
    });

    test('== returns true for empty lists', () {
      final Runtime runtime = getRuntime('main = [] == []');
      checkResult(runtime, true);
    });

    test('== returns false for empty vs non-empty lists', () {
      final Runtime runtime = getRuntime('main = [] == [1, 2, 3]');
      checkResult(runtime, false);
    });

    test('== returns false for non-empty vs empty lists', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] == []');
      checkResult(runtime, false);
    });

    test('== returns true for equal lists', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] == [1, 2, 3]');
      checkResult(runtime, true);
    });

    test('== returns true for equal lists with expressions', () {
      final Runtime runtime = getRuntime(
        'main = [1, 2, 3] == [4 - 3, 1 + 1, 3 * 1]',
      );
      checkResult(runtime, true);
    });

    test('== returns true for empty maps', () {
      final Runtime runtime = getRuntime('main = {} == {}');
      checkResult(runtime, true);
    });

    test('== returns false for empty vs non-empty maps', () {
      final Runtime runtime = getRuntime('main = {} == {"a": 1}');
      checkResult(runtime, false);
    });

    test('== returns false for non-empty vs empty maps', () {
      final Runtime runtime = getRuntime('main = {"a": 1} == {}');
      checkResult(runtime, false);
    });

    test('== returns true for equal maps', () {
      final Runtime runtime = getRuntime(
        'main = {"a": 1, "b": 2, "c": 3} == {"a": 1, "b": 2, "c": 3}',
      );
      checkResult(runtime, true);
    });

    test('== returns true for equal maps with expressions', () {
      final Runtime runtime = getRuntime(
        'main = {"a": 1, "b": 2, "c": 3} == {"a": 3 - 2, "b": 1 + 1, "c": 3 * 1}',
      );
      checkResult(runtime, true);
    });

    test('== returns true for equal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('== returns true for empty sets', () {
      final Runtime runtime = getRuntime('main = set.new([]) == set.new([])');
      checkResult(runtime, true);
    });

    test('== returns true for equal sets', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2, 3]) == set.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal sets', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) == set.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== returns true for empty stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([]) == stack.new([])',
      );
      checkResult(runtime, true);
    });

    test('== returns true for equal stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2, 3]) == stack.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2]) == stack.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== returns true for empty queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([]) == queue.new([])',
      );
      checkResult(runtime, true);
    });

    test('== returns true for equal queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2, 3]) == queue.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2]) == queue.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== returns true for empty vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) == vector.new([])',
      );
      checkResult(runtime, true);
    });

    test('== returns true for equal vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2, 3]) == vector.new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) == vector.new([2])',
      );
      checkResult(runtime, false);
    });

    test('== returns true for equal files', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") == file.fromPath(".")',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal files', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") == file.fromPath("..")',
      );
      checkResult(runtime, false);
    });

    test('== returns true for equal directories', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") == directory.fromPath(".")',
      );
      checkResult(runtime, true);
    });

    test('== returns false for unequal directories', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") == directory.fromPath("..")',
      );
      checkResult(runtime, false);
    });

    test('!= returns false for equal strings', () {
      final Runtime runtime = getRuntime('main = "hey" != "hey"');
      checkResult(runtime, false);
    });

    test('!= returns true for unequal strings', () {
      final Runtime runtime = getRuntime('main = "hey" != "heyo"');
      checkResult(runtime, true);
    });

    test('!= returns false for equal numbers', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 1)');
      checkResult(runtime, false);
    });

    test('!= returns true for unequal numbers', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 2)');
      checkResult(runtime, true);
    });

    test('!= returns false for equal booleans', () {
      final Runtime runtime = getRuntime('main = true != (1 >= 1)');
      checkResult(runtime, false);
    });

    test('!= returns true for unequal booleans', () {
      final Runtime runtime = getRuntime('main = true != (1 > 1)');
      checkResult(runtime, true);
    });

    test('!= returns false for equal empty lists', () {
      final Runtime runtime = getRuntime('main = [] != []');
      checkResult(runtime, false);
    });

    test('!= returns true for empty vs non-empty lists', () {
      final Runtime runtime = getRuntime('main = [] != [1, 2, 3]');
      checkResult(runtime, true);
    });

    test('!= returns true for non-empty vs empty lists', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != []');
      checkResult(runtime, true);
    });

    test('!= returns true for unequal lists', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 4]');
      checkResult(runtime, true);
    });

    test('!= returns false for equal lists', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 3]');
      checkResult(runtime, false);
    });

    test('!= returns false for equal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for empty sets', () {
      final Runtime runtime = getRuntime('main = set.new([]) != set.new([])');
      checkResult(runtime, false);
    });

    test('!= returns false for equal sets', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2, 3]) != set.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal sets', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) != set.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for empty stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([]) != stack.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= returns false for equal stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2, 3]) != stack.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal stacks', () {
      final Runtime runtime = getRuntime(
        'main = stack.new([1, 2]) != stack.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for empty queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([]) != queue.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= returns false for equal queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2, 3]) != queue.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal queues', () {
      final Runtime runtime = getRuntime(
        'main = queue.new([1, 2]) != queue.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for empty vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) != vector.new([])',
      );
      checkResult(runtime, false);
    });

    test('!= returns false for equal vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2, 3]) != vector.new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) != vector.new([2])',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for equal files', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") != file.fromPath(".")',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal files', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(".") != file.fromPath("..")',
      );
      checkResult(runtime, true);
    });

    test('!= returns false for equal directories', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") != directory.fromPath(".")',
      );
      checkResult(runtime, false);
    });

    test('!= returns true for unequal directories', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath(".") != directory.fromPath("..")',
      );
      checkResult(runtime, true);
    });

    test('> returns true when left number is greater', () {
      final Runtime runtime = getRuntime('main = 10 > 4');
      checkResult(runtime, true);
    });

    test('> returns false when left number is smaller', () {
      final Runtime runtime = getRuntime('main = 4 > 10');
      checkResult(runtime, false);
    });

    test('> returns true when left string is greater', () {
      final Runtime runtime = getRuntime('main = "Hello" > "Bye"');
      checkResult(runtime, true);
    });

    test('> returns false when left string is smaller', () {
      final Runtime runtime = getRuntime('main = "Bye" > "Hello"');
      checkResult(runtime, false);
    });

    test('> returns false when left timestamp is earlier', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") > time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('> returns true when left timestamp is later', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") > time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('< returns false when left number is greater', () {
      final Runtime runtime = getRuntime('main = 10 < 4');
      checkResult(runtime, false);
    });

    test('< returns true when left number is smaller', () {
      final Runtime runtime = getRuntime('main = 4 < 10');
      checkResult(runtime, true);
    });

    test('< returns false when left string is greater', () {
      final Runtime runtime = getRuntime('main = "Hello" < "Bye"');
      checkResult(runtime, false);
    });

    test('< returns true when left string is smaller', () {
      final Runtime runtime = getRuntime('main = "Bye" < "Hello"');
      checkResult(runtime, true);
    });

    test('< returns true when left timestamp is earlier', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") < time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('< returns false when left timestamp is later', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") < time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('>= returns true for equal numbers', () {
      final Runtime runtime = getRuntime('main = 10 >= 10');
      checkResult(runtime, true);
    });

    test('>= returns true when left number is greater', () {
      final Runtime runtime = getRuntime('main = 11 >= 10');
      checkResult(runtime, true);
    });

    test('>= returns false when left number is smaller', () {
      final Runtime runtime = getRuntime('main = 10 >= 11');
      checkResult(runtime, false);
    });

    test('>= returns true for equal strings', () {
      final Runtime runtime = getRuntime('main = "Hello" >= "Hello"');
      checkResult(runtime, true);
    });

    test('>= returns true when left string is greater', () {
      final Runtime runtime = getRuntime('main = "See you" >= "Hello"');
      checkResult(runtime, true);
    });

    test('>= returns false when left string is smaller', () {
      final Runtime runtime = getRuntime('main = "Hello" >= "See you"');
      checkResult(runtime, false);
    });

    test('>= returns true for equal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('>= returns true when left timestamp is later', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") >= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('>= returns false when left timestamp is earlier', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('<= returns true for equal numbers', () {
      final Runtime runtime = getRuntime('main = 10 <= 10');
      checkResult(runtime, true);
    });

    test('<= returns true when left number is smaller', () {
      final Runtime runtime = getRuntime('main = 10 <= 11');
      checkResult(runtime, true);
    });

    test('<= returns false when left number is greater', () {
      final Runtime runtime = getRuntime('main = 11 <= 10');
      checkResult(runtime, false);
    });

    test('<= returns true for equal strings', () {
      final Runtime runtime = getRuntime('main = "Hello" <= "Hello"');
      checkResult(runtime, true);
    });

    test('<= returns true when left string is smaller', () {
      final Runtime runtime = getRuntime('main = "Hello" <= "See you"');
      checkResult(runtime, true);
    });

    test('<= returns false when left string is greater', () {
      final Runtime runtime = getRuntime('main = "See you" <= "Hello"');
      checkResult(runtime, false);
    });

    test('<= returns true for equal timestamps', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('<= returns true when left timestamp is earlier', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-02T00:00:00")',
      );
      checkResult(runtime, true);
    });

    test('<= returns false when left timestamp is later', () {
      final Runtime runtime = getRuntime(
        'main = time.fromIso("2024-09-02T00:00:00") <= time.fromIso("2024-09-01T00:00:00")',
      );
      checkResult(runtime, false);
    });

    test('+ adds two positive numbers', () {
      final Runtime runtime = getRuntime('main = 5 + 7');
      checkResult(runtime, 12);
    });

    test('+ adds positive and negative numbers', () {
      final Runtime runtime = getRuntime('main = 5 + -7');
      checkResult(runtime, -2);
    });

    test('+ concatenates two strings', () {
      final Runtime runtime = getRuntime('main = "He" + "llo"');
      checkResult(runtime, '"Hello"');
    });

    test('+ adds two empty vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) + vector.new([])',
      );
      checkResult(runtime, []);
    });

    test('+ adds two non-empty vectors element-wise', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) + vector.new([3, 4])',
      );
      checkResult(runtime, [4, 6]);
    });

    test('+ adds element to empty set from right', () {
      final Runtime runtime = getRuntime('main = set.new([]) + 1');
      checkResult(runtime, {1});
    });

    test('+ adds element to empty set from left', () {
      final Runtime runtime = getRuntime('main = 1 + set.new([])');
      checkResult(runtime, {1});
    });

    test('+ adds new element to non-empty set from right', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2]) + 3');
      checkResult(runtime, {1, 2, 3});
    });

    test('+ adds new element to non-empty set from left', () {
      final Runtime runtime = getRuntime('main = 3 + set.new([1, 2])');
      checkResult(runtime, {1, 2, 3});
    });

    test('+ adds duplicate element to set from right', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2]) + 2');
      checkResult(runtime, {1, 2});
    });

    test('+ adds duplicate element to set from left', () {
      final Runtime runtime = getRuntime('main = 2 + set.new([1, 2])');
      checkResult(runtime, {1, 2});
    });

    test('+ unions two empty sets', () {
      final Runtime runtime = getRuntime('main = set.new([]) + set.new([])');
      checkResult(runtime, {});
    });

    test('+ unions non-empty set with smaller set', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) + set.new([3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('+ unions smaller set with non-empty set', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1]) + set.new([2, 3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('+ unions two overlapping sets', () {
      final Runtime runtime = getRuntime(
        'main = set.new([1, 2]) + set.new([2, 3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('- subtracts larger from smaller number', () {
      final Runtime runtime = getRuntime('main = 5 - 7');
      checkResult(runtime, -2);
    });

    test('- subtracts negative number', () {
      final Runtime runtime = getRuntime('main = 5 - -7');
      checkResult(runtime, 12);
    });

    test('- negates a number', () {
      final Runtime runtime = getRuntime('main = -5');
      checkResult(runtime, -5);
    });

    test('- subtracts two empty vectors', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([]) - vector.new([])',
      );
      checkResult(runtime, []);
    });

    test('- subtracts two non-empty vectors element-wise', () {
      final Runtime runtime = getRuntime(
        'main = vector.new([1, 2]) - vector.new([3, 4])',
      );
      checkResult(runtime, [-2, -2]);
    });

    test('* multiplies two numbers', () {
      final Runtime runtime = getRuntime('main = 5 * 7');
      checkResult(runtime, 35);
    });

    test('/ divides two numbers', () {
      final Runtime runtime = getRuntime('main = 5 / 8');
      checkResult(runtime, 0.625);
    });

    test('% returns remainder when left is greater', () {
      final Runtime runtime = getRuntime('main = 7 % 5');
      checkResult(runtime, 2);
    });

    test('% returns zero when operands are equal', () {
      final Runtime runtime = getRuntime('main = 7 % 7');
      checkResult(runtime, 0);
    });

    test('% returns left when left is smaller', () {
      final Runtime runtime = getRuntime('main = 5 % 7');
      checkResult(runtime, 5);
    });

    test('& returns true when both are true', () {
      final Runtime runtime = getRuntime('main = true & true');
      checkResult(runtime, true);
    });

    test('& returns false when right is false', () {
      final Runtime runtime = getRuntime('main = true & false');
      checkResult(runtime, false);
    });

    test('& returns false when left is false', () {
      final Runtime runtime = getRuntime('main = false & true');
      checkResult(runtime, false);
    });

    test('& returns false when both are false', () {
      final Runtime runtime = getRuntime('main = false & false');
      checkResult(runtime, false);
    });

    test('& short-circuits on false left operand', () {
      final Runtime runtime = getRuntime(
        'main = false & error.throw(-1, "Error")',
      );
      checkResult(runtime, false);
    });

    test('| returns true when both are true', () {
      final Runtime runtime = getRuntime('main = true | true');
      checkResult(runtime, true);
    });

    test('| returns true when right is false', () {
      final Runtime runtime = getRuntime('main = true | false');
      checkResult(runtime, true);
    });

    test('| returns true when left is false', () {
      final Runtime runtime = getRuntime('main = false | true');
      checkResult(runtime, true);
    });

    test('| returns false when both are false', () {
      final Runtime runtime = getRuntime('main = false | false');
      checkResult(runtime, false);
    });

    test('| short-circuits on true left operand', () {
      final Runtime runtime = getRuntime(
        'main = true | error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });

    test('! negates false to true', () {
      final Runtime runtime = getRuntime('main = !false');
      checkResult(runtime, true);
    });

    test('! negates true to false', () {
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
