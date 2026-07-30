import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/extensions/duration_extension.dart';

/// The shared value renderer.
///
/// Every member is static so that native functions, which see nothing but
/// [Term]s and have no route to a runtime instance, can still render a value
/// the same way the CLI renders a program's result.
class Runtime {
  const Runtime._();

  /// Renders a term for display, falling back to [Term.toString] when the
  /// value cannot be formatted.
  ///
  /// Both [format] and [Term.native] can throw (an unrecognized value and an
  /// unsubstituted bound variable respectively), so callers that render a term
  /// while building an error message must not let that escape.
  static String render(Term term) {
    try {
      return format(term.native()).toString();
    } catch (_) {
      return term.toString();
    }
  }

  static dynamic format(dynamic value) {
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

  static dynamic getList(List<dynamic> element) => element.map(format).toList();

  static dynamic getSet(Set<dynamic> element) => element.map(format).toSet();

  static dynamic getMap(Map<dynamic, dynamic> element) {
    final Map<dynamic, dynamic> result = {};

    element.forEach((key, value) {
      result[format(key)] = format(value);
    });

    return result;
  }
}
