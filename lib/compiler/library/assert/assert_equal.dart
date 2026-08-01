import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/term.dart';

class AssertEqual extends NativeFunctionTerm {
  const AssertEqual()
    : super(
        name: 'assert_equal',
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

    final BooleanTerm comparison;

    try {
      // Passing `this` attributes a type error to "assert.equal" rather than
      // to the primitive underneath.
      comparison = CompEq.execute(
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

    if (comparison.value) {
      return const BooleanTerm(true);
    }

    throw AssertionFailedError(
      function: name,
      expected: Runtime.render(b),
      actual: Runtime.render(a),
    );
  }
}
