import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/extensions/duration_extension.dart';

class Runtime {
  final RuntimeInput input;

  const Runtime(this.input);

  Term reduceTerm(Term term) => term.reduce();

  dynamic format(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is num) {
      return value;
    } else if (value is String) {
      return '"$value"';
    } else if (value is DateTime) {
      return '"${value.toIso8601String()}"';
    } else if (value is Duration) {
      return '"${value.toFormattedString()}"';
    } else if (value is File) {
      return '"${value.absolute.path}"';
    } else if (value is Directory) {
      return '"${value.absolute.path}"';
    } else if (value is Set) {
      return getSet(value);
    } else if (value is List) {
      return getList(value);
    } else if (value is Map) {
      return getMap(value);
    } else {
      throw InvalidValueError(value.toString());
    }
  }

  dynamic getList(List<dynamic> element) => element.map(format).toList();

  dynamic getSet(Set<dynamic> element) => element.map(format).toSet();

  dynamic getMap(Map<dynamic, dynamic> element) {
    final Map<dynamic, dynamic> result = {};

    element.forEach((key, value) {
      result[format(key)] = format(value);
    });

    return result;
  }
}
