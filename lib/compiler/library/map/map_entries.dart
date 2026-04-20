import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class MapEntries extends NativeFunctionTerm {
  const MapEntries()
    : super(
        name: 'map.entries',
        parameters: const [
          Parameter.map('a'),
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

    if (a is MapTerm) {
      final Map<dynamic, Term> map = a.asMapWithKeys();

      final List<Term> entries = map.entries.map((entry) {
        return ListTerm([ValueTerm.from(entry.key), entry.value]);
      }).toList();

      return ListTerm(entries);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
