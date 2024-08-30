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
    test('==', () {
      final Runtime runtime = getRuntime('main = "hey" == "hey"');
      checkResult(runtime, true);
    });

    test('==', () {
      final Runtime runtime = getRuntime('main = "hey" == "heyo"');
      checkResult(runtime, false);
    });

    test('==', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 1)');
      checkResult(runtime, true);
    });

    test('==', () {
      final Runtime runtime = getRuntime('main = 42 == (41 + 2)');
      checkResult(runtime, false);
    });

    test('==', () {
      final Runtime runtime = getRuntime('main = true == (1 >= 1)');
      checkResult(runtime, true);
    });

    test('==', () {
      final Runtime runtime = getRuntime('main = true == (1 > 1)');
      checkResult(runtime, false);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = "hey" != "hey"');
      checkResult(runtime, false);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = "hey" != "heyo"');
      checkResult(runtime, true);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 1)');
      checkResult(runtime, false);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = 42 != (41 + 2)');
      checkResult(runtime, true);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = true != (1 >= 1)');
      checkResult(runtime, false);
    });

    test('!=', () {
      final Runtime runtime = getRuntime('main = true != (1 > 1)');
      checkResult(runtime, true);
    });

    test('>', () {
      final Runtime runtime = getRuntime('main = 10 > 4');
      checkResult(runtime, true);
    });

    test('>', () {
      final Runtime runtime = getRuntime('main = 4 > 10');
      checkResult(runtime, false);
    });

    test('<', () {
      final Runtime runtime = getRuntime('main = 10 < 4');
      checkResult(runtime, false);
    });

    test('<', () {
      final Runtime runtime = getRuntime('main = 4 < 10');
      checkResult(runtime, true);
    });

    test('>=', () {
      final Runtime runtime = getRuntime('main = 10 >= 10');
      checkResult(runtime, true);
    });

    test('>=', () {
      final Runtime runtime = getRuntime('main = 10 >= 11');
      checkResult(runtime, false);
    });

    test('<=', () {
      final Runtime runtime = getRuntime('main = 10 <= 10');
      checkResult(runtime, true);
    });

    test('<=', () {
      final Runtime runtime = getRuntime('main = 11 <= 10');
      checkResult(runtime, false);
    });

    test('+', () {
      final Runtime runtime = getRuntime('main = 5 + 7');
      checkResult(runtime, 12);
    });

    test('+', () {
      final Runtime runtime = getRuntime('main = 5 + -7');
      checkResult(runtime, -2);
    });

    test('+', () {
      final Runtime runtime = getRuntime('main = "He" + "llo"');
      checkResult(runtime, '"Hello"');
    });

    test('-', () {
      final Runtime runtime = getRuntime('main = 5 - 7');
      checkResult(runtime, -2);
    });

    test('-', () {
      final Runtime runtime = getRuntime('main = 5 - -7');
      checkResult(runtime, 12);
    });

    test('-', () {
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

    test('%', () {
      final Runtime runtime = getRuntime('main = 7 % 5');
      checkResult(runtime, 2);
    });

    test('%', () {
      final Runtime runtime = getRuntime('main = 7 % 7');
      checkResult(runtime, 0);
    });

    test('%', () {
      final Runtime runtime = getRuntime('main = 5 % 7');
      checkResult(runtime, 5);
    });

    test('&', () {
      final Runtime runtime = getRuntime('main = true & true');
      checkResult(runtime, true);
    });

    test('&', () {
      final Runtime runtime = getRuntime('main = true & false');
      checkResult(runtime, false);
    });

    test('&', () {
      final Runtime runtime = getRuntime('main = false & true');
      checkResult(runtime, false);
    });

    test('&', () {
      final Runtime runtime = getRuntime('main = false & false');
      checkResult(runtime, false);
    });

    test('|', () {
      final Runtime runtime = getRuntime('main = true | true');
      checkResult(runtime, true);
    });

    test('|', () {
      final Runtime runtime = getRuntime('main = true | false');
      checkResult(runtime, true);
    });

    test('|', () {
      final Runtime runtime = getRuntime('main = false | true');
      checkResult(runtime, true);
    });

    test('|', () {
      final Runtime runtime = getRuntime('main = false | false');
      checkResult(runtime, false);
    });

    test('!', () {
      final Runtime runtime = getRuntime('main = !false');
      checkResult(runtime, true);
    });

    test('!', () {
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
    test('num.abs', () {
      final Runtime runtime = getRuntime('main = num.abs(1)');
      checkResult(runtime, 1);
    });

    test('num.abs', () {
      final Runtime runtime = getRuntime('main = num.abs(-1)');
      checkResult(runtime, 1);
    });

    test('num.negative', () {
      final Runtime runtime = getRuntime('main = num.negative(5)');
      checkResult(runtime, -5);
    });

    test('num.negative', () {
      final Runtime runtime = getRuntime('main = num.negative(-5)');
      checkResult(runtime, -5);
    });

    test('num.inc', () {
      final Runtime runtime = getRuntime('main = num.inc(2)');
      checkResult(runtime, 3);
    });

    test('num.inc', () {
      final Runtime runtime = getRuntime('main = num.inc(-2)');
      checkResult(runtime, -1);
    });

    test('num.dec', () {
      final Runtime runtime = getRuntime('main = num.dec(0)');
      checkResult(runtime, -1);
    });

    test('num.dec', () {
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

    test('num.min', () {
      final Runtime runtime = getRuntime('main = num.min(7, 5)');
      checkResult(runtime, 5);
    });

    test('num.min', () {
      final Runtime runtime = getRuntime('main = num.min(-7, -5)');
      checkResult(runtime, -7);
    });

    test('num.max', () {
      final Runtime runtime = getRuntime('main = num.max(7, 5)');
      checkResult(runtime, 7);
    });

    test('num.pow', () {
      final Runtime runtime = getRuntime('main = num.pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('num.pow', () {
      final Runtime runtime = getRuntime('main = num.pow(7, 0)');
      checkResult(runtime, 1);
    });

    test('num.pow', () {
      final Runtime runtime = getRuntime('main = num.pow(4, -1)');
      checkResult(runtime, 0.25);
    });

    test('num.sqrt', () {
      final Runtime runtime = getRuntime('main = num.sqrt(16)');
      checkResult(runtime, 4);
    });

    test('num.sqrt', () {
      final Runtime runtime = getRuntime('main = num.sqrt(0)');
      checkResult(runtime, 0);
    });

    test('num.round', () {
      final Runtime runtime = getRuntime('main = num.round(4.0)');
      checkResult(runtime, 4);
    });

    test('num.round', () {
      final Runtime runtime = getRuntime('main = num.round(4.4)');
      checkResult(runtime, 4);
    });

    test('num.round', () {
      final Runtime runtime = getRuntime('main = num.round(4.5)');
      checkResult(runtime, 5);
    });

    test('num.round', () {
      final Runtime runtime = getRuntime('main = num.round(4.6)');
      checkResult(runtime, 5);
    });

    test('num.floor', () {
      final Runtime runtime = getRuntime('main = num.floor(4.0)');
      checkResult(runtime, 4);
    });

    test('num.floor', () {
      final Runtime runtime = getRuntime('main = num.floor(4.4)');
      checkResult(runtime, 4);
    });

    test('num.floor', () {
      final Runtime runtime = getRuntime('main = num.floor(4.5)');
      checkResult(runtime, 4);
    });

    test('num.floor', () {
      final Runtime runtime = getRuntime('main = num.floor(4.6)');
      checkResult(runtime, 4);
    });

    test('num.ceil', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.0)');
      checkResult(runtime, 4);
    });

    test('num.ceil', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.4)');
      checkResult(runtime, 5);
    });

    test('num.ceil', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.5)');
      checkResult(runtime, 5);
    });

    test('num.ceil', () {
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

    test('num.isNegative', () {
      final Runtime runtime = getRuntime('main = num.isNegative(5)');
      checkResult(runtime, false);
    });

    test('num.isNegative', () {
      final Runtime runtime = getRuntime('main = num.isNegative(-5)');
      checkResult(runtime, true);
    });

    test('num.isPositive', () {
      final Runtime runtime = getRuntime('main = num.isPositive(5)');
      checkResult(runtime, true);
    });

    test('num.isPositive', () {
      final Runtime runtime = getRuntime('main = num.isPositive(-5)');
      checkResult(runtime, false);
    });

    test('num.isZero', () {
      final Runtime runtime = getRuntime('main = num.isZero(0)');
      checkResult(runtime, true);
    });

    test('num.isZero', () {
      final Runtime runtime = getRuntime('main = num.isZero(0.1)');
      checkResult(runtime, false);
    });

    test('num.isEven', () {
      final Runtime runtime = getRuntime('main = num.isEven(6)');
      checkResult(runtime, true);
    });

    test('num.isEven', () {
      final Runtime runtime = getRuntime('main = num.isEven(7)');
      checkResult(runtime, false);
    });

    test('num.isOdd', () {
      final Runtime runtime = getRuntime('main = num.isOdd(6)');
      checkResult(runtime, false);
    });

    test('num.isOdd', () {
      final Runtime runtime = getRuntime('main = num.isOdd(7)');
      checkResult(runtime, true);
    });
  });

  group('Logic', () {
    test('bool.and', () {
      final Runtime runtime = getRuntime('main = bool.and(true, true)');
      checkResult(runtime, true);
    });

    test('bool.and', () {
      final Runtime runtime = getRuntime('main = bool.and(false, true)');
      checkResult(runtime, false);
    });
    
    test('bool.and', () {
      final Runtime runtime = getRuntime('main = bool.and(true, false)');
      checkResult(runtime, false);
    });
    
    test('bool.and', () {
      final Runtime runtime = getRuntime('main = bool.and(false, false)');
      checkResult(runtime, false);
    });

    test('bool.or', () {
      final Runtime runtime = getRuntime('main = bool.or(true, true)');
      checkResult(runtime, true);
    });

    test('bool.or', () {
      final Runtime runtime = getRuntime('main = bool.or(true, false)');
      checkResult(runtime, true);
    });

    test('bool.or', () {
      final Runtime runtime = getRuntime('main = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('bool.or', () {
      final Runtime runtime = getRuntime('main = bool.or(false, false)');
      checkResult(runtime, false);
    });

    test('bool.xor', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, true)');
      checkResult(runtime, false);
    });

    test('bool.xor', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, false)');
      checkResult(runtime, true);
    });

    test('bool.xor', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, true)');
      checkResult(runtime, true);
    });

    test('bool.xor', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, false)');
      checkResult(runtime, false);
    });

    test('bool.not', () {
      final Runtime runtime = getRuntime('main = bool.not(true)');
      checkResult(runtime, false);
    });

    test('bool.not', () {
      final Runtime runtime = getRuntime('main = bool.not(false)');
      checkResult(runtime, true);
    });
  });

  group('Strings', () {
    test('str.substring', () {
      final Runtime runtime = getRuntime('main = str.substring("hola", 1, 3)');
      checkResult(runtime, '"ol"');
    });

    test('str.startsWith', () {
      final Runtime runtime = getRuntime('main = str.startsWith("hola", "ho")');
      checkResult(runtime, true);
    });

    test('str.endsWith', () {
      final Runtime runtime = getRuntime('main = str.endsWith("hola", "la")');
      checkResult(runtime, true);
    });

    test('str.replace', () {
      final Runtime runtime =
          getRuntime('main = str.replace("banana", "na", "to")');
      checkResult(runtime, '"batoto"');
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

    test('str.isEmpty', () {
      final Runtime runtime = getRuntime('main = str.isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty', () {
      final Runtime runtime = getRuntime('main = str.isNotEmpty("Hello")');
      checkResult(runtime, true);
    });

    test('str.contains', () {
      final Runtime runtime = getRuntime('main = str.contains("Hello", "ell")');
      checkResult(runtime, true);
    });

    test('str.take', () {
      final Runtime runtime = getRuntime('main = str.take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.drop', () {
      final Runtime runtime = getRuntime('main = str.drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('str.remove', () {
      final Runtime runtime = getRuntime('main = str.remove("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('str.reverse', () {
      final Runtime runtime = getRuntime('main = str.reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });
  });

  group('To', () {
    test('to.number', () {
      final Runtime runtime = getRuntime('main = to.number("12.5")');
      checkResult(runtime, 12.5);
    });

    test('to.integer', () {
      final Runtime runtime = getRuntime('main = to.integer("12")');
      checkResult(runtime, 12);
    });

    test('to.decimal', () {
      final Runtime runtime = getRuntime('main = to.decimal(12)');
      checkResult(runtime, 12.0);
    });

    test('to.string', () {
      final Runtime runtime = getRuntime('main = to.string(12)');
      checkResult(runtime, '"12"');
    });

    test('to.boolean', () {
      final Runtime runtime = getRuntime('main = to.boolean(12)');
      checkResult(runtime, true);
    });
  });

  group('Is', () {
    test('is.number', () {
      final Runtime runtime = getRuntime('main = is.number(12.5)');
      checkResult(runtime, true);
    });

    test('is.integer', () {
      final Runtime runtime = getRuntime('main = is.integer(12)');
      checkResult(runtime, true);
    });

    test('is.decimal', () {
      final Runtime runtime = getRuntime('main = is.decimal(12.5)');
      checkResult(runtime, true);
    });

    test('is.infinite', () {
      final Runtime runtime = getRuntime('main = is.infinite(12)');
      checkResult(runtime, false);
    });

    test('is.string', () {
      final Runtime runtime = getRuntime('main = is.string("Hey")');
      checkResult(runtime, true);
    });

    test('is.boolean', () {
      final Runtime runtime = getRuntime('main = is.boolean(true)');
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
