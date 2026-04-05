import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class Bindings {
  final Map<String, Term> data;

  const Bindings(this.data);

  Term get(String name) {
    if (data.containsKey(name)) {
      return data[name]!;
    } else {
      throw NotFoundInScopeError(name);
    }
  }

  factory Bindings.from({
    required List<Parameter> parameters,
    required List<Term> arguments,
  }) {
    final Map<String, Term> bindings = {};

    for (int i = 0; i < parameters.length; i++) {
      bindings[parameters[i].name] = arguments[i];
    }

    return Bindings(bindings);
  }
}
