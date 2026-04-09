import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class MapSet extends NativeFunctionTerm {
  const MapSet()
    : super(
        name: 'map.set',
        parameters: const [
          Parameter.map('a'),
          Parameter.hashable('b'),
          Parameter.any('c'),
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
    final Term c = arguments[2];

    if ((a is MapTerm) && (b is ValueTerm)) {
      final Map<dynamic, Term> map = a.asMapWithKeys();
      map[b.value] = c.reduce();

      final Map<Term, Term> newMap = {};
      map.forEach((key, value) {
        newMap[ValueTerm.from(key)] = value;
      });

      return MapTerm(newMap);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
