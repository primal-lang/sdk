import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Runtime', () {
    test('Generic (eq)', () {
      final Runtime runtime = getRuntime('main = eq("hey", "hey")');
      checkResult(runtime, true);
    });

    test('Numbers (neq)', () {
      final Runtime runtime = getRuntime('main = neq(7, 8)');
      checkResult(runtime, true);
    });

    test('If (if1)', () {
      final Runtime runtime = getRuntime('main = if(true, "yes", "no")');
      checkResult(runtime, '"yes"');
    });

    test('If (if2)', () {
      final Runtime runtime = getRuntime('main = if(false, "yes", "no")');
      checkResult(runtime, '"no"');
    });

    test('If (if3)', () {
      final Runtime runtime = getRuntime('main = if(true, sum(1, 2), 42)');
      checkResult(runtime, 3);
    });

    test('Try (try1)', () {
      final Runtime runtime = getRuntime('main = try(div(1, 2), 42)');
      checkResult(runtime, 0.5);
    });

    test('Try (try2)', () {
      final Runtime runtime =
          getRuntime('main = try(error("Does not compute"), 42)');
      checkResult(runtime, 42);
    });

    test('Error (error)', () {
      try {
        final Runtime runtime =
            getRuntime('main = error("Segmentation fault")');
        runtime.executeMain();
        fail('Should fail');
      } catch (e) {
        expect(e, isA<RuntimeError>());
      }
    });

    test('Debug (debug)', () {
      final Runtime runtime = getRuntime('main = debug("Enter in function")');
      checkResult(runtime, '"Enter in function"');
    });

    test('Numbers (abs)', () {
      final Runtime runtime = getRuntime('main = abs(-1)');
      checkResult(runtime, 1);
    });

    test('Numbers (inc)', () {
      final Runtime runtime = getRuntime('main = inc(2)');
      checkResult(runtime, 3);
    });

    test('Numbers (dec)', () {
      final Runtime runtime = getRuntime('main = dec(0)');
      checkResult(runtime, -1);
    });

    test('Numbers (sum)', () {
      final Runtime runtime = getRuntime('main = sum(5, -7)');
      checkResult(runtime, -2);
    });

    test('Numbers (add)', () {
      final Runtime runtime = getRuntime('main = add(5, -7)');
      checkResult(runtime, -2);
    });

    test('Numbers (sub)', () {
      final Runtime runtime = getRuntime('main = sub(5, -7)');
      checkResult(runtime, 12);
    });

    test('Numbers (mul)', () {
      final Runtime runtime = getRuntime('main = mul(5, -7)');
      checkResult(runtime, -35);
    });

    test('Numbers (div)', () {
      final Runtime runtime = getRuntime('main = div(5, -8)');
      checkResult(runtime, -0.625);
    });

    test('Numbers (divInt)', () {
      final Runtime runtime = getRuntime('main = divInt(7, 3)');
      checkResult(runtime, 2);
    });

    test('Numbers (mod)', () {
      final Runtime runtime = getRuntime('main = mod(7, 5)');
      checkResult(runtime, 2);
    });

    test('Numbers (min)', () {
      final Runtime runtime = getRuntime('main = min(7, 5)');
      checkResult(runtime, 5);
    });

    test('Numbers (max)', () {
      final Runtime runtime = getRuntime('main = max(7, 5)');
      checkResult(runtime, 7);
    });

    test('Numbers (pow)', () {
      final Runtime runtime = getRuntime('main = pow(7, 5)');
      checkResult(runtime, 16807);
    });

    test('Numbers (sqrt)', () {
      final Runtime runtime = getRuntime('main = sqrt(16)');
      checkResult(runtime, 4);
    });

    test('Numbers (round)', () {
      final Runtime runtime = getRuntime('main = round(4.8)');
      checkResult(runtime, 5);
    });

    test('Numbers (floor)', () {
      final Runtime runtime = getRuntime('main = floor(4.8)');
      checkResult(runtime, 4);
    });

    test('Numbers (ceil)', () {
      final Runtime runtime = getRuntime('main = ceil(4.2)');
      checkResult(runtime, 5);
    });

    test('Numbers (sin)', () {
      final Runtime runtime = getRuntime('main = sin(10)');
      checkResult(runtime, -0.5440211108893698);
    });

    test('Numbers (cos)', () {
      final Runtime runtime = getRuntime('main = cos(10)');
      checkResult(runtime, -0.8390715290764524);
    });

    test('Numbers (tan)', () {
      final Runtime runtime = getRuntime('main = tan(10)');
      checkResult(runtime, 0.6483608274590866);
    });

    test('Numbers (log)', () {
      final Runtime runtime = getRuntime('main = log(10)');
      checkResult(runtime, 2.302585092994046);
    });

    test('Numbers (gt)', () {
      final Runtime runtime = getRuntime('main = gt(10, 4)');
      checkResult(runtime, true);
    });

    test('Numbers (lt)', () {
      final Runtime runtime = getRuntime('main = lt(10, 4)');
      checkResult(runtime, false);
    });

    test('Numbers (ge)', () {
      final Runtime runtime = getRuntime('main = ge(10, 4)');
      checkResult(runtime, true);
    });

    test('Numbers (le)', () {
      final Runtime runtime = getRuntime('main = le(10, 10)');
      checkResult(runtime, true);
    });

    test('Numbers (isNegative)', () {
      final Runtime runtime = getRuntime('main = isNegative(-5)');
      checkResult(runtime, true);
    });

    test('Numbers (isPositive)', () {
      final Runtime runtime = getRuntime('main = isPositive(-5)');
      checkResult(runtime, false);
    });

    test('Numbers (isZero)', () {
      final Runtime runtime = getRuntime('main = isZero(0)');
      checkResult(runtime, true);
    });

    test('Numbers (isEven)', () {
      final Runtime runtime = getRuntime('main = isEven(6)');
      checkResult(runtime, true);
    });

    test('Numbers (isOdd)', () {
      final Runtime runtime = getRuntime('main = isOdd(7)');
      checkResult(runtime, true);
    });

    test('Booleans (and)', () {
      final Runtime runtime = getRuntime('main = and(true, true)');
      checkResult(runtime, true);
    });

    test('Booleans (or)', () {
      final Runtime runtime = getRuntime('main = or(false, true)');
      checkResult(runtime, true);
    });

    test('Booleans (xor)', () {
      final Runtime runtime = getRuntime('main = xor(false, true)');
      checkResult(runtime, true);
    });

    test('Booleans (not)', () {
      final Runtime runtime = getRuntime('main = not(false)');
      checkResult(runtime, true);
    });

    test('Strings (subString)', () {
      final Runtime runtime = getRuntime('main = subString("hola", 1, 3)');
      checkResult(runtime, '"ol"');
    });

    test('Strings (startsWith)', () {
      final Runtime runtime = getRuntime('main = startsWith("hola", "ho")');
      checkResult(runtime, true);
    });

    test('Strings (endsWith)', () {
      final Runtime runtime = getRuntime('main = endsWith("hola", "la")');
      checkResult(runtime, true);
    });

    test('Strings (replace)', () {
      final Runtime runtime = getRuntime('main = replace("banana", "na", "to")');
      checkResult(runtime, '"batoto"');
    });

    test('Strings (uppercase)', () {
      final Runtime runtime = getRuntime('main = uppercase("Primal")');
      checkResult(runtime, '"PRIMAL"');
    });

    test('Strings (lowercase)', () {
      final Runtime runtime = getRuntime('main = lowercase("Primal")');
      checkResult(runtime, '"primal"');
    });

    test('Strings (trim)', () {
      final Runtime runtime = getRuntime('main = trim(" Primal ")');
      checkResult(runtime, '"Primal"');
    });

    test('Strings (match)', () {
      final Runtime runtime = getRuntime('main = match("identifier42", "[a-zA-Z]+[0-9]+")');
      checkResult(runtime, true);
    });

    test('Generic:String (length)', () {
      final Runtime runtime = getRuntime('main = length("primal")');
      checkResult(runtime, 6);
    });

    test('Generic:String (concat)', () {
      final Runtime runtime = getRuntime('main = concat("Hello", ", world!")');
      checkResult(runtime, '"Hello, world!"');
    });

    test('Generic:String (first)', () {
      final Runtime runtime = getRuntime('main = first("Hello")');
      checkResult(runtime, '"H"');
    });

    test('Generic:String (last)', () {
      final Runtime runtime = getRuntime('main = last("Hello")');
      checkResult(runtime, '"o"');
    });

    test('Generic:String (init)', () {
      final Runtime runtime = getRuntime('main = init("Hello")');
      checkResult(runtime, '"Hell"');
    });

    test('Generic:String (tail)', () {
      final Runtime runtime = getRuntime('main = tail("Hello")');
      checkResult(runtime, '"ello"');
    });

    test('Generic:String (at)', () {
      final Runtime runtime = getRuntime('main = at("Hello", 1)');
      checkResult(runtime, '"e"');
    });

    test('Generic:String (isEmpty)', () {
      final Runtime runtime = getRuntime('main = isEmpty("Hello")');
      checkResult(runtime, false);
    });

    test('Generic:String (isNotEmpty)', () {
      final Runtime runtime = getRuntime('main = isNotEmpty("Hello")');
      checkResult(runtime, true);
    });

    test('Generic:String (contains)', () {
      final Runtime runtime = getRuntime('main = contains("Hello", "ell")');
      checkResult(runtime, true);
    });

    test('Generic:String (take)', () {
      final Runtime runtime = getRuntime('main = take("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('Generic:String (drop)', () {
      final Runtime runtime = getRuntime('main = drop("Hello", 2)');
      checkResult(runtime, '"llo"');
    });

    test('Generic:String (remove)', () {
      final Runtime runtime = getRuntime('main = remove("Hello", 4)');
      checkResult(runtime, '"Hell"');
    });

    test('Generic:String (reverse)', () {
      final Runtime runtime = getRuntime('main = reverse("Hello")');
      checkResult(runtime, '"olleH"');
    });

    test('Casting (toNumber)', () {
      final Runtime runtime = getRuntime('main = toNumber("12.5")');
      checkResult(runtime, 12.5);
    });

    test('Casting (toInteger)', () {
      final Runtime runtime = getRuntime('main = toInteger("12")');
      checkResult(runtime, 12);
    });

    test('Casting (toDecimal)', () {
      final Runtime runtime = getRuntime('main = toDecimal(12)');
      checkResult(runtime, 12.0);
    });

    test('Casting (toString)', () {
      final Runtime runtime = getRuntime('main = toString(12)');
      checkResult(runtime, '"12"');
    });

    test('Casting (toBoolean)', () {
      final Runtime runtime = getRuntime('main = toBoolean(12)');
      checkResult(runtime, true);
    });

    test('Casting (isNumber)', () {
      final Runtime runtime = getRuntime('main = isNumber(12.5)');
      checkResult(runtime, true);
    });

    test('Casting (isInteger)', () {
      final Runtime runtime = getRuntime('main = isInteger(12)');
      checkResult(runtime, true);
    });

    test('Casting (isDecimal)', () {
      final Runtime runtime = getRuntime('main = isDecimal(12.5)');
      checkResult(runtime, true);
    });

    test('Casting (isInfinite)', () {
      final Runtime runtime = getRuntime('main = isInfinite(12)');
      checkResult(runtime, false);
    });

    test('Casting (isString)', () {
      final Runtime runtime = getRuntime('main = isString("Hey")');
      checkResult(runtime, true);
    });

    test('Casting (isBoolean)', () {
      final Runtime runtime = getRuntime('main = isBoolean(true)');
      checkResult(runtime, true);
    });

    test('Complex script (factorial)', () {
      final Runtime runtime = getRuntime(
          'factorial(n) = if(isZero(n), 1, mul(n, factorial(dec(n))))\nmain = factorial(5)');
      checkResult(runtime, 120);
    });
  });
}
