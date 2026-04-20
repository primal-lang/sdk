import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListChunk extends NativeFunctionTerm {
  const ListChunk()
    : super(
        name: 'list.chunk',
        parameters: const [
          Parameter.list('a'),
          Parameter.number('b'),
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

    if ((a is ListTerm) && (b is NumberTerm)) {
      final int chunkSize = b.value.toInt();

      if (chunkSize < 0) {
        throw NegativeIndexError(function: name, index: chunkSize);
      }

      if (chunkSize == 0) {
        throw const InvalidValueError('Chunk size must be positive, got 0');
      }

      final List<Term> result = [];
      final List<Term> elements = a.value;

      for (int i = 0; i < elements.length; i += chunkSize) {
        final int end = (i + chunkSize < elements.length)
            ? i + chunkSize
            : elements.length;
        result.add(ListTerm(elements.sublist(i, end)));
      }

      return ListTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
