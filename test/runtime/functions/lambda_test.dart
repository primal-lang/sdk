@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Lambda expressions', () {
    group('Basic invocation', () {
      test('Immediately invoked lambda', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> x + 1)(5)');
        checkResult(runtime, 6);
      });

      test('Zero-param lambda', () {
        final RuntimeFacade runtime = getRuntime('main() = (() -> 42)()');
        checkResult(runtime, 42);
      });

      test('Multi-param lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x, y) -> x + y)(2, 3)',
        );
        checkResult(runtime, 5);
      });

      test('Three-param lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((a, b, c) -> a + b + c)(1, 2, 3)',
        );
        checkResult(runtime, 6);
      });

      test('Lambda with arithmetic body', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> x * 2 + 1)(5)',
        );
        checkResult(runtime, 11);
      });

      test('Lambda with comparison body', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> x > 0)(5)');
        checkResult(runtime, true);
      });

      test('Lambda with negation body', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> -x)(5)');
        checkResult(runtime, -5);
      });

      test('Lambda with boolean not body', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> !x)(true)');
        checkResult(runtime, false);
      });
    });

    group('Nested lambdas', () {
      test('Nested invocation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> (y) -> x + y)(1)(2)',
        );
        checkResult(runtime, 3);
      });

      test('Triple nested invocation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((a) -> (b) -> (c) -> a + b + c)(1)(2)(3)',
        );
        checkResult(runtime, 6);
      });

      test('Nested captures outer parameter', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> (y) -> x * y)(3)(4)',
        );
        checkResult(runtime, 12);
      });
    });

    group('Closures', () {
      test('Captures function parameter', () {
        final RuntimeFacade runtime = getRuntime('''
mult(n) = (x) -> x * n
main() = mult(3)(4)
''');
        checkResult(runtime, 12);
      });

      test('Captures let binding', () {
        final RuntimeFacade runtime = getRuntime('''
f(n) = let m = 2 in (x) -> x * m
main() = f(0)(5)
''');
        checkResult(runtime, 10);
      });

      test('Captures multiple variables', () {
        final RuntimeFacade runtime = getRuntime('''
f(a, b) = (x) -> x + a + b
main() = f(10, 20)(5)
''');
        checkResult(runtime, 35);
      });

      test('Closure with nested let', () {
        final RuntimeFacade runtime = getRuntime('''
f(n) = let a = 1, b = 2 in (x) -> x + a + b + n
main() = f(10)(100)
''');
        checkResult(runtime, 113);
      });
    });

    group('Higher-order functions with lambdas', () {
      test('list.map with lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.map([1, 2, 3], (x) -> x * 2)',
        );
        checkResult(runtime, '[2, 4, 6]');
      });

      test('list.filter with lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.filter([1, 2, 3, 4], (x) -> x > 2)',
        );
        checkResult(runtime, '[3, 4]');
      });

      test('list.reduce with lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.reduce([1, 2, 3], 0, (acc, x) -> acc + x)',
        );
        checkResult(runtime, 6);
      });

      test('list.sort with lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.sort([3, 1, 2], (a, b) -> a - b)',
        );
        checkResult(runtime, '[1, 2, 3]');
      });

      test('list.sort descending with lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.sort([1, 3, 2], (a, b) -> b - a)',
        );
        checkResult(runtime, '[3, 2, 1]');
      });

      test('Chained higher-order functions', () {
        final RuntimeFacade runtime = getRuntime('''
main() = list.reduce(
  list.map([1, 2, 3], (x) -> x * 2),
  0,
  (acc, x) -> acc + x
)
''');
        checkResult(runtime, 12);
      });
    });

    group('Lambda in data structures', () {
      test('Lambda in list literal', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = [(x) -> x + 1, (x) -> x * 2] @ 0(5)',
        );
        checkResult(runtime, 6);
      });

      test('Lambda in list accessed by index', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = [(x) -> x + 1][0](10)',
        );
        checkResult(runtime, 11);
      });

      test('Lambda in map value', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = {"inc": (x) -> x + 1}["inc"](5)',
        );
        checkResult(runtime, 6);
      });

      test('Multiple lambdas in map', () {
        final RuntimeFacade runtime = getRuntime('''
ops() = {"add": (x) -> x + 1, "mult": (x) -> x * 2}
main() = ops()["mult"](5)
''');
        checkResult(runtime, 10);
      });
    });

    group('Lambda with control flow', () {
      test('Lambda with if body', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> if (x > 0) x else -x)(-5)',
        );
        checkResult(runtime, 5);
      });

      test('Lambda with let body', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> let y = x * 2 in y + 1)(5)',
        );
        checkResult(runtime, 11);
      });

      test('Lambda with nested if', () {
        final RuntimeFacade runtime = getRuntime('''
sign() = (x) -> if (x > 0) 1 else if (x < 0) -1 else 0
main() = sign()(-5)
''');
        checkResult(runtime, -1);
      });
    });

    group('Compose pattern', () {
      test('Function composition with lambdas', () {
        final RuntimeFacade runtime = getRuntime('''
compose(f, g) = (x) -> f(g(x))
main() = compose((x) -> x + 1, (x) -> x * 2)(3)
''');
        checkResult(runtime, 7);
      });

      test('Triple composition', () {
        final RuntimeFacade runtime = getRuntime('''
compose(f, g) = (x) -> f(g(x))
inc(x) = x + 1
double(x) = x * 2
main() = compose(inc, compose(double, inc))(5)
''');
        checkResult(runtime, 13);
      });
    });

    group('Error handling', () {
      test('Error in lambda body', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> x / 0)(5)');
        expect(
          runtime.executeMain,
          throwsA(isA<DivisionByZeroError>()),
        );
      });

      test('try catches lambda error', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = try(((x) -> x / 0)(5), 0)',
        );
        checkResult(runtime, 0);
      });

      test('Wrong arity throws error', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x, y) -> x + y)(1)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentCountError>()),
        );
      });

      test('Type mismatch in lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> x + 1)("hello")',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      });
    });

    group('Lambda toString', () {
      test('Lambda prints as function signature', () {
        final RuntimeFacade runtime = getRuntime('main() = (x) -> x');
        final String result = runtime.executeMain();
        expect(result, contains('<lambda@'));
        expect(result, contains('(x)'));
      });

      test('Multi-param lambda prints correctly', () {
        final RuntimeFacade runtime = getRuntime('main() = (a, b) -> a + b');
        final String result = runtime.executeMain();
        expect(result, contains('(a, b)'));
      });
    });

    group('Return type', () {
      test('Lambda returns LambdaTerm', () {
        final RuntimeFacade runtime = getRuntime('main() = (x) -> x');
        final Expression expression = runtime.mainExpression([]);
        final Term term = runtime.evaluateToTerm(expression);
        expect(term, isA<LambdaTerm>());
      });

      test('Applied lambda returns correct type', () {
        final RuntimeFacade runtime = getRuntime('main() = ((x) -> x)(42)');
        checkTypedResult<NumberTerm>(runtime, 42);
      });

      test('Lambda returning lambda', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> (y) -> y)(1)',
        );
        final Expression expression = runtime.mainExpression([]);
        final Term term = runtime.evaluateToTerm(expression);
        expect(term, isA<LambdaTerm>());
      });
    });

    group('Edge cases', () {
      test('Lambda immediately applied multiple times', () {
        final RuntimeFacade runtime = getRuntime('''
f() = (x) -> x + 1
main() = f()(1) + f()(2) + f()(3)
''');
        checkResult(runtime, 9);
      });

      test('Lambda with very long body', () {
        final RuntimeFacade runtime = getRuntime('''
main() = ((x) -> x + x + x + x + x + x + x + x + x + x)(1)
''');
        checkResult(runtime, 10);
      });

      test('Deeply nested closures', () {
        final RuntimeFacade runtime = getRuntime('''
f(a) = (b) -> (c) -> (d) -> a + b + c + d
main() = f(1)(2)(3)(4)
''');
        checkResult(runtime, 10);
      });

      test('Lambda with string body', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((x) -> str.concat(x, "!"))("hello")',
        );
        checkResult(runtime, '"hello!"');
      });

      test('Lambda with list operations', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = ((xs) -> list.head(xs))([1, 2, 3])',
        );
        checkResult(runtime, 1);
      });
    });

    group('Semantic errors', () {
      test('Duplicate lambda parameter', () {
        expect(
          () => getIntermediateRepresentation('f() = (x, x) -> x'),
          throwsA(isA<DuplicatedLambdaParameterError>()),
        );
      });

      test('Shadowed parameter', () {
        expect(
          () => getIntermediateRepresentation('f(x) = (x) -> x'),
          throwsA(isA<ShadowedLambdaParameterError>()),
        );
      });

      test('Undefined variable in body', () {
        expect(
          () => getIntermediateRepresentation('f() = (x) -> y'),
          throwsA(isA<UndefinedIdentifierError>()),
        );
      });
    });
  });
}
