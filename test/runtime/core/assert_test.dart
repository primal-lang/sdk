@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/assert/assert_throws.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

/// Matches an [AssertionFailedError] whose rendered message contains [message].
Matcher throwsAssertionFailure(String message) => throwsA(
  isA<AssertionFailedError>().having(
    (AssertionFailedError error) => error.toString(),
    'toString()',
    contains(message),
  ),
);

/// Matches an [AssertionArgumentError] whose rendered message contains
/// [message].
Matcher throwsAssertionArgument(String message) => throwsA(
  isA<AssertionArgumentError>().having(
    (AssertionArgumentError error) => error.toString(),
    'toString()',
    contains(message),
  ),
);

void main() {
  group('assert.equal', () {
    test('returns true for equal numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.equal(1, 1)');
      checkResult(runtime, true);
    });

    test('returns true for equal strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal("a", "a")',
      );
      checkResult(runtime, true);
    });

    test('returns true for equal collections', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal([1, 2], [1, 2])',
      );
      checkResult(runtime, true);
    });

    test('passes for an integer and its decimal representation', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.equal(1, 1.0)');
      checkResult(runtime, true);
    });

    test('fails when the values differ', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.equal(3, 2)');
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.equal" failed: expected 2, actual 3',
        ),
      );
    });

    test('renders strings with quotes, through Runtime.format', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal("3", "2")',
      );
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.equal" failed: expected "2", actual "3"',
        ),
      );
    });

    test('fails for collections of different length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal([1, 2], [1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionFailedError>()));
    });

    test('errors for operands of different kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal("1", 1)',
      );
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Invalid argument types for function "assert.equal". '
          'Expected: (Equatable, Equatable). Actual: (String, Number)',
        ),
      );
    });

    test('type error names assert.equal, not comp.eq', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal("1", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<AssertionArgumentError>().having(
            (AssertionArgumentError error) => error.toString(),
            'toString()',
            isNot(contains('comp.eq')),
          ),
        ),
      );
    });

    test('errors for equal-length lists with mismatched element kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal([1], ["x"])',
      );
      expect(
        runtime.executeMain,
        throwsAssertionArgument('Actual: (Number, String)'),
      );
    });

    test('errors for maps with mismatched value kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal({"a": 1}, {"a": "x"})',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionArgumentError>()));
    });

    test('fails, not errors, for sets with mismatched element kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal(set.new([1]), set.new(["x"]))',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionFailedError>()));
    });

    test('fails, not errors, for maps with mismatched key kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal({1: "a"}, {"1": "a"})',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionFailedError>()));
    });

    test('propagates an error raised while reducing an operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal(to.number("x"), 1)',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('propagates a type error raised by a lazily reduced element', () {
      // Collection elements are reduced inside CompEq, so an error from the
      // code under test surfaces at the same place as a comparison type error.
      // Only the latter belongs to the assertion.
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal([num.add(1, "x")], [2])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          allOf(
            isA<InvalidArgumentTypesError>(),
            isNot(isA<AssertionArgumentError>()),
            isA<InvalidArgumentTypesError>().having(
              (InvalidArgumentTypesError error) => error.function,
              'function',
              equals('num.add'),
            ),
          ),
        ),
      );
    });

    test('declares its parameters as a and b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.parameters(assert.equal)',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });
  });

  group('assert.notEqual', () {
    test('returns true when the values differ', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual(1, 2)',
      );
      checkResult(runtime, true);
    });

    test('returns true for collections of different length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual([1, 2], [1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('fails when the values are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual(1, 1)',
      );
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.notEqual" failed: expected not 1, actual 1',
        ),
      );
    });

    test('fails for an integer and its decimal representation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual(1, 1.0)',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionFailedError>()));
    });

    test('errors, rather than passing, for operands of different kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual("1", 1)',
      );
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Invalid argument types for function "assert.notEqual". '
          'Expected: (Equatable, Equatable). Actual: (String, Number)',
        ),
      );
    });

    test('type error names assert.notEqual, not comp.neq or comp.eq', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual("1", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<AssertionArgumentError>().having(
            (AssertionArgumentError error) => error.toString(),
            'toString()',
            allOf(isNot(contains('comp.neq')), isNot(contains('comp.eq'))),
          ),
        ),
      );
    });

    test('errors for equal-length lists with mismatched element kinds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual([1], ["x"])',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionArgumentError>()));
    });

    test('propagates an error raised while reducing an operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.notEqual(to.number("x"), 1)',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('declares its parameters as a and b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.parameters(assert.notEqual)',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });
  });

  group('assert.true', () {
    test('returns true for a true condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.true(true)');
      checkResult(runtime, true);
    });

    test('returns true for a true expression', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.true(1 < 2)');
      checkResult(runtime, true);
    });

    test('fails for a false condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.true(false)');
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.true" failed: expected true, actual false',
        ),
      );
    });

    test('errors for a non-boolean condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.true(1)');
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Runtime error: Invalid argument types for function "assert.true". '
          'Expected: (Boolean). Actual: (Number)',
        ),
      );
    });

    test('declares its parameter as a', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.parameters(assert.true)',
      );
      checkResult(runtime, ['"a"']);
    });
  });

  group('assert.false', () {
    test('returns true for a false condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.false(false)');
      checkResult(runtime, true);
    });

    test('fails for a true condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.false(true)');
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.false" failed: expected false, actual true',
        ),
      );
    });

    test('errors for a non-boolean condition', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.false("x")');
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Runtime error: Invalid argument types for function "assert.false". '
          'Expected: (Boolean). Actual: (String)',
        ),
      );
    });

    test('declares its parameter as a', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.parameters(assert.false)',
      );
      checkResult(runtime, ['"a"']);
    });
  });

  group('assert.throws', () {
    test('returns true when the expression throws a runtime error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(to.number("not a number"))',
      );
      checkResult(runtime, true);
    });

    test('returns true when the expression throws a custom error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(error.throw(404, "not found"))',
      );
      checkResult(runtime, true);
    });

    test('returns true for a type error raised by the code under test', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(num.add(1, "x"))',
      );
      checkResult(runtime, true);
    });

    test('fails when the expression completes normally', () {
      final RuntimeFacade runtime = getRuntime('main() = assert.throws(42)');
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.throws" failed: '
          'expected a thrown error, actual 42',
        ),
      );
    });

    test('rethrows a nested assertion failure unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(assert.equal(1, 2))',
      );
      expect(
        runtime.executeMain,
        throwsAssertionFailure(
          'Assertion error: "assert.equal" failed: expected 2, actual 1',
        ),
      );
    });

    test('rethrows a nested assertion misuse unchanged (assert.true)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(assert.true(1))',
      );
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Invalid argument types for function "assert.true"',
        ),
      );
    });

    test('rethrows a nested assertion misuse unchanged (assert.equal)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(assert.equal("1", 1))',
      );
      expect(
        runtime.executeMain,
        throwsAssertionArgument(
          'Invalid argument types for function "assert.equal"',
        ),
      );
    });

    test('absorbs a type error from a lazily reduced collection element', () {
      // The error comes from the code under test, not from the assertion, so
      // the expectation is legitimate and must pass.
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(assert.equal([num.add(1, "x")], [2]))',
      );
      checkResult(runtime, true);
    });

    test('still rethrows a genuine element-kind mismatch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.throws(assert.equal([1], ["x"]))',
      );
      expect(runtime.executeMain, throwsA(isA<AssertionArgumentError>()));
    });

    test('rethrows RecursionLimitError rather than absorbing it', () {
      final RuntimeFacade runtime = getRuntime(
        'loop(n) = loop(n + 1)\nmain() = assert.throws(loop(0))',
      );
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));
    });

    test('declares its parameter as a', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = function.parameters(assert.throws)',
      );
      checkResult(runtime, ['"a"']);
    });

    test('a value whose rendering throws still fails rather than aborting', () {
      // BoundVariableTerm.native() throws StateError, so the failure message
      // can only be built through the guarded renderer's toString() fallback.
      const AssertThrows function = AssertThrows();
      final Term term = function.term(const [BoundVariableTerm('x')]);

      expect(
        term.reduce,
        throwsAssertionFailure(
          'Assertion error: "assert.throws" failed: '
          'expected a thrown error, actual x',
        ),
      );
    });
  });

  group('composition', () {
    test('&& chains several assertions in one expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = '
        'assert.equal(str.length("abc"), 3) && '
        'assert.notEqual(str.length("abc"), 0) && '
        'assert.true(str.startsWith("abc", "a")) && '
        'assert.false(str.isEmpty("abc"))',
      );
      checkResult(runtime, true);
    });

    test('a failing assertion stops a && chain at the first failure', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.equal(1, 2) && assert.equal(3, 4)',
      );
      expect(
        runtime.executeMain,
        throwsAssertionFailure('expected 2, actual 1'),
      );
    });

    test('& chains assertions identically', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = assert.true(true) & assert.false(false)',
      );
      checkResult(runtime, true);
    });

    test('try swallows a failed assertion', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(assert.equal(1, 2), true)',
      );
      checkResult(runtime, true);
    });

    test('assert.throws cannot be abstracted behind a custom function', () {
      final RuntimeFacade runtime = getRuntime(
        'expectThrow(e) = assert.throws(e)\n'
        'main() = expectThrow(to.number("z"))',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });
  });
}
