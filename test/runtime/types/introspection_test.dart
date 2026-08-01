@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('type_of', () {
    group('returns correct type name for each runtime type', () {
      test('Boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of(true)');
        checkResult(runtime, '"Boolean"');
      });

      test('Number (integer)', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of(42)');
        checkResult(runtime, '"Number"');
      });

      test('Number (decimal)', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of(3.14)');
        checkResult(runtime, '"Number"');
      });

      test('String', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of("hello")');
        checkResult(runtime, '"String"');
      });

      test('List', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of([1, 2, 3])');
        checkResult(runtime, '"List"');
      });

      test('Map', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of({"a": 1})');
        checkResult(runtime, '"Map"');
      });

      test('Set', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(set_new([1, 2]))',
        );
        checkResult(runtime, '"Set"');
      });

      test('Stack', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(stack_new([1, 2]))',
        );
        checkResult(runtime, '"Stack"');
      });

      test('Queue', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(queue_new([1, 2]))',
        );
        checkResult(runtime, '"Queue"');
      });

      test('Vector', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(vector_new([1, 2]))',
        );
        checkResult(runtime, '"Vector"');
      });

      test('File', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(file_fromPath("."))',
        );
        checkResult(runtime, '"File"');
      });

      test('Directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(directory_fromPath("."))',
        );
        checkResult(runtime, '"Directory"');
      });

      test('Timestamp', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(time_now())',
        );
        checkResult(runtime, '"Timestamp"');
      });

      test('Duration', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(duration_fromHours(1))',
        );
        checkResult(runtime, '"Duration"');
      });

      test('Function (standard library)', () {
        final RuntimeFacade runtime = getRuntime('main() = type_of(num_add)');
        checkResult(runtime, '"Function"');
      });

      test('Function (user-defined)', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = type_of(add)
''');
        checkResult(runtime, '"Function"');
      });

      test('Function (lambda)', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of((x) -> x + 1)',
        );
        checkResult(runtime, '"Function"');
      });
    });

    group('reduces argument before inspection', () {
      test('conditional expression returns type of selected branch', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(if (true) 42 else "x")',
        );
        checkResult(runtime, '"Number"');
      });

      test('function call result', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(list_first([1, 2, 3]))',
        );
        checkResult(runtime, '"Number"');
      });

      test('let binding', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = let x = [1, 2] in type_of(x)',
        );
        checkResult(runtime, '"List"');
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(type_of)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(type_of, 1, 2)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('propagates error from argument evaluation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = type_of(error_throw(1, "test error"))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<CustomError>()),
        );
      });
    });
  });

  group('function_name', () {
    group('user-defined functions', () {
      test('returns declared function name', () {
        final RuntimeFacade runtime = getRuntime('''
addNumbers(a, b) = a + b
main() = function_name(addNumbers)
''');
        checkResult(runtime, '"addNumbers"');
      });

      test('returns name for zero-arity function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function_name(zero)
''');
        checkResult(runtime, '"zero"');
      });
    });

    group('standard library functions', () {
      test('returns qualified name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name(num_add)',
        );
        checkResult(runtime, '"num_add"');
      });

      test('returns qualified name for list_map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name(list_map)',
        );
        checkResult(runtime, '"list_map"');
      });

      test('returns qualified name for single-name function', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name(debug)',
        );
        checkResult(runtime, '"debug"');
      });
    });

    group('lambda expressions', () {
      test('returns synthetic location-based name', () {
        final RuntimeFacade runtime = getRuntime('''
id() = (x) -> x
main() = function_name(id())
''');
        final String result = runtime.executeMain().toString();
        expect(result, matches(RegExp(r'"<lambda@\d+:\d+>"')));
      });

      test('inline lambda has location-based name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name((x) -> x)',
        );
        final String result = runtime.executeMain().toString();
        expect(result, matches(RegExp(r'"<lambda@\d+:\d+>"')));
      });
    });

    group('let bindings', () {
      test('returns intrinsic name, not binding name', () {
        final RuntimeFacade runtime = getRuntime('''
greet(name) = name
main() = let alias = greet in function_name(alias)
''');
        checkResult(runtime, '"greet"');
      });

      test('nested let binding returns intrinsic name', () {
        final RuntimeFacade runtime = getRuntime('''
original(x) = x
main() = let a = original in let b = a in function_name(b)
''');
        checkResult(runtime, '"original"');
      });
    });

    group('mutual recursion', () {
      test('works with mutually recursive functions', () {
        final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main() = function_name(isEven)
''');
        checkResult(runtime, '"isEven"');
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime('main() = function_name(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name([1, 2])',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for boolean', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name(true)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function_name)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function_name, num_add, num_sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('function_arity', () {
    group('user-defined functions', () {
      test('returns arity for two-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = function_arity(add)
''');
        checkResult(runtime, 2);
      });

      test('returns arity for zero-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function_arity(zero)
''');
        checkResult(runtime, 0);
      });

      test('returns arity for single-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main() = function_arity(identity)
''');
        checkResult(runtime, 1);
      });

      test('returns arity for five-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
five(a, b, c, d, e) = a + b + c + d + e
main() = function_arity(five)
''');
        checkResult(runtime, 5);
      });
    });

    group('standard library functions', () {
      test('num_add has arity 2', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity(num_add)',
        );
        checkResult(runtime, 2);
      });

      test('num_abs has arity 1', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity(num_abs)',
        );
        checkResult(runtime, 1);
      });

      test('time_now has arity 0', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity(time_now)',
        );
        checkResult(runtime, 0);
      });

      test('list_map has arity 2', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity(list_map)',
        );
        checkResult(runtime, 2);
      });
    });

    group('lambda expressions', () {
      test('single parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity((x) -> x)',
        );
        checkResult(runtime, 1);
      });

      test('two parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity((x, y) -> x + y)',
        );
        checkResult(runtime, 2);
      });

      test('zero parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity(() -> 42)',
        );
        checkResult(runtime, 0);
      });

      test('nested lambda returns outer arity only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity((x) -> (y) -> x + y)',
        );
        checkResult(runtime, 1);
      });

      test('lambda returned from function', () {
        final RuntimeFacade runtime = getRuntime('''
makeLambda() = (a, b, c) -> a + b + c
main() = function_arity(makeLambda())
''');
        checkResult(runtime, 3);
      });
    });

    group('wrapped functions', () {
      test('partial application creates new lambda with own arity', () {
        final RuntimeFacade runtime = getRuntime('''
partial() = (x) -> num_add(x, 5)
main() = function_arity(partial())
''');
        checkResult(runtime, 1);
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime('main() = function_arity(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_arity({"a": 1})',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function_arity)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function_arity, num_add, num_sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('function_parameters', () {
    group('user-defined functions', () {
      test('returns parameter names for two-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = function_parameters(add)
''');
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('returns empty list for zero-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
zero() = 0
main() = function_parameters(zero)
''');
        checkResult(runtime, <String>[]);
      });

      test('returns parameter name for single-parameter function', () {
        final RuntimeFacade runtime = getRuntime('''
greet(name) = name
main() = function_parameters(greet)
''');
        checkResult(runtime, ['"name"']);
      });

      test('preserves parameter order', () {
        final RuntimeFacade runtime = getRuntime('''
order(first, second, third) = first
main() = function_parameters(order)
''');
        checkResult(runtime, ['"first"', '"second"', '"third"']);
      });
    });

    group('standard library functions', () {
      test('num_add has parameters a, b', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(num_add)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('list_map has parameters a, b', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(list_map)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      });

      test('time_now has empty parameters', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(time_now)',
        );
        checkResult(runtime, <String>[]);
      });
    });

    group('lambda expressions', () {
      test('single parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters((x) -> x)',
        );
        checkResult(runtime, ['"x"']);
      });

      test('two parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters((x, y) -> x + y)',
        );
        checkResult(runtime, ['"x"', '"y"']);
      });

      test('zero parameter lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(() -> 42)',
        );
        checkResult(runtime, <String>[]);
      });

      test('preserves lambda parameter names', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters((first, second) -> first)',
        );
        checkResult(runtime, ['"first"', '"second"']);
      });
    });

    group('closures', () {
      test('returns only lambda parameters, not captured variables', () {
        final RuntimeFacade runtime = getRuntime('''
makeAdder(n) = (x) -> x + n
main() = function_parameters(makeAdder(5))
''');
        checkResult(runtime, ['"x"']);
      });

      test('multiple captured variables not included', () {
        final RuntimeFacade runtime = getRuntime('''
makeFunc(a, b, c) = (x, y) -> x + y + a + b + c
main() = function_parameters(makeFunc(1, 2, 3))
''');
        checkResult(runtime, ['"x"', '"y"']);
      });
    });

    group('wrapped functions', () {
      test('wrapper has its own parameters', () {
        final RuntimeFacade runtime = getRuntime('''
partial() = (x) -> num_add(x, 5)
main() = function_parameters(partial())
''');
        checkResult(runtime, ['"x"']);
      });
    });

    group('error handling', () {
      test('throws InvalidArgumentTypesError for number', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentTypesError for list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters([1, 2])',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too few)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f) = f()
main() = apply(function_parameters)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('throws InvalidArgumentCountError via indirect call (too many)', () {
        final RuntimeFacade runtime = getRuntime('''
apply(f, x, y) = f(x, y)
main() = apply(function_parameters, num_add, num_sub)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });
    });
  });

  group('FunctionReferenceTerm resolution', () {
    test('function_name resolves reference to standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function_name(num_add)',
      );
      checkResult(runtime, '"num_add"');
    });

    test('function_arity resolves reference to standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function_arity(num_add)',
      );
      checkResult(runtime, 2);
    });

    test(
      'function_parameters resolves reference to standard library function',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_parameters(num_add)',
        );
        checkResult(runtime, ['"a"', '"b"']);
      },
    );

    test('function_name resolves reference to user-defined function', () {
      final RuntimeFacade runtime = getRuntime('''
foo(x) = x
main() = function_name(foo)
''');
      checkResult(runtime, '"foo"');
    });
  });

  group('Consistency with is_function', () {
    // Values for which is_function returns false should cause function_name
    // to throw InvalidArgumentTypesError.

    final Map<String, String> nonFunctionExpressions = {
      'integer': '42',
      'decimal': '12.5',
      'string': '"hello"',
      'boolean': 'true',
      'list': '[1, 2, 3]',
      'map': '{"foo": 1}',
      'vector': 'vector_new([1, 2, 3])',
      'set': 'set_new([1, 2, 3])',
      'stack': 'stack_new([1, 2, 3])',
      'queue': 'queue_new([1, 2, 3])',
      'timestamp': 'time_now()',
      'duration': 'duration_fromHours(2)',
      'file': 'file_fromPath(".")',
      'directory': 'directory_fromPath(".")',
    };

    for (final MapEntry<String, String> entry
        in nonFunctionExpressions.entries) {
      final String typeName = entry.key;
      final String expression = entry.value;

      test('function_name throws for $typeName', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = function_name($expression)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });
    }

    // function values should work
    test('function_name works for standard library function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function_name(num_abs)',
      );
      checkResult(runtime, '"num_abs"');
    });
  });
}
