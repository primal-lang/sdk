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
      final Runtime runtime = getRuntime('main = if true 1 + 2 else 42');
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

  group('Debug', () {
    test('debug', () {
      final Runtime runtime = getRuntime('main = debug("Enter in function")');
      checkResult(runtime, '"Enter in function"');
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

    test('> 1', () {
      final Runtime runtime = getRuntime('main = 10 > 4');
      checkResult(runtime, true);
    });

    test('> 2', () {
      final Runtime runtime = getRuntime('main = 4 > 10');
      checkResult(runtime, false);
    });

    test('< 1', () {
      final Runtime runtime = getRuntime('main = 10 < 4');
      checkResult(runtime, false);
    });

    test('< 2', () {
      final Runtime runtime = getRuntime('main = 4 < 10');
      checkResult(runtime, true);
    });

    test('>= 1', () {
      final Runtime runtime = getRuntime('main = 10 >= 10');
      checkResult(runtime, true);
    });

    test('>= 2', () {
      final Runtime runtime = getRuntime('main = 10 >= 11');
      checkResult(runtime, false);
    });

    test('<= 1', () {
      final Runtime runtime = getRuntime('main = 10 <= 10');
      checkResult(runtime, true);
    });

    test('<= 2', () {
      final Runtime runtime = getRuntime('main = 11 <= 10');
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

    test('str.tail', () {
      final Runtime runtime = getRuntime('main = str.tail("Hello")');
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

    test('list.get 1', () {
      final Runtime runtime = getRuntime('main = list.get([0, 1, 2], 1)');
      checkResult(runtime, 1);
    });

    test('list.get 2', () {
      final Runtime runtime = getRuntime('main = list.get([0, 2 + 3, 4], 1)');
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

    test('list.tail', () {
      final Runtime runtime = getRuntime('main = list.tail([1, 2, 3, 4, 5])');
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
      final Runtime runtime = getRuntime('main = is.number(12.5)');
      checkResult(runtime, true);
    });

    test('is.number 2', () {
      final Runtime runtime = getRuntime('main = is.number("12.5")');
      checkResult(runtime, false);
    });

    test('is.number 3', () {
      final Runtime runtime = getRuntime('main = is.number(true)');
      checkResult(runtime, false);
    });

    test('is.number 4', () {
      final Runtime runtime = getRuntime('main = is.number([1, 2, 3])');
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
  });

  group('Samples', () {
    test('factorial', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/factorial.prm'));
      checkResult(runtime, 120);
    });

    test('fibonacci', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/fibonacci.prm'));
      checkResult(runtime, 55);
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
  });
}
