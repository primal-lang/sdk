import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class CompEq extends NativeFunctionTerm {
  const CompEq()
    : super(
        name: 'comp.eq',
        parameters: const [
          Parameter.equatable('a'),
          Parameter.equatable('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static BooleanTerm execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if ((a is BooleanTerm) && (b is BooleanTerm)) {
      return BooleanTerm(a.value == b.value);
    } else if ((a is NumberTerm) && (b is NumberTerm)) {
      return BooleanTerm(a.value == b.value);
    } else if ((a is StringTerm) && (b is StringTerm)) {
      return BooleanTerm(a.value == b.value);
    } else if ((a is TimestampTerm) && (b is TimestampTerm)) {
      return BooleanTerm(a.value.compareTo(b.value) == 0);
    } else if ((a is DurationTerm) && (b is DurationTerm)) {
      return BooleanTerm(a.value == b.value);
    } else if ((a is FileTerm) && (b is FileTerm)) {
      return BooleanTerm(a.value.absolute.path == b.value.absolute.path);
    } else if ((a is DirectoryTerm) && (b is DirectoryTerm)) {
      return BooleanTerm(a.value.absolute.path == b.value.absolute.path);
    } else if ((a is ListTerm) && (b is ListTerm)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is VectorTerm) && (b is VectorTerm)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is StackTerm) && (b is StackTerm)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is QueueTerm) && (b is QueueTerm)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is SetTerm) && (b is SetTerm)) {
      return compareSets(
        function: function,
        setA: a.native(),
        setB: b.native(),
      );
    } else if ((a is MapTerm) && (b is MapTerm)) {
      return compareMaps(
        function: function,
        a: a,
        b: b,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }

  static BooleanTerm compareLists({
    required FunctionTerm function,
    required List listA,
    required List listB,
  }) {
    if (listA.length != listB.length) {
      return const BooleanTerm(false);
    } else {
      for (int i = 0; i < listA.length; i++) {
        final BooleanTerm comparison = execute(
          function: function,
          a: listA[i].reduce(),
          b: listB[i].reduce(),
        );

        if (!comparison.value) {
          return const BooleanTerm(false);
        }
      }

      return const BooleanTerm(true);
    }
  }

  static BooleanTerm compareSets({
    required FunctionTerm function,
    required Set setA,
    required Set setB,
  }) {
    if (setA.length != setB.length) {
      return const BooleanTerm(false);
    } else {
      for (final dynamic element in setA) {
        if (!setB.contains(element)) {
          return const BooleanTerm(false);
        }
      }

      return const BooleanTerm(true);
    }
  }

  static BooleanTerm compareMaps({
    required FunctionTerm function,
    required MapTerm a,
    required MapTerm b,
  }) {
    if (a.value.length != b.value.length) {
      return const BooleanTerm(false);
    } else {
      final Map<dynamic, Term> mapA = a.asMapWithKeys();
      final Map<dynamic, Term> mapB = b.asMapWithKeys();

      final Set<dynamic> keys = {
        ...mapA.keys,
        ...mapB.keys,
      };

      for (final dynamic key in keys) {
        if (!mapA.containsKey(key) || !mapB.containsKey(key)) {
          return const BooleanTerm(false);
        }

        final BooleanTerm comparison = execute(
          function: function,
          a: mapA[key]!.reduce(),
          b: mapB[key]!.reduce(),
        );

        if (!comparison.value) {
          return const BooleanTerm(false);
        }
      }

      return const BooleanTerm(true);
    }
  }
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

    return CompEq.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
