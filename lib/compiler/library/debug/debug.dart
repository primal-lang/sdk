import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class Debug extends NativeFunctionTerm {
  const Debug()
    : super(
        name: 'debug',
        parameters: const [
          Parameter.string('a'),
          Parameter.any('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => DebugTermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class DebugTermWithArguments extends NativeFunctionTermWithArguments {
  const DebugTermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    // Evaluate label first (left-to-right order for error propagation)
    final Term label = arguments[0].reduce();

    // Verify label is a string
    if (label is! StringTerm) {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [label.type, arguments[1].reduce().type],
      );
    }

    // Evaluate and deep-reduce the value
    final Term value = arguments[1].reduce();
    final Term deeplyReducedValue = _deepReduce(value);

    // Print formatted output
    final String output = '[debug] ${label.value}: $deeplyReducedValue';
    PlatformInterface().console.outWriteLn(output);

    return deeplyReducedValue;
  }

  /// Recursively reduces a term and all nested elements within collections.
  ///
  /// This ensures that computed values are shown in output, and the return
  /// value contains fully evaluated elements.
  Term _deepReduce(Term term) {
    final Term reduced = term.reduce();
    return switch (reduced) {
      ListTerm() => ListTerm(reduced.value.map(_deepReduce).toList()),
      VectorTerm() => VectorTerm(reduced.value.map(_deepReduce).toList()),
      StackTerm() => StackTerm(reduced.value.map(_deepReduce).toList()),
      QueueTerm() => QueueTerm(reduced.value.map(_deepReduce).toList()),
      SetTerm() => SetTerm(reduced.value.map(_deepReduce).toSet()),
      MapTerm() => MapTerm(
        Map<Term, Term>.fromEntries(
          reduced.value.entries.map(
            (MapEntry<Term, Term> entry) => MapEntry<Term, Term>(
              _deepReduce(entry.key),
              _deepReduce(entry.value),
            ),
          ),
        ),
      ),
      _ => reduced, // Primitives, functions, etc. are already fully reduced
    };
  }
}
