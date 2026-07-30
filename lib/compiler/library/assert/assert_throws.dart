import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/term.dart';

class AssertThrows extends NativeFunctionTerm {
  const AssertThrows()
    : super(
        name: 'assert.throws',
        parameters: const [
          Parameter.any('a'),
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
    final Term outcome;

    try {
      outcome = arguments[0].reduce();
    } on AssertionFailedError {
      // A nested assertion failure is not "a throw".
      rethrow;
    } on AssertionArgumentError {
      // A nested assertion misuse is not "a throw".
      rethrow;
    } on RecursionLimitError {
      // An exhausted interpreter budget is not an expectation the test made.
      rethrow;
    } on RuntimeError {
      return const BooleanTerm(true);
    }
    // Anything that is not a RuntimeError is deliberately not caught: an
    // interpreter defect must not be masked as a satisfied expectation.

    // Thrown outside the guarded region on purpose. AssertionFailedError is a
    // RuntimeError, so throwing it inside would let the clause above swallow it
    // and make `assert.throws(42)` pass.
    throw AssertionFailedError(
      function: name,
      expected: 'a thrown error',
      actual: Runtime.render(outcome),
    );
  }
}
