import 'dart:convert';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class JsonDecode extends NativeFunctionTerm {
  const JsonDecode()
    : super(
        name: 'json.decode',
        parameters: const [
          Parameter.string('a'),
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

    if (a is StringTerm) {
      final dynamic json;
      try {
        json = jsonDecode(a.value);
      } on FormatException catch (e) {
        throw JsonParseError(input: a.value, details: e.message);
      }

      return getValue(json);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }

  Term getValue(dynamic value) {
    if (value == null) {
      throw const RuntimeError('JSON null values are not supported');
    } else if (value is bool) {
      return BooleanTerm(value);
    } else if (value is num) {
      return NumberTerm(value);
    } else if (value is String) {
      return StringTerm(value);
    } else if (value is List) {
      return getList(value);
    } else if (value is Map) {
      return getMap(value);
    } else {
      throw InvalidValueError(value.toString());
    }
  }

  ListTerm getList(List<dynamic> element) =>
      ListTerm(element.where((e) => e != null).map(getValue).toList());

  MapTerm getMap(Map<dynamic, dynamic> element) {
    final Map<Term, Term> result = {};

    element.forEach((key, value) {
      if (value != null) {
        final Term termKey = ValueTerm.from(key);
        result[termKey] = getValue(value);
      }
    });

    return MapTerm(result);
  }
}
