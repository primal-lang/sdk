import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class QueueDequeue extends NativeFunctionTerm {
  const QueueDequeue()
    : super(
        name: 'queue.dequeue',
        parameters: const [
          Parameter.queue('a'),
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

    if (a is QueueTerm) {
      if (a.value.isEmpty) {
        throw EmptyCollectionError(function: name, collectionType: 'queue');
      }

      return QueueTerm(a.value.sublist(1));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
