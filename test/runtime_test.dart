import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Control', () {
    test('if/else 1', () {
      final Runtime runtime = getRuntime('main = if (true) "yes" else "no"');
      checkResult(runtime, '"yes"');
    });

    test('if/else 2', () {
      final Runtime runtime = getRuntime('main = if (false) "yes" else "no"');
      checkResult(runtime, '"no"');
    });

    test('if/else 3', () {
      final Runtime runtime = getRuntime('main = if (true) 1 + 2 else 42');
      checkResult(runtime, 3);
    });
  });

  group('Try/Catch', () {
    test('try/catch 1', () {
      final Runtime runtime = getRuntime('main = try(1 / 2, 42)');
      checkResult(runtime, 0.5);
    });

    test('try/catch 2', () {
      final Runtime runtime =
          getRuntime('main = try(error.throw(0, "Does not compute"), 42)');
      checkResult(runtime, 42);
    });
  });

  group('Error', () {
    test('throw', () {
      try {
        final Runtime runtime =
            getRuntime('main = error.throw(-1, "Segmentation fault")');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<CustomError>());
      }
    });
  });

  group('Constants', () {
    test('Boolean', () {
      final Runtime runtime = getRuntime('main = true');
      checkResult(runtime, true);
    });

    test('Number', () {
      final Runtime runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('String', () {
      final Runtime runtime = getRuntime('main = "Hello"');
      checkResult(runtime, '"Hello"');
    });

    test('List', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });
  });

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
      final Runtime runtime =
          getRuntime('main = [1, 2, 3] == [4 - 3, 1 + 1, 3 * 1]');
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
          'main = {"a": 1, "b": 2, "c": 3} == {"a": 1, "b": 2, "c": 3}');
      checkResult(runtime, true);
    });

    test('== 16', () {
      final Runtime runtime = getRuntime(
          'main = {"a": 1, "b": 2, "c": 3} == {"a": 3 - 2, "b": 1 + 1, "c": 3 * 1}');
      checkResult(runtime, true);
    });

    test('== 17', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-01T00:00:00")');
      checkResult(runtime, true);
    });

    test('== 17', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") == time.fromIso("2024-09-02T00:00:00")');
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

    test('== 7', () {
      final Runtime runtime = getRuntime('main = [] != []');
      checkResult(runtime, false);
    });

    test('== 8', () {
      final Runtime runtime = getRuntime('main = [] != [1, 2, 3]');
      checkResult(runtime, true);
    });

    test('== 9', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != []');
      checkResult(runtime, true);
    });

    test('== 10', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 4]');
      checkResult(runtime, true);
    });

    test('== 11', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3] != [1, 2, 3]');
      checkResult(runtime, false);
    });

    test('== 12', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-01T00:00:00")');
      checkResult(runtime, false);
    });

    test('== 13', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") != time.fromIso("2024-09-02T00:00:00")');
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
          'main = time.fromIso("2024-09-01T00:00:00") > time.fromIso("2024-09-02T00:00:00")');
      checkResult(runtime, false);
    });

    test('> 6', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-02T00:00:00") > time.fromIso("2024-09-01T00:00:00")');
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
          'main = time.fromIso("2024-09-01T00:00:00") < time.fromIso("2024-09-02T00:00:00")');
      checkResult(runtime, true);
    });

    test('< 6', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-02T00:00:00") < time.fromIso("2024-09-01T00:00:00")');
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
          'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-01T00:00:00")');
      checkResult(runtime, true);
    });

    test('>= 8', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-02T00:00:00") >= time.fromIso("2024-09-01T00:00:00")');
      checkResult(runtime, true);
    });

    test('>= 9', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") >= time.fromIso("2024-09-02T00:00:00")');
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
          'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-01T00:00:00")');
      checkResult(runtime, true);
    });

    test('<= 8', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-01T00:00:00") <= time.fromIso("2024-09-02T00:00:00")');
      checkResult(runtime, true);
    });

    test('<= 9', () {
      final Runtime runtime = getRuntime(
          'main = time.fromIso("2024-09-02T00:00:00") <= time.fromIso("2024-09-01T00:00:00")');
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
      final Runtime runtime =
          getRuntime('main = vector.new([]) + vector.new([])');
      checkResult(runtime, []);
    });

    test('+ 5', () {
      final Runtime runtime =
          getRuntime('main = vector.new([1, 2]) + vector.new([3, 4])');
      checkResult(runtime, [4, 6]);
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
      final Runtime runtime =
          getRuntime('main = vector.new([]) - vector.new([])');
      checkResult(runtime, []);
    });

    test('- 5', () {
      final Runtime runtime =
          getRuntime('main = vector.new([1, 2]) - vector.new([3, 4])');
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

    test('! 1', () {
      final Runtime runtime = getRuntime('main = !false');
      checkResult(runtime, true);
    });

    test('! 2', () {
      final Runtime runtime = getRuntime('main = !true');
      checkResult(runtime, false);
    });
  });

  group('Comparison', () {
    test('comp.eq', () {
      final Runtime runtime = getRuntime('main = comp.eq("hey", "hey")');
      checkResult(runtime, true);
    });

    test('comp.neq', () {
      final Runtime runtime = getRuntime('main = comp.neq(7, 8)');
      checkResult(runtime, true);
    });

    test('comp.gt', () {
      final Runtime runtime = getRuntime('main = comp.gt(10, 4)');
      checkResult(runtime, true);
    });

    test('comp.lt', () {
      final Runtime runtime = getRuntime('main = comp.lt(10, 4)');
      checkResult(runtime, false);
    });

    test('comp.ge', () {
      final Runtime runtime = getRuntime('main = comp.ge(10, 10)');
      checkResult(runtime, true);
    });

    test('comp.le', () {
      final Runtime runtime = getRuntime('main = comp.le(10, 10)');
      checkResult(runtime, true);
    });
  });

  group('Arithmetic', () {
    test('num.abs 1', () {
      final Runtime runtime = getRuntime('main = num.abs(1)');
      checkResult(runtime, 1);
    });

    test('num.abs 2', () {
      final Runtime runtime = getRuntime('main = num.abs(-1)');
      checkResult(runtime, 1);
    });

    test('num.negative 1', () {
      final Runtime runtime = getRuntime('main = num.negative(5)');
      checkResult(runtime, -5);
    });

    test('num.negative 2', () {
      final Runtime runtime = getRuntime('main = num.negative(-5)');
      checkResult(runtime, -5);
    });

    test('num.inc 1', () {
      final Runtime runtime = getRuntime('main = num.inc(2)');
      checkResult(runtime, 3);
    });

    test('num.inc 2', () {
      final Runtime runtime = getRuntime('main = num.inc(-2)');
      checkResult(runtime, -1);
    });

    test('num.dec 1', () {
      final Runtime runtime = getRuntime('main = num.dec(0)');
      checkResult(runtime, -1);
    });

    test('num.dec 2', () {
      final Runtime runtime = getRuntime('main = num.dec(-2)');
      checkResult(runtime, -3);
    });

    test('num.add', () {
      final Runtime runtime = getRuntime('main = num.add(5, 7)');
      checkResult(runtime, 12);
    });

    test('num.sum', () {
      final Runtime runtime = getRuntime('main = num.sum(5, 7)');
      checkResult(runtime, 12);
    });

    test('num.sub', () {
      final Runtime runtime = getRuntime('main = num.sub(5, 7)');
      checkResult(runtime, -2);
    });

    test('num.mul', () {
      final Runtime runtime = getRuntime('main = num.mul(5, 7)');
      checkResult(runtime, 35);
    });

    test('num.div', () {
      final Runtime runtime = getRuntime('main = num.div(5, 8)');
      checkResult(runtime, 0.625);
    });

    test('num.mod', () {
      final Runtime runtime = getRuntime('main = num.mod(7, 5)');
      checkResult(runtime, 2);
    });

    test('num.min 1', () {
      final Runtime runtime = getRuntime('main = num.min(7, 5)');
      checkResult(runtime, 5);
    });

    test('num.min 2', () {
      final Runtime runtime = getRuntime('main = num.min(-7, -5)');
      checkResult(runtime, -7);
    });

    test('num.max', () {
      final Runtime runtime = getRuntime('main = num.max(7, 5)');
      checkResult(runtime, 7);
    });

    test('num.pow 1', () {
      final Runtime runtime = getRuntime('main = num.pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('num.pow 2', () {
      final Runtime runtime = getRuntime('main = num.pow(7, 0)');
      checkResult(runtime, 1);
    });

    test('num.pow 3', () {
      final Runtime runtime = getRuntime('main = num.pow(4, -1)');
      checkResult(runtime, 0.25);
    });

    test('num.sqrt 1', () {
      final Runtime runtime = getRuntime('main = num.sqrt(16)');
      checkResult(runtime, 4);
    });

    test('num.sqrt 2', () {
      final Runtime runtime = getRuntime('main = num.sqrt(0)');
      checkResult(runtime, 0);
    });

    test('num.round 1', () {
      final Runtime runtime = getRuntime('main = num.round(4.0)');
      checkResult(runtime, 4);
    });

    test('num.round 2', () {
      final Runtime runtime = getRuntime('main = num.round(4.4)');
      checkResult(runtime, 4);
    });

    test('num.round 3', () {
      final Runtime runtime = getRuntime('main = num.round(4.5)');
      checkResult(runtime, 5);
    });

    test('num.round 4', () {
      final Runtime runtime = getRuntime('main = num.round(4.6)');
      checkResult(runtime, 5);
    });

    test('num.floor 1', () {
      final Runtime runtime = getRuntime('main = num.floor(4.0)');
      checkResult(runtime, 4);
    });

    test('num.floor 2', () {
      final Runtime runtime = getRuntime('main = num.floor(4.4)');
      checkResult(runtime, 4);
    });

    test('num.floor 3', () {
      final Runtime runtime = getRuntime('main = num.floor(4.5)');
      checkResult(runtime, 4);
    });

    test('num.floor 4', () {
      final Runtime runtime = getRuntime('main = num.floor(4.6)');
      checkResult(runtime, 4);
    });

    test('num.ceil 1', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.0)');
      checkResult(runtime, 4);
    });

    test('num.ceil 2', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.4)');
      checkResult(runtime, 5);
    });

    test('num.ceil 3', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.5)');
      checkResult(runtime, 5);
    });

    test('num.ceil 4', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.6)');
      checkResult(runtime, 5);
    });

    test('num.sin', () {
      final Runtime runtime = getRuntime('main = num.sin(10)');
      checkResult(runtime, -0.5440211108893698);
    });

    test('num.cos', () {
      final Runtime runtime = getRuntime('main = num.cos(10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('num.tan', () {
      final Runtime runtime = getRuntime('main = num.tan(10)');
      checkResult(runtime, 0.6483608274590866);
    });

    test('num.log', () {
      final Runtime runtime = getRuntime('main = num.log(10)');
      checkResult(runtime, 2.302585092994046);
    });

    test('num.isNegative 1', () {
      final Runtime runtime = getRuntime('main = num.isNegative(5)');
      checkResult(runtime, false);
    });

    test('num.isNegative 2', () {
      final Runtime runtime = getRuntime('main = num.isNegative(-5)');
      checkResult(runtime, true);
    });

    test('num.isPositive 1', () {
      final Runtime runtime = getRuntime('main = num.isPositive(5)');
      checkResult(runtime, true);
    });

    test('num.isPositive 2', () {
      final Runtime runtime = getRuntime('main = num.isPositive(-5)');
      checkResult(runtime, false);
    });

    test('num.isZero 1', () {
      final Runtime runtime = getRuntime('main = num.isZero(0)');
      checkResult(runtime, true);
    });

    test('num.isZero 2', () {
      final Runtime runtime = getRuntime('main = num.isZero(0.1)');
      checkResult(runtime, false);
    });

    test('num.isEven 1', () {
      final Runtime runtime = getRuntime('main = num.isEven(6)');
      checkResult(runtime, true);
    });

    test('num.isEven 2', () {
      final Runtime runtime = getRuntime('main = num.isEven(7)');
      checkResult(runtime, false);
    });

    test('num.isOdd 1', () {
      final Runtime runtime = getRuntime('main = num.isOdd(6)');
      checkResult(runtime, false);
    });

    test('num.isOdd 2', () {
      final Runtime runtime = getRuntime('main = num.isOdd(7)');
      checkResult(runtime, true);
    });

    test('num.asRadians 1', () {
      final Runtime runtime = getRuntime('main = num.asRadians(0)');
      checkResult(runtime, 0.0);
    });

    test('num.asRadians 2', () {
      final Runtime runtime = getRuntime('main = num.asRadians(30)');
      expect(num.parse(runtime.executeMain()), closeTo(0.523598775598, 0.0001));
    });

    test('num.asRadians 3', () {
      final Runtime runtime = getRuntime('main = num.asRadians(180)');
      expect(num.parse(runtime.executeMain()), closeTo(3.141592653589, 0.0001));
    });

    test('num.asDegrees 1', () {
      final Runtime runtime = getRuntime('main = num.asDegrees(0)');
      checkResult(runtime, 0.0);
    });

    test('num.asDegrees 2', () {
      final Runtime runtime =
          getRuntime('main = num.asDegrees(0.52359877559829887307)');
      expect(num.parse(runtime.executeMain()), closeTo(30, 0.0001));
    });

    test('num.asDegrees 3', () {
      final Runtime runtime =
          getRuntime('main = num.asDegrees(3.141592653589793)');
      expect(num.parse(runtime.executeMain()), closeTo(180, 0.0001));
    });

    test('num.infinity 1', () {
      final Runtime runtime = getRuntime('main = num.infinity()');
      checkResult(runtime, double.infinity);
    });

    test('num.infinity 2', () {
      final Runtime runtime = getRuntime('main = is.infinite(num.infinity())');
      checkResult(runtime, true);
    });

    test('num.fraction 1', () {
      final Runtime runtime = getRuntime('main = num.fraction(1)');
      checkResult(runtime, 0);
    });

    test('num.fraction 2', () {
      final Runtime runtime = getRuntime('main = num.fraction(1.25)');
      checkResult(runtime, 0.25);
    });

    test('num.fraction 3', () {
      final Runtime runtime = getRuntime('main = num.fraction(-1.25)');
      checkResult(runtime, 0.25);
    });

    test('num.clamp 1', () {
      final Runtime runtime = getRuntime('main = num.clamp(0, 1, 2)');
      checkResult(runtime, 1);
    });

    test('num.clamp 2', () {
      final Runtime runtime = getRuntime('main = num.clamp(2, 1, 5)');
      checkResult(runtime, 2);
    });

    test('num.clamp 3', () {
      final Runtime runtime = getRuntime('main = num.clamp(6, 1, 5)');
      checkResult(runtime, 5);
    });

    test('num.sign 1', () {
      final Runtime runtime = getRuntime('main = num.sign(-2)');
      checkResult(runtime, -1);
    });

    test('num.sign 2', () {
      final Runtime runtime = getRuntime('main = num.sign(0)');
      checkResult(runtime, 0);
    });

    test('num.sign 3', () {
      final Runtime runtime = getRuntime('main = num.sign(2)');
      checkResult(runtime, 1);
    });

    test('num.integerRandom', () {
      final Runtime runtime = getRuntime('main = num.integerRandom(10, 20)');
      expect(num.parse(runtime.executeMain()), inInclusiveRange(10, 20));
    });

    test('num.decimalRandom', () {
      final Runtime runtime = getRuntime('main = num.decimalRandom()');
      expect(num.parse(runtime.executeMain()), inInclusiveRange(0, 1));
    });

    test('num.compare 1', () {
      final Runtime runtime = getRuntime('main = num.compare(3, 7)');
      checkResult(runtime, -1);
    });

    test('num.compare 2', () {
      final Runtime runtime = getRuntime('main = num.compare(7, 7)');
      checkResult(runtime, 0);
    });

    test('num.compare 3', () {
      final Runtime runtime = getRuntime('main = num.compare(7, 3)');
      checkResult(runtime, 1);
    });
  });

  group('Logic', () {
    test('bool.and 1', () {
      final Runtime runtime = getRuntime('main = bool.and(true, true)');
      checkResult(runtime, true);
    });

    test('bool.and 2', () {
      final Runtime runtime = getRuntime('main = bool.and(false, true)');
      checkResult(runtime, false);
    });

    test('bool.and 3', () {
      final Runtime runtime = getRuntime('main = bool.and(true, false)');
      checkResult(runtime, false);
    });

    test('bool.and 4', () {
      final Runtime runtime = getRuntime('main = bool.and(false, false)');
      checkResult(runtime, false);
    });

    test('bool.or 1', () {
      final Runtime runtime = getRuntime('main = bool.or(true, true)');
      checkResult(runtime, true);
    });

    test('bool.or 2', () {
      final Runtime runtime = getRuntime('main = bool.or(true, false)');
      checkResult(runtime, true);
    });

    test('bool.or 3', () {
      final Runtime runtime = getRuntime('main = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('bool.or 4', () {
      final Runtime runtime = getRuntime('main = bool.or(false, false)');
      checkResult(runtime, false);
    });

    test('bool.xor 1', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, true)');
      checkResult(runtime, false);
    });

    test('bool.xor 2', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, false)');
      checkResult(runtime, true);
    });

    test('bool.xor 3', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, true)');
      checkResult(runtime, true);
    });

    test('bool.xor 4', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, false)');
      checkResult(runtime, false);
    });

    test('bool.not 1', () {
      final Runtime runtime = getRuntime('main = bool.not(true)');
      checkResult(runtime, false);
    });

    test('bool.not 2', () {
      final Runtime runtime = getRuntime('main = bool.not(false)');
      checkResult(runtime, true);
    });
  });

  group('String', () {
    test('String indexing', () {
      final Runtime runtime = getRuntime('main = "Hello"[1]');
      checkResult(runtime, '"e"');
    });

    test('str.substring', () {
      final Runtime runtime = getRuntime('main = str.substring("hola", 1, 3)');
      checkResult(runtime, '"ol"');
    });

    test('str.startsWith 1', () {
      final Runtime runtime = getRuntime('main = str.startsWith("hola", "ho")');
      checkResult(runtime, true);
    });

    test('str.startsWith 2', () {
      final Runtime runtime =
          getRuntime('main = str.startsWith("hola", "hoy")');
      checkResult(runtime, false);
    });

    test('str.endsWith 1', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "la")');
      checkResult(runtime, true);
    });

    test('str.endsWith 2', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "lol")');
      checkResult(runtime, false);
    });

    test('str.replace 1', () {
      final Runtime runtime =
          getRuntime('main = str.replace("banana", "na", "to")');
      checkResult(runtime, '"batoto"');
    });

    test('str.replace 2', () {
      final Runtime runtime =
          getRuntime('main = str.replace("banana", "bon", "to")');
      checkResult(runtime, '"banana"');
    });

    test('str.uppercase', () {
      final Runtime runtime = getRuntime('main = str.uppercase("Primal")');
      checkResult(runtime, '"PRIMAL"');
    });

    test('str.lowercase', () {
      final Runtime runtime = getRuntime('main = str.lowercase("Primal")');
      checkResult(runtime, '"primal"');
    });

    test('str.trim', () {
      final Runtime runtime = getRuntime('main = str.trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('str.match', () {
      final Runtime runtime =
          getRuntime('main = str.match("identifier42", "[a-zA-Z]+[0-9]+")');
      checkResult(runtime, true);
    });

    test('str.length', () {
      final Runtime runtime = getRuntime('main = str.length("primal")');
      checkResult(runtime, 6);
    });

    test('str.concat', () {
      final Runtime runtime =
          getRuntime('main = str.concat("Hello", ", world!")');
      checkResult(runtime, '"Hello, world!"');
    });

    test('str.first', () {
      final Runtime runtime = getRuntime('main = str.first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('str.last', () {
      final Runtime runtime = getRuntime('main = str.last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('str.init', () {
      final Runtime runtime = getRuntime('main = str.init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('str.rest 1', () {
      final Runtime runtime = getRuntime('main = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.rest 2', () {
      final Runtime runtime = getRuntime('main = str.rest("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('str.at', () {
      final Runtime runtime = getRuntime('main = str.at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('str.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty 2', () {
      final Runtime runtime = getRuntime('main = str.isEmpty(" ")');
      checkResult(runtime, false);
    });

    test('str.isEmpty 3', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty 2', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty(" ")');
      checkResult(runtime, true);
    });

    test('str.isNotEmpty 3', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("Hello")');
      checkResult(runtime, true);
    });

    test('str.contains 1', () {
      final Runtime runtime = getRuntime('main = str.contains("Hello", "ell")');
      checkResult(runtime, true);
    });

    test('str.contains 2', () {
      final Runtime runtime =
          getRuntime('main = str.contains("Hello", "hell")');
      checkResult(runtime, false);
    });

    test('str.take 1', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.take 2', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop 1', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 0)');
      checkResult(runtime, '"Hello"');
    });

    test('str.drop 2', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str.removeAt', () {
      final Runtime runtime = getRuntime('main = str.removeAt("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.reverse', () {
      final Runtime runtime = getRuntime('main = str.reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('str.bytes', () {
      final Runtime runtime = getRuntime('main = str.bytes("Hello")');
      checkResult(runtime, [72, 101, 108, 108, 111]);
    });

    test('str.indexOf 1', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "x")');
      checkResult(runtime, -1);
    });

    test('str.indexOf 2', () {
      final Runtime runtime = getRuntime('main = str.indexOf("Hello", "l")');
      checkResult(runtime, 2);
    });

    test('str.padLeft 1', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 0, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft 2', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 5, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padLeft 2', () {
      final Runtime runtime = getRuntime('main = str.padLeft("12345", 8, "0")');
      checkResult(runtime, '"00012345"');
    });

    test('str.padRight 1', () {
      final Runtime runtime =
          getRuntime('main = str.padRight("12345", 0, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padRight 2', () {
      final Runtime runtime =
          getRuntime('main = str.padRight("12345", 5, "0")');
      checkResult(runtime, '"12345"');
    });

    test('str.padRight 2', () {
      final Runtime runtime =
          getRuntime('main = str.padRight("12345", 8, "0")');
      checkResult(runtime, '"12345000"');
    });

    test('str.split 1', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", "x")');
      checkResult(runtime, ['"aa,bb,cc"']);
    });

    test('str.split 2', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", "")');
      checkResult(
          runtime, ['"a"', '"a"', '","', '"b"', '"b"', '","', '"c"', '"c"']);
    });

    test('str.split 3', () {
      final Runtime runtime = getRuntime('main = str.split("aa,bb,cc", ",")');
      checkResult(runtime, ['"aa"', '"bb"', '"cc"']);
    });

    test('str.compare 1', () {
      final Runtime runtime =
          getRuntime('main = str.compare("hello", "mountain")');
      checkResult(runtime, -1);
    });

    test('str.compare 2', () {
      final Runtime runtime =
          getRuntime('main = str.compare("table", "table")');
      checkResult(runtime, 0);
    });

    test('str.compare 3', () {
      final Runtime runtime = getRuntime('main = str.compare("monkey", "cat")');
      checkResult(runtime, 1);
    });
  });

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
        [1]
      ]);
    });

    test('List constructor 4', () {
      final Runtime runtime = getRuntime('main = [1 + 2]');
      checkResult(runtime, [3]);
    });

    test('List constructor 5', () {
      final Runtime runtime = getRuntime('main = [[1 + 2]]');
      checkResult(runtime, [
        [3]
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
      final Runtime runtime =
          getRuntime('main = [[1, 2, 3], [4, 5, 6], [7, 8, 9]][1]');
      checkResult(runtime, [4, 5, 6]);
    });

    test('List indexing 3', () {
      final Runtime runtime =
          getRuntime('main = ([[1, 2, 3], [4, 5, 6], [7, 8, 9]][1])[0]');
      checkResult(runtime, 4);
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
      final Runtime runtime =
          getRuntime('main = list.set([1, 2, 3, 4, 5], 2, 42)');
      checkResult(runtime, [1, 2, 42, 3, 4, 5]);
    });

    test('list.join 1', () {
      final Runtime runtime =
          getRuntime('main = list.join(["Hello", "world!"], ", ")');
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
      final Runtime runtime =
          getRuntime('main = list.contains([1, 2 + 2, 3], 4)');
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
      final Runtime runtime =
          getRuntime('main = list.take([1, 2, 3, 4, 5], 0)');
      checkResult(runtime, []);
    });

    test('list.take 2', () {
      final Runtime runtime =
          getRuntime('main = list.take([1, 2, 3, 4, 5], 4)');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.drop 1', () {
      final Runtime runtime =
          getRuntime('main = list.drop([1, 2, 3, 4, 5], 0)');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.drop 2', () {
      final Runtime runtime =
          getRuntime('main = list.drop([1, 2, 3, 4, 5], 2)');
      checkResult(runtime, [3, 4, 5]);
    });

    test('list.remove 1', () {
      final Runtime runtime =
          getRuntime('main = list.remove([1, 2, 3, 4, 5], 0)');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.remove 2', () {
      final Runtime runtime =
          getRuntime('main = list.remove([1, 2, 3, 4, 5], 2)');
      checkResult(runtime, [1, 3, 4, 5]);
    });

    test('list.remove 3', () {
      final Runtime runtime =
          getRuntime('main = list.remove([1, 2, 2, 4, 5], 2)');
      checkResult(runtime, [1, 4, 5]);
    });

    test('list.removeAt', () {
      final Runtime runtime =
          getRuntime('main = list.removeAt([1, 2, 3, 4, 5], 2)');
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
      final Runtime runtime =
          getRuntime('main = list.swap([1, 2, 3, 4, 5], 1, 3)');
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list.sublist', () {
      final Runtime runtime =
          getRuntime('main = list.sublist([1, 2, 3, 4, 5], 1, 3)');
      checkResult(runtime, [2, 3]);
    });

    test('list.map 1 ', () {
      final Runtime runtime = getRuntime('main = list.map([], num.abs)');
      checkResult(runtime, []);
    });

    test('list.map 2', () {
      final Runtime runtime = getRuntime(
          'main = list.map([1, -2 - 6, 3 * -3, -4, num.negative(7)], num.abs)');
      checkResult(runtime, [1, 8, 9, 4, 7]);
    });

    test('list.filter 1', () {
      final Runtime runtime = getRuntime('main = list.filter([], num.isEven)');
      checkResult(runtime, []);
    });

    test('list.filter 2', () {
      final Runtime runtime = getRuntime(
          'main = list.filter([-3, -2, -1, 0, 1, 2, 3], num.isEven)');
      checkResult(runtime, [-2, 0, 2]);
    });

    test('list.filter 3', () {
      final Runtime runtime =
          getRuntime('main = list.filter([-3, -2, -1, 1, 2, 3], num.isZero)');
      checkResult(runtime, []);
    });

    test('list.reduce 1', () {
      final Runtime runtime = getRuntime('main = list.reduce([], 0, num.add)');
      checkResult(runtime, 0);
    });

    test('list.reduce 2', () {
      final Runtime runtime =
          getRuntime('main = list.reduce([1, 2, 3, 4, 5], 10, num.add)');
      checkResult(runtime, 25);
    });

    test('list.all 1', () {
      final Runtime runtime = getRuntime('main = list.all([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.all 2', () {
      final Runtime runtime =
          getRuntime('main = list.all([2, 4, 5], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.all 3', () {
      final Runtime runtime =
          getRuntime('main = list.all([2, 4, 6], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.none 1', () {
      final Runtime runtime = getRuntime('main = list.none([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.none 2', () {
      final Runtime runtime =
          getRuntime('main = list.none([1, 2, 3], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.none 3', () {
      final Runtime runtime =
          getRuntime('main = list.none([1, 3, 7], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.any 1', () {
      final Runtime runtime = getRuntime('main = list.any([], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.any 2', () {
      final Runtime runtime =
          getRuntime('main = list.any([1, 3, 5], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.none 3', () {
      final Runtime runtime =
          getRuntime('main = list.any([1, 2, 3], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.zip 1', () {
      final Runtime runtime = getRuntime('main = list.zip([], [], num.add)');
      checkResult(runtime, []);
    });

    test('list.zip 2', () {
      final Runtime runtime =
          getRuntime('main = list.zip([1, 3, 5], [2, 4], num.add)');
      checkResult(runtime, [3, 7, 5]);
    });

    test('list.zip 3', () {
      final Runtime runtime =
          getRuntime('main = list.zip([1, 3], [2, 4, 6], num.add)');
      checkResult(runtime, [3, 7, 6]);
    });

    test('list.zip 4', () {
      final Runtime runtime =
          getRuntime('main = list.zip([1, 3, 5], [2, 4, 6], num.add)');
      checkResult(runtime, [3, 7, 11]);
    });

    test('list.zip 5', () {
      final Runtime runtime =
          getRuntime('main = list.zip([1 + 1 + 1, 3, 5], [2, 4, 6], num.add)');
      checkResult(runtime, [5, 7, 11]);
    });

    test('list.sort 1', () {
      final Runtime runtime = getRuntime('main = list.sort([], num.compare)');
      checkResult(runtime, []);
    });

    test('list.sort 2', () {
      final Runtime runtime =
          getRuntime('main = list.sort([3, 1, 5, 2, 4], num.compare)');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.sort 3', () {
      final Runtime runtime = getRuntime(
          'main = list.sort(["Peter", "Alice", "John", "Bob", "Daniel"], str.compare)');
      checkResult(
          runtime, ['"Alice"', '"Bob"', '"Daniel"', '"John"', '"Peter"']);
    });
  });

  group('Vector', () {
    test('vector.new 1', () {
      final Runtime runtime = getRuntime('main = vector.new([])');
      checkResult(runtime, []);
    });

    test('vector.new 2', () {
      final Runtime runtime = getRuntime('main = vector.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('vector.magnitude 1', () {
      final Runtime runtime =
          getRuntime('main = vector.magnitude(vector.new([]))');
      checkResult(runtime, 0.0);
    });

    test('vector.magnitude 2', () {
      final Runtime runtime =
          getRuntime('main = vector.magnitude(vector.new([1, 2, 3]))');
      expect(
          num.parse(runtime.executeMain()), closeTo(3.7416573867739413, 0.001));
    });

    test('vector.normalize 1', () {
      final Runtime runtime =
          getRuntime('main = vector.normalize(vector.new([]))');
      checkResult(runtime, []);
    });

    test('vector.magnitude 2', () {
      final Runtime runtime =
          getRuntime('main = vector.normalize(vector.new([1, 2, 3]))');
      checkResult(runtime,
          [0.2672612419124244, 0.5345224838248488, 0.8017837257372732]);
    });

    test('vector.add 1', () {
      final Runtime runtime =
          getRuntime('main = vector.add(vector.new([]), vector.new([]))');
      checkResult(runtime, []);
    });

    test('vector.add 2', () {
      final Runtime runtime = getRuntime(
          'main = vector.add(vector.new([1, 2]), vector.new([3, 4]))');
      checkResult(runtime, [4, 6]);
    });

    test('vector.add 3', () {
      try {
        final Runtime runtime = getRuntime(
            'main = vector.add(vector.new([1, 2]), vector.new([4, 5, 6]))');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<IterablesWithDifferentLengthError>());
      }
    });

    test('vector.sub 1', () {
      final Runtime runtime =
          getRuntime('main = vector.sub(vector.new([]), vector.new([]))');
      checkResult(runtime, []);
    });

    test('vector.sub 2', () {
      final Runtime runtime = getRuntime(
          'main = vector.sub(vector.new([1, 2]), vector.new([3, 4]))');
      checkResult(runtime, [-2, -2]);
    });

    test('vector.sub 3', () {
      try {
        final Runtime runtime = getRuntime(
            'main = vector.sub(vector.new([1, 2]), vector.new([4, 5, 6]))');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<IterablesWithDifferentLengthError>());
      }
    });

    test('vector.angle 1', () {
      try {
        final Runtime runtime =
            getRuntime('main = vector.angle(vector.new([]), vector.new([]))');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<RuntimeError>());
      }
    });

    test('vector.angle 2', () {
      final Runtime runtime = getRuntime(
          'main = vector.angle(vector.new([1, 2]), vector.new([3, 4]))');
      expect(num.parse(runtime.executeMain()),
          closeTo(0.17985349979247847, 0.000001));
    });

    test('vector.angle 3', () {
      final Runtime runtime = getRuntime(
          'main = vector.angle(vector.new([3, 4, 0]), vector.new([4, 3, 0]))');
      expect(
          num.parse(runtime.executeMain()), closeTo(0.28379410920832, 0.0001));
    });
  });

  group('Set', () {
    test('set.new 1', () {
      final Runtime runtime = getRuntime('main = set.new([])');
      checkResult(runtime, []);
    });

    test('set.new 2', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('set.new 3', () {
      final Runtime runtime = getRuntime('main = set.new([1, 2, 1])');
      checkResult(runtime, [1, 2]);
    });
  });

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
        '"foo"': {'"bar"': 2}
      });
    });

    test('Map constructor 4', () {
      final Runtime runtime = getRuntime('main = {"foo": 1 + 2}');
      checkResult(runtime, {'"foo"': 3});
    });

    test('Map constructor 5', () {
      final Runtime runtime =
          getRuntime('main = {"name": "John", "age": 42, "married": true}');
      checkResult(
          runtime, {'"name"': '"John"', '"age"': 42, '"married"': true});
    });

    test('Map indexing 1', () {
      final Runtime runtime = getRuntime(
          'main = {"name": "John", "age": 42, "married": true}["age"]');
      checkResult(runtime, 42);
    });

    test('Map indexing 2', () {
      final Runtime runtime = getRuntime(
          'main = {"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"]');
      checkResult(runtime, [42, 99, 201]);
    });

    test('Map indexing 3', () {
      final Runtime runtime = getRuntime(
          'main = ({"name": "John", "numbers": [42, 99, 201], "married": true}["numbers"])[1]');
      checkResult(runtime, 99);
    });

    test('map.at 1', () {
      final Runtime runtime = getRuntime(
          'main = map.at({"name": "John", "age": 42, "married": true}, "age")');
      checkResult(runtime, 42);
    });

    test('map.at 2', () {
      final Runtime runtime = getRuntime(
          'main = map.at({"name": "John", "age": 42 + 1, "married": true}, "age")');
      checkResult(runtime, 43);
    });

    test('map.set 1', () {
      final Runtime runtime = getRuntime('main = map.set({}, "foo", 1)');
      checkResult(runtime, {'"foo"': 1});
    });

    test('map.set 2', () {
      final Runtime runtime = getRuntime(
          'main = map.set({"name": "John", "age": 42, "married": true}, "age", 30)');
      checkResult(
          runtime, {'"name"': '"John"', '"age"': 30, '"married"': true});
    });

    test('map.keys 1', () {
      final Runtime runtime = getRuntime('main = map.keys({})');
      checkResult(runtime, []);
    });

    test('map.keys 2', () {
      final Runtime runtime = getRuntime(
          'main = map.keys({"name": "John", "age": 42, "married": true, 3: 2})');
      checkResult(runtime, ['"name"', '"age"', '"married"', 3]);
    });

    test('map.values 1', () {
      final Runtime runtime = getRuntime('main = map.values({})');
      checkResult(runtime, []);
    });

    test('map.values 2', () {
      final Runtime runtime = getRuntime(
          'main = map.values({"name": "John", "age": 42, "married": true, 3: 2, "foo": [1, 2, 3]})');
      checkResult(runtime, [
        '"John"',
        42,
        true,
        2,
        [1, 2, 3]
      ]);
    });

    test('map.contains 1', () {
      final Runtime runtime = getRuntime('main = map.containsKey({}, "name")');
      checkResult(runtime, false);
    });

    test('map.contains 2', () {
      final Runtime runtime =
          getRuntime('main = map.containsKey({"name": "John"}, "name")');
      checkResult(runtime, true);
    });

    test('map.contains 3', () {
      final Runtime runtime =
          getRuntime('main = map.containsKey({("na" + "me"): "John"}, "name")');
      checkResult(runtime, true);
    });

    test('map.contains 4', () {
      final Runtime runtime =
          getRuntime('main = map.containsKey({"name": "John"}, "age")');
      checkResult(runtime, false);
    });

    test('map.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = map.isEmpty({})');
      checkResult(runtime, true);
    });

    test('map.isEmpty 2', () {
      final Runtime runtime =
          getRuntime('main = map.isEmpty({"name": "John"})');
      checkResult(runtime, false);
    });

    test('map.isNotEmpty 1', () {
      final Runtime runtime = getRuntime('main = map.isNotEmpty({})');
      checkResult(runtime, false);
    });

    test('map.isNotEmpty 2', () {
      final Runtime runtime =
          getRuntime('main = map.isNotEmpty({"name": "John"})');
      checkResult(runtime, true);
    });

    test('map.removeAt 1', () {
      final Runtime runtime = getRuntime(
          'main = map.removeAt({"name": "John", "age": 42, "married": true}, "age")');
      checkResult(runtime, {'"name"': '"John"', '"married"': true});
    });

    test('map.removeAt 2', () {
      final Runtime runtime = getRuntime(
          'main = map.removeAt({"name": "John", "age": 42, "married": true}, "foo")');
      checkResult(
          runtime, {'"name"': '"John"', '"age"': 42, '"married"': true});
    });

    test('map.length 1', () {
      final Runtime runtime = getRuntime('main = map.length({})');
      checkResult(runtime, 0);
    });

    test('map.length 2', () {
      final Runtime runtime = getRuntime(
          'main = map.length({"name": "John", "age": 42, "married": true})');
      checkResult(runtime, 3);
    });
  });

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
      try {
        final Runtime runtime = getRuntime('main = to.number(true)');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidArgumentTypesError>());
      }
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
      try {
        final Runtime runtime = getRuntime('main = to.integer(true)');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidArgumentTypesError>());
      }
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
      try {
        final Runtime runtime = getRuntime('main = to.decimal(true)');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidArgumentTypesError>());
      }
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
      final Runtime runtime =
          getRuntime('main = is.number(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.number 8', () {
      final Runtime runtime =
          getRuntime('main = is.number(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.string(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.string 7', () {
      final Runtime runtime =
          getRuntime('main = is.string(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.boolean(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.boolean 7', () {
      final Runtime runtime =
          getRuntime('main = is.boolean(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.list(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.list 8', () {
      final Runtime runtime = getRuntime('main = is.list(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.map(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.map 8', () {
      final Runtime runtime = getRuntime('main = is.map(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.vector(vector.new([1, 2, 3]))');
      checkResult(runtime, true);
    });

    test('is.vector 8', () {
      final Runtime runtime =
          getRuntime('main = is.vector(set.new([1, 2, 3]))');
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
      final Runtime runtime =
          getRuntime('main = is.set(vector.new([1, 2, 3]))');
      checkResult(runtime, false);
    });

    test('is.set 8', () {
      final Runtime runtime = getRuntime('main = is.set(set.new([1, 2, 3]))');
      checkResult(runtime, true);
    });
  });

  group('Samples', () {
    test('factorial', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/factorial.prm'));
      checkResult(runtime, 120);
    });

    test('fibonacci', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/fibonacci.prm'));
      checkResult(runtime, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
    });

    test('is_palindrome', () {
      final Runtime runtime =
          getRuntime(loadFile('web_samples/is_palindrome.prm'));
      checkResult(runtime, true);
    });

    test('is_prime', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/is_prime.prm'));
      checkResult(runtime, true);
    });

    test('power', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/power.prm'));
      checkResult(runtime, 1024);
    });

    test('sum_of_digits', () {
      final Runtime runtime =
          getRuntime(loadFile('web_samples/sum_of_digits.prm'));
      checkResult(runtime, 45);
    });

    test('to_binary', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/to_binary.prm'));
      checkResult(runtime, '"1010"');
    });

    test('frequency', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/frequency.prm'));
      checkResult(runtime, {1: 2, 2: 4, 3: 1, 4: 1, 5: 2});
    });
  });

  group('Higher order functions', () {
    test('Function as parameter', () {
      final Runtime runtime =
          getRuntime('foo(f, v) = f(v)\n\nmain = foo(num.abs, -4)');
      checkResult(runtime, 4);
    });

    test('Function as result 1', () {
      final Runtime runtime =
          getRuntime('bar = num.abs\n\nfoo(v) = bar()(v)\n\nmain = foo(-4)');
      checkResult(runtime, 4);
    });

    test('Function as result 2', () {
      final Runtime runtime = getRuntime(
          'bar = num.abs\n\nfoo(f, v) = f(v)\n\nmain = foo(bar(), -4)');
      checkResult(runtime, 4);
    });

    test('Print function 1', () {
      final Runtime runtime = getRuntime('main = num.add');
      checkResult(runtime, '"num.add(a: Number, b: Number)"');
    });

    test('Print function 2', () {
      final Runtime runtime = getRuntime('foo(a, b) = a + b\n\nmain = foo');
      checkResult(runtime, '"foo(a: Any, b: Any)"');
    });

    test('Print function 3', () {
      final Runtime runtime = getRuntime('main = [num.add, num.abs]');
      checkResult(
          runtime, '["num.add(a: Number, b: Number)", "num.abs(a: Number)"]');
    });
  });

  group('Console', () {
    test('console.write', () {
      final Runtime runtime =
          getRuntime('main = console.write("Enter in function")');
      checkResult(runtime, '"Enter in function"');
    });

    test('console.writeLn', () {
      final Runtime runtime =
          getRuntime('main = console.writeLn("Enter in function")');
      checkResult(runtime, '"Enter in function"');
    });
  });

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
      final Runtime runtime =
          getRuntime("main = json.decode('[1, \"Hello\", true]')");
      checkResult(runtime, [1, '"Hello"', true]);
    });

    test('json.decode 4', () {
      final Runtime runtime = getRuntime(
          "main = json.decode('{\"name\": \"John\", \"age\": 42, \"married\": true, \"numbers\": [1, 2, 3]}')");
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
        '"numbers"': [1, 2, 3]
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
      final Runtime runtime =
          getRuntime('main = json.encode([1, "Hello", true])');
      checkResult(runtime, '"[1,"Hello",true]"');
    });

    test('json.encode 4', () {
      final Runtime runtime = getRuntime('main = json.encode([1, 2, [3, 4]])');
      checkResult(runtime, '"[1,2,[3,4]]"');
    });

    test('json.encode 4', () {
      final Runtime runtime = getRuntime('main = json.encode({})');
      checkResult(runtime, '"{}"');
    });

    test('json.encode 5', () {
      final Runtime runtime = getRuntime(
          'main = json.encode({"name": "John", "age": 42, "married": true, "numbers": [1, 2, 3]})');
      checkResult(runtime,
          '"{"name":"John","age":42,"married":true,"numbers":[1,2,3]}"');
    });
  });

  group('Hash', () {
    test('hash.md5 1', () {
      final Runtime runtime = getRuntime('main = hash.md5("")');
      checkResult(runtime, '"d41d8cd98f00b204e9800998ecf8427e"');
    });

    test('hash.md5 2', () {
      final Runtime runtime = getRuntime('main = hash.md5("Hello")');
      checkResult(runtime, '"8b1a9953c4611296a827abf8c47804d7"');
    });

    test('hash.sha1 1', () {
      final Runtime runtime = getRuntime('main = hash.sha1("")');
      checkResult(runtime, '"da39a3ee5e6b4b0d3255bfef95601890afd80709"');
    });

    test('hash.sha1 2', () {
      final Runtime runtime = getRuntime('main = hash.sha1("Hello")');
      checkResult(runtime, '"f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"');
    });

    test('hash.sha256 1', () {
      final Runtime runtime = getRuntime('main = hash.sha256("")');
      checkResult(runtime,
          '"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"');
    });

    test('hash.sha256 2', () {
      final Runtime runtime = getRuntime('main = hash.sha256("Hello")');
      checkResult(runtime,
          '"185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"');
    });

    test('hash.sha512 1', () {
      final Runtime runtime = getRuntime('main = hash.sha512("")');
      checkResult(runtime,
          '"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"');
    });

    test('hash.sha512 2', () {
      final Runtime runtime = getRuntime('main = hash.sha512("Hello")');
      checkResult(runtime,
          '"3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315"');
    });
  });

  group('Timestamp', () {
    test('time.now', () {
      final Runtime runtime = getRuntime('main = time.now()');
      checkDates(runtime, DateTime.now());
    });

    test('time.toIso', () {
      final Runtime runtime = getRuntime('main = time.toIso(time.now())');
      checkDates(runtime, DateTime.now());
    });

    test('time.fromIso', () {
      final DateTime now = DateTime.now();
      final Runtime runtime =
          getRuntime('main = time.fromIso("${now.toIso8601String()}")');
      checkDates(runtime, now);
    });

    test('time.year', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.year(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.year, 0));
    });

    test('time.month', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.month(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.month, 0));
    });

    test('time.day', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.day(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.day, 0));
    });

    test('time.hour', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.hour(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.hour, 0));
    });

    test('time.minute', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.minute(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.minute, 0));
    });

    test('time.second', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.second(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 1));
    });

    test('time.millisecond', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.millisecond(time.now())');
      expect(num.parse(runtime.executeMain()), closeTo(now.second, 999));
    });

    test('time.epoch', () {
      final DateTime now = DateTime.now();
      final Runtime runtime = getRuntime('main = time.epoch(time.now())');
      expect(num.parse(runtime.executeMain()),
          closeTo(now.millisecondsSinceEpoch, 500));
    });

    test('time.compare 1', () {
      final Runtime runtime = getRuntime(
          'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-02T00:00:00"))');
      checkResult(runtime, -1);
    });

    test('time.compare 2', () {
      final Runtime runtime = getRuntime(
          'main = time.compare(time.fromIso("2024-09-01T00:00:00"), time.fromIso("2024-09-01T00:00:00"))');
      checkResult(runtime, 0);
    });

    test('time.compare 3', () {
      final Runtime runtime = getRuntime(
          'main = time.compare(time.fromIso("2024-09-02T00:00:00"), time.fromIso("2024-09-01T00:00:00"))');
      checkResult(runtime, 1);
    });
  });

  group('Environment', () {
    test('env.get 1', () {
      final Runtime runtime = getRuntime('main = env.get("INVALID_VARIABLE")');
      checkResult(runtime, '""');
    });

    test('env.get 2', () {
      final String username = Platform.environment['USERNAME'] ?? '';
      final Runtime runtime = getRuntime('main = env.get("USERNAME")');
      checkResult(runtime, '"$username"');
    });
  });
}
