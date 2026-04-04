@Tags(['runtime'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Division and Modulo Edge Cases', () {
    test('division by zero produces infinity', () {
      final RuntimeFacade runtime = getRuntime('main = 1 / 0');
      checkResult(runtime, double.infinity);
    });

    test('negative division by zero produces negative infinity', () {
      final RuntimeFacade runtime = getRuntime('main = -1 / 0');
      checkResult(runtime, double.negativeInfinity);
    });

    test('modulo by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = 1 % 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            contains('Division by zero'),
          ),
        ),
      );
    });

    test('zero divided by zero produces NaN', () {
      final RuntimeFacade runtime = getRuntime('main = 0 / 0');
      expect(runtime.executeMain(), 'NaN');
    });
  });

  group('Empty Collection Errors', () {
    test('stack.pop on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot pop from an empty stack'),
          ),
        ),
      );
    });

    test('stack.peek on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot peek from an empty stack'),
          ),
        ),
      );
    });

    test('queue.dequeue on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot dequeue from an empty queue'),
          ),
        ),
      );
    });

    test('queue.peek on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot peek from an empty queue'),
          ),
        ),
      );
    });
  });

  group('Map Access Errors', () {
    test('map.at with non-existent key has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"a": 1, "b": 2}, "c")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidMapIndexError>().having(
            (e) => e.toString(),
            'message',
            contains('"c"'),
          ),
        ),
      );
    });
  });

  group('Vector Length Mismatch', () {
    test('vector.add with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1]), vector.new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });

    test('vector.sub with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2, 3, 4]), vector.new([1]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });
  });

  group('Type Conversion Errors', () {
    test('to.number throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.number("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('number'),
            ),
          ),
        ),
      );
    });

    test('to.integer throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('integer'),
            ),
          ),
        ),
      );
    });

    test('to.decimal throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('decimal'),
            ),
          ),
        ),
      );
    });
  });

  group('Custom Errors', () {
    test('error.throw raises CustomError with message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(42, "test error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('test error'),
          ),
        ),
      );
    });

    test('try catches error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(0, "oops"), "recovered")',
      );
      checkResult(runtime, '"recovered"');
    });

    test('try catches type error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 + true, -1)');
      checkResult(runtime, -1);
    });
  });

  group('Invalid Argument Count', () {
    test('too few arguments throws InvalidArgumentCountError', () {
      final RuntimeFacade runtime = getRuntime(
        'apply(f, x) = f(x)\nadd(a, b) = a + b\nmain = apply(add, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 1'),
            ),
          ),
        ),
      );
    });

    test('too many arguments throws InvalidArgumentCountError', () {
      final RuntimeFacade runtime = getRuntime(
        'apply(f, x, y, z) = f(x, y, z)\nadd(a, b) = a + b\nmain = apply(add, 1, 2, 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 3'),
            ),
          ),
        ),
      );
    });
  });

  group('Runtime Format Errors', () {
    test('format with unsupported type throws InvalidValueError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.format(Object()),
        throwsA(isA<InvalidValueError>()),
      );
    });
  });

  group('Cross-Type Comparison Errors', () {
    test('list equals string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2] == "hello"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map equals list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1} == [1]');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Dynamic Callability Errors', () {
    test(
      'calling function result that is not callable throws InvalidFunctionError',
      () {
        final RuntimeFacade runtime = getRuntime('''
getVal(x) = x
main = getVal(5)(1)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidFunctionError>()),
        );
      },
    );

    test(
      'indexing non-indexable variable throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('''
getVal(x) = x
main = getVal(true)[0]
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });

  group('Runtime.evaluate() Semantic Validation', () {
    const Compiler compiler = Compiler();

    test('undefined function throws UndefinedFunctionError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('foo()')),
        throwsA(
          isA<UndefinedFunctionError>().having(
            (e) => e.toString(),
            'message',
            contains('foo'),
          ),
        ),
      );
    });

    test('wrong arity throws InvalidNumberOfArgumentsError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('num.add(1)')),
        throwsA(
          isA<InvalidNumberOfArgumentsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num.add'),
              contains('expected 2'),
              contains('got 1'),
            ),
          ),
        ),
      );
    });

    test('non-callable literal throws NotCallableError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('5(1)')),
        throwsA(
          isA<NotCallableError>().having(
            (e) => e.toString(),
            'message',
            contains('number'),
          ),
        ),
      );
    });

    test('non-indexable literal throws NotIndexableError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('5[0]')),
        throwsA(
          isA<NotIndexableError>().having(
            (e) => e.toString(),
            'message',
            contains('number'),
          ),
        ),
      );
    });
  });
}
