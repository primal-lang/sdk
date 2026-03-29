import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
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
      final Runtime runtime = getRuntime(
        'main = num.asDegrees(0.52359877559829887307)',
      );
      expect(num.parse(runtime.executeMain()), closeTo(30, 0.0001));
    });

    test('num.asDegrees 3', () {
      final Runtime runtime = getRuntime(
        'main = num.asDegrees(3.141592653589793)',
      );
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

  group('Division and Modulo Edge Cases', () {
    test('division by zero', () {
      final Runtime runtime = getRuntime('main = 5 / 0');
      checkResult(runtime, double.infinity);
    });

    test('negative division by zero', () {
      final Runtime runtime = getRuntime('main = -5 / 0');
      checkResult(runtime, double.negativeInfinity);
    });

    test('modulo by zero', () {
      final Runtime runtime = getRuntime('main = 5 % 0');
      expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
    });

    test('num.div by zero', () {
      final Runtime runtime = getRuntime('main = num.div(5, 0)');
      checkResult(runtime, double.infinity);
    });

    test('num.mod by zero', () {
      final Runtime runtime = getRuntime('main = num.mod(5, 0)');
      expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
    });
  });

  group('Numeric Edge Cases', () {
    test('num.sqrt negative throws', () {
      final Runtime runtime = getRuntime('main = num.sqrt(-1)');
      expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
    });

    test('num.round negative half', () {
      final Runtime runtime = getRuntime('main = num.round(-0.5)');
      checkResult(runtime, -1);
    });

    test('num.floor negative', () {
      final Runtime runtime = getRuntime('main = num.floor(-4.6)');
      checkResult(runtime, -5);
    });

    test('num.ceil negative', () {
      final Runtime runtime = getRuntime('main = num.ceil(-4.6)');
      checkResult(runtime, -4);
    });

    test('num.isPositive zero', () {
      final Runtime runtime = getRuntime('main = num.isPositive(0)');
      checkResult(runtime, false);
    });

    test('num.isNegative zero', () {
      final Runtime runtime = getRuntime('main = num.isNegative(0)');
      checkResult(runtime, false);
    });

    test('num.isZero zero decimal', () {
      final Runtime runtime = getRuntime('main = num.isZero(0.0)');
      checkResult(runtime, true);
    });

    test('num.max both negative', () {
      final Runtime runtime = getRuntime('main = num.max(-7, -5)');
      checkResult(runtime, -5);
    });

    test('decimal equals integer', () {
      final Runtime runtime = getRuntime('main = 1.0 == 1');
      checkResult(runtime, true);
    });

    test('num.sign positive decimal', () {
      final Runtime runtime = getRuntime('main = num.sign(0.5)');
      checkResult(runtime, 1);
    });

    test('num.sign negative decimal', () {
      final Runtime runtime = getRuntime('main = num.sign(-0.5)');
      checkResult(runtime, -1);
    });

    test('num.clamp value equals min', () {
      final Runtime runtime = getRuntime('main = num.clamp(1, 1, 5)');
      checkResult(runtime, 1);
    });

    test('num.clamp value equals max', () {
      final Runtime runtime = getRuntime('main = num.clamp(5, 1, 5)');
      checkResult(runtime, 5);
    });
  });

  group('Arithmetic Type Errors', () {
    test('num.add throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.add("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sub throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.sub(true, 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mul throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.mul([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.div throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.div("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.mod throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.mod("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.pow throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.pow("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.abs throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.abs("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.sqrt throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.sqrt("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.round throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.round("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.ceil throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.ceil("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('num.floor throws for wrong type', () {
      final Runtime runtime = getRuntime('main = num.floor("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });
}
