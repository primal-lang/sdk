import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/set/set_add.dart';
import 'package:primal/compiler/library/set/set_union.dart';
import 'package:primal/compiler/library/vector/vector_add.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorAdd extends NativeFunctionTerm {
  const OperatorAdd()
    : super(
        name: '+',
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
      return NumberTerm(a.value + b.value);
    } else if ((a is StringTerm) && (b is StringTerm)) {
      return StringTerm(a.value + b.value);
    } else if ((a is VectorTerm) && (b is VectorTerm)) {
      return VectorAdd.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is ListTerm) && (b is ListTerm)) {
      return ListTerm([...a.value, ...b.value]);
    } else if ((a is ListTerm) && (b is! ListTerm)) {
      return ListTerm([...a.value, b]);
    } else if ((a is! ListTerm) && (b is ListTerm)) {
      return ListTerm([a, ...b.value]);
    } else if ((a is SetTerm) && (b is SetTerm)) {
      return SetUnion.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is SetTerm) && (b is! SetTerm)) {
      return SetAdd.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is! SetTerm) && (b is SetTerm)) {
      return SetAdd.execute(
        function: this,
        a: b,
        b: a,
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
