import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class MapAt extends NativeFunctionTerm {
  const MapAt()
    : super(
        name: 'map.at',
        parameters: const [
          Parameter.map('a'),
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

    if ((a is MapTerm) && (b is LiteralTerm)) {
      final Map<dynamic, Term> map = a.asMapWithKeys();
      final dynamic key = b.native();

      if (map.containsKey(key)) {
        return map[key]!;
      } else {
        throw InvalidMapIndexError(key);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
