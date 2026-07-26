@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('type.of', () {
    group('returns correct type name for each runtime type', () {
      test('Boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of(true)');
        checkResult(runtime, '"Boolean"');
      });

      test('Number (integer)', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of(42)');
        checkResult(runtime, '"Number"');
      });

      test('Number (decimal)', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of(3.14)');
        checkResult(runtime, '"Number"');
      });

      test('String', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of("hello")');
        checkResult(runtime, '"String"');
      });

      test('List', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of([1, 2, 3])');
        checkResult(runtime, '"List"');
      });

      test('Map', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of({"a": 1})');
        checkResult(runtime, '"Map"');
      });

      test('Set', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(set.new([1, 2]))',
        );
        checkResult(runtime, '"Set"');
      });

      test('Stack', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(stack.new([1, 2]))',
        );
        checkResult(runtime, '"Stack"');
      });

      test('Queue', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(queue.new([1, 2]))',
        );
        checkResult(runtime, '"Queue"');
      });

      test('Vector', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(vector.new([1, 2]))',
        );
        checkResult(runtime, '"Vector"');
      });

      test('File', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(file.fromPath("."))',
        );
        checkResult(runtime, '"File"');
      });

      test('Directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(directory.fromPath("."))',
        );
        checkResult(runtime, '"Directory"');
      });

      test('Timestamp', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(time.now())',
        );
        checkResult(runtime, '"Timestamp"');
      });

      test('Duration', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(duration.fromHours(1))',
        );
        checkResult(runtime, '"Duration"');
      });

      test('Function (standard library)', () {
        final RuntimeFacade runtime = getRuntime('main() = type.of(num.add)');
        checkResult(runtime, '"Function"');
      });

      test('Function (user-defined)', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = type.of(add)
''');
        checkResult(runtime, '"Function"');
      });

      test('Function (lambda)', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of((x) -> x + 1)',
        );
        checkResult(runtime, '"Function"');
      });
    });

    group('reduces argument before inspection', () {
      test('conditional expression returns type of selected branch', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(if (true) 42 else "x")',
        );
        checkResult(runtime, '"Number"');
      });

      test('function call result', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(list.first([1, 2, 3]))',
        );
        checkResult(runtime, '"Number"');
      });

      test('let binding', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = let x = [1, 2] in type.of(x)',
        );
        checkResult(runtime, '"List"');
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(type.of)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(type.of, 1, 2)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('propagates error from argument evaluation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type.of(error.throw(1, "test error"))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<CustomError>()),
        );
      });
    });
  });

  group('function.name', () {
    group('user-defined functions', () {
      test('returns declared function name', () {
        final RuntimeFacade runtime = getRuntime('''
addNumbers(a, b) = a + b
main() = function.name(addNumbers)
''');
        checkResult(runtime, '"addNumbers"');
      });

      test('returns name for zero-arity function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function.name(zero)
''');
        checkResult(runtime, '"zero"');
      });
    });

    group('standard library functions', () {
      test('returns qualified name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name(num.add)',
        );
        checkResult(runtime, '"num.add"');
      });

      test('returns qualified name for list.map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name(list.map)',
        );
        checkResult(runtime, '"list.map"');
      });

      test('returns qualified name for single-name function', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name(debug)',
        );
        checkResult(runtime, '"debug"');
      });
    });

    group('lambda expressions', () {
      test('returns synthetic location-based name', () {
        final RuntimeFacade runtime = getRuntime('''
id() = (x) -> x
main() = function.name(id())
''');
        final String result = runtime.executeMain().toString();
        expect(result, matches(RegExp(r'"<lambda@\d+:\d+>"')));
      });

      test('inline lambda has location-based name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name((x) -> x)',
        );
        final String result = runtime.executeMain().toString();
        expect(result, matches(RegExp(r'"<lambda@\d+:\d+>"')));
      });
    });

    group('let bindings', () {
      test('returns intrinsic name, not binding name', () {
        final RuntimeFacade runtime = getRuntime('''
greet(name) = name
main() = let alias = greet in function.name(alias)
''');
        checkResult(runtime, '"greet"');
      });

      test('nested let binding returns intrinsic name', () {
        final RuntimeFacade runtime = getRuntime('''
original(x) = x
main() = let a = original in let b = a in function.name(b)
''');
        checkResult(runtime, '"original"');
      });
    });

    group('mutual recursion', () {
      test('works with mutually recursive functions', () {
        final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main() = function.name(isEven)
''');
        checkResult(runtime, '"isEven"');
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime('main() = function.name(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name([1, 2])',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for boolean', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name(true)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function.name)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function.name, num.add, num.sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('function.arity', () {
    group('user-defined functions', () {
      test('returns arity for two-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = function.arity(add)
''');
        checkResult(runtime, 2);
      });

      test('returns arity for zero-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function.arity(zero)
''');
        checkResult(runtime, 0);
      });

      test('returns arity for single-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main() = function.arity(identity)
''');
        checkResult(runtime, 1);
      });

      test('returns arity for five-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
five(a, b, c, d, e) = a + b + c + d + e
main() = function.arity(five)
''');
        checkResult(runtime, 5);
      });
    });

    group('standard library functions', () {
      test('num.add has arity 2', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity(num.add)',
        );
        checkResult(runtime, 2);
      });

      test('num.abs has arity 1', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity(num.abs)',
        );
        checkResult(runtime, 1);
      });

      test('time.now has arity 0', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity(time.now)',
        );
        checkResult(runtime, 0);
      });

      test('list.map has arity 2', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity(list.map)',
        );
        checkResult(runtime, 2);
      });
    });

    group('lambda expressions', () {
      test('single parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity((x) -> x)',
        );
        checkResult(runtime, 1);
      });

      test('two parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity((x, y) -> x + y)',
        );
        checkResult(runtime, 2);
      });

      test('zero parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity(() -> 42)',
        );
        checkResult(runtime, 0);
      });

      test('nested lambda returns outer arity only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity((x) -> (y) -> x + y)',
        );
        checkResult(runtime, 1);
      });

      test('lambda returned from function', () {
        final RuntimeFacade runtime = getRuntime('''
makeLambda() = (a, b, c) -> a + b + c
main() = function.arity(makeLambda())
''');
        checkResult(runtime, 3);
      });
    });

    group('wrapped functions', () {
      test('partial application creates new lambda with own arity', () {
        final RuntimeFacade runtime = getRuntime('''
partial() = (x) -> num.add(x, 5)
main() = function.arity(partial())
''');
        checkResult(runtime, 1);
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime('main() = function.arity(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.arity({"a": 1})',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function.arity)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function.arity, num.add, num.sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('function.parameters', () {
    group('user-defined functions', () {
      test('returns parameter names for two-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = function.parameters(add)
''');
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('returns empty list for zero-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function.parameters(zero)
''');
        checkResult(runtime, <String>[]);
      });

      test('returns parameter name for single-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
greet(name) = name
main() = function.parameters(greet)
''');
        checkResult(runtime, ['"name"']);
      });

      test('preserves parameter order', () {
        final RuntimeFacade runtime = getRuntime('''
order(first, second, third) = first
main() = function.parameters(order)
''');
        checkResult(runtime, ['"first"', '"second"', '"third"']);
      });
    });

    group('standard library functions', () {
      test('num.add has parameters a, b', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(num.add)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('list.map has parameters a, b', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(list.map)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('time.now has empty parameters', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(time.now)',
        );
        checkResult(runtime, <String>[]);
      });
    });

    group('lambda expressions', () {
      test('single parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters((x) -> x)',
        );
        checkResult(runtime, ['"x"']);
      });

      test('two parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters((x, y) -> x + y)',
        );
        checkResult(runtime, ['"x"', '"y"']);
      });

      test('zero parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(() -> 42)',
        );
        checkResult(runtime, <String>[]);
      });

      test('preserves lambda parameter names', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters((first, second) -> first)',
        );
        checkResult(runtime, ['"first"', '"second"']);
      });
    });

    group('closures', () {
      test('returns only lambda parameters, not captured variables', () {
        final RuntimeFacade runtime = getRuntime('''
makeAdder(n) = (x) -> x + n
main() = function.parameters(makeAdder(5))
''');
        checkResult(runtime, ['"x"']);
      });

      test('multiple captured variables not included', () {
        final RuntimeFacade runtime = getRuntime('''
makeFunc(a, b, c) = (x, y) -> x + y + a + b + c
main() = function.parameters(makeFunc(1, 2, 3))
''');
        checkResult(runtime, ['"x"', '"y"']);
      });
    });

    group('wrapped functions', () {
      test('wrapper has its own parameters', () {
        final RuntimeFacade runtime = getRuntime('''
partial() = (x) -> num.add(x, 5)
main() = function.parameters(partial())
''');
        checkResult(runtime, ['"x"']);
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters([1, 2])',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function.parameters)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function.parameters, num.add, num.sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('FunctionReferenceTerm resolution', () {
    test('function.name resolves reference to standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.name(num.add)',
      );
      checkResult(runtime, '"num.add"');
    });

    test('function.arity resolves reference to standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.arity(num.add)',
      );
      checkResult(runtime, 2);
    });

    test(
      'function.parameters resolves reference to standard library function',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.parameters(num.add)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      },
    );

    test('function.name resolves reference to user-defined function', () {
      final RuntimeFacade runtime = getRuntime('''
foo(x) = x
main() = function.name(foo)
''');
      checkResult(runtime, '"foo"');
    });
  });

  group('Consistency with is.function', () {
    // Values for which is.function returns false should cause function.name
    // to throw InvalidArgumentTypesError.

    final Map<String, String> nonFunctionExpressions = {
      'integer': '42',
      'decimal': '12.5',
      'string': '"hello"',
      'boolean': 'true',
      'list': '[1, 2, 3]',
      'map': '{"foo": 1}',
      'vector': 'vector.new([1, 2, 3])',
      'set': 'set.new([1, 2, 3])',
      'stack': 'stack.new([1, 2, 3])',
      'queue': 'queue.new([1, 2, 3])',
      'timestamp': 'time.now()',
      'duration': 'duration.fromHours(2)',
      'file': 'file.fromPath(".")',
      'directory': 'directory.fromPath(".")',
    };

    for (final MapEntry<String, String> entry
        in nonFunctionExpressions.entries) {
      final String typeName = entry.key;
      final String expression = entry.value;

      test('function.name throws for $typeName', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function.name($expression)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });
    }

    // function values should work
    test('function.name works for standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.name(num.abs)',
      );
      checkResult(runtime, '"num.abs"');
    });
  });
}
