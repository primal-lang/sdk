import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/term.dart';

class AssertTrue extends NativeFunctionTerm {
  const AssertTrue()
    : super(
        name: 'assert_true',
        parameters: const [
          Parameter.boolean('a'),
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

    if (a is! BooleanTerm) {
      // Rewrapped so `assert.throws` can tell a misused assertion apart from a
      // type error legitimately raised by the code under test.
      throw AssertionArgumentError(
        InvalidArgumentTypesError(
          function: name,
          expected: parameterTypes,
          actual: [a.type],
        ),
      );
    }

    if (a.value) {
      return const BooleanTerm(true);
    }

    throw AssertionFailedError(
      function: name,
      expected: 'true',
      actual: Runtime.render(a),
    );
  }
}
