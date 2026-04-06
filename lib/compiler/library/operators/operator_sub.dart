import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/set/set_difference.dart';
import 'package:primal/compiler/library/set/set_remove.dart';
import 'package:primal/compiler/library/vector/vector_sub.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorSub extends NativeFunctionTerm {
  const OperatorSub()
    : super(
        name: '-',
        parameters: const [
          Parameter.any('a'),
          Parameter.any('b'),
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

    if ((a is NumberTerm) && (b is NumberTerm)) {
      return NumberTerm(a.value - b.value);
    } else if ((a is VectorTerm) && (b is VectorTerm)) {
      return VectorSub.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is SetTerm) && (b is SetTerm)) {
      return SetDifference.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is SetTerm) && (b is! SetTerm)) {
      return SetRemove.execute(
        function: this,
        a: a,
        b: b,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
