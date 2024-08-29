import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Control', () {
    test('if1', () {
      final Runtime runtime = getRuntime('main = if(true, "yes", "no")');
      checkResult(runtime, '"yes"');
    });

    test('if2', () {
      final Runtime runtime = getRuntime('main = if(false, "yes", "no")');
      checkResult(runtime, '"no"');
    });

    test('if3', () {
      final Runtime runtime = getRuntime('main = if(true, 1 + 2, 42)');
      checkResult(runtime, 3);
    });
  });

  group('Try/Catch', () {
    test('try1', () {
      final Runtime runtime = getRuntime('main = try(1 / 2, 42)');
      checkResult(runtime, 0.5);
    });

    test('try2', () {
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

    test('!=', () {
      final Runtime runtime = getRuntime('main = 7 != 8');
      checkResult(runtime, true);
    });

    test('>', () {
      final Runtime runtime = getRuntime('main = 10 > 4');
      checkResult(runtime, true);
    });

    test('<', () {
      final Runtime runtime = getRuntime('main = 10 < 4');
      checkResult(runtime, false);
    });

    test('>=', () {
      final Runtime runtime = getRuntime('main = 10 >= 10');
      checkResult(runtime, true);
    });

    test('<=', () {
      final Runtime runtime = getRuntime('main = 10 <= 10');
      checkResult(runtime, true);
    });

    test('+', () {
      final Runtime runtime = getRuntime('main = 5 + 7');
      checkResult(runtime, 12);
    });

    test('-', () {
      final Runtime runtime = getRuntime('main = 5 - 7');
      checkResult(runtime, -2);
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

    test('&', () {
      final Runtime runtime = getRuntime('main = true & true');
      checkResult(runtime, true);
    });

    test('|', () {
      final Runtime runtime = getRuntime('main = false | true');
      checkResult(runtime, true);
    });

    test('!', () {
      final Runtime runtime = getRuntime('main = !false');
      checkResult(runtime, true);
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

    test('num.negative', () {
      final Runtime runtime = getRuntime('main = num.negative(5)');
      checkResult(runtime, -5);
    });

    test('num.inc', () {
      final Runtime runtime = getRuntime('main = num.inc(2)');
      checkResult(runtime, 3);
    });

    test('num.dec', () {
      final Runtime runtime = getRuntime('main = num.dec(0)');
      checkResult(runtime, -1);
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

    test('num.max', () {
      final Runtime runtime = getRuntime('main = num.max(7, 5)');
      checkResult(runtime, 7);
    });

    test('num.pow', () {
      final Runtime runtime = getRuntime('main = num.pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('num.sqrt', () {
      final Runtime runtime = getRuntime('main = num.sqrt(16)');
      checkResult(runtime, 4);
    });

    test('num.round', () {
      final Runtime runtime = getRuntime('main = num.round(4.8)');
      checkResult(runtime, 5);
    });

    test('num.floor', () {
      final Runtime runtime = getRuntime('main = num.floor(4.8)');
      checkResult(runtime, 4);
    });

    test('num.ceil', () {
      final Runtime runtime = getRuntime('main = num.ceil(4.2)');
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

    test('num.isPositive', () {
      final Runtime runtime = getRuntime('main = num.isPositive(5)');
      checkResult(runtime, true);
    });

    test('num.isZero', () {
      final Runtime runtime = getRuntime('main = num.isZero(0)');
      checkResult(runtime, true);
    });

    test('num.isEven', () {
      final Runtime runtime = getRuntime('main = num.isEven(6)');
      checkResult(runtime, true);
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

    test('bool.or', () {
      final Runtime runtime = getRuntime('main = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('bool.xor', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, true)');
      checkResult(runtime, true);
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

  group('Complex', () {
    test('factorial', () {
      final Runtime runtime = getRuntime(
          'factorial(n) = if(n == 0, 1, n * factorial(n - 1))\nmain = factorial(5)');
      checkResult(runtime, 120);
    });
  });
}
