import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';

class Runtime {
  final RuntimeInput input;

  const Runtime(this.input);

  Node reduceNode(Node node) => node.reduce();

  dynamic format(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is num) {
      return value;
    } else if (value is String) {
      return '"$value"';
    } else if (value is DateTime) {
      return '"${value.toIso8601String()}"';
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
