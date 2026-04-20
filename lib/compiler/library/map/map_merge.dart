import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class MapMerge extends NativeFunctionTerm {
  const MapMerge()
    : super(
        name: 'map.merge',
        parameters: const [
          Parameter.map('a'),
          Parameter.map('b'),
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

    if ((a is MapTerm) && (b is MapTerm)) {
      final Map<dynamic, Term> mapA = a.asMapWithKeys();
      final Map<dynamic, Term> mapB = b.asMapWithKeys();

      // Merge b into a (b overrides a)
      final Map<dynamic, Term> merged = {...mapA, ...mapB};

      final Map<Term, Term> result = {};
      merged.forEach((key, value) {
        result[ValueTerm.from(key)] = value;
      });

      return MapTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
