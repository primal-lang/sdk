import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_neq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/term.dart';

class AssertNotEqual extends NativeFunctionTerm {
  const AssertNotEqual()
    : super(
        name: 'assert_notEqual',
        parameters: const [
          Parameter.equatable('a'),
          Parameter.equatable('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    final Term comparison;

    try {
      // Passing `this` attributes a type error to "assert.notEqual" rather than
      // to the primitive underneath.
      comparison = CompNeq.execute(
        function: this,
        a: a,
        b: b,
      );
    } on InvalidArgumentTypesError catch (error) {
      // Only errors the comparison itself raised are rewrapped, so that
      // `assert.throws` can tell a misused assertion apart from a type error
      // legitimately raised by the code under test. Collection elements are
      // reduced lazily inside CompEq, so an error from the expression under
      // test can surface here too — that one must propagate unchanged.
      if (error.function != name) {
        rethrow;
      }

      throw AssertionArgumentError(error);
    }

    // CompNeq.execute is declared to return Term, so the result is narrowed
    // rather than assumed.
    if ((comparison is BooleanTerm) && comparison.value) {
      return const BooleanTerm(true);
    }

    throw AssertionFailedError(
      function: name,
      expected: 'not ${Runtime.render(b)}',
      actual: Runtime.render(a),
    );
  }
}
