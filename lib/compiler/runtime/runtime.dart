import 'dart:io';
import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;
  final Map<String, FunctionNode> _loweredFunctions;

  static Scope<FunctionNode> SCOPE = const Scope();

  Runtime(this.intermediateCode)
    : _loweredFunctions = _lowerFunctions(intermediateCode) {
    SCOPE = Scope(_loweredFunctions);
  }

  static Map<String, FunctionNode> _lowerFunctions(IntermediateCode code) {
    const Lowerer lowerer = Lowerer();
    final Map<String, FunctionNode> result = {...code.standardLibrary};

    for (final function in code.customFunctions.values) {
      result[function.name] = lowerer.lowerFunction(function);
    }

    return result;
  }

  bool get hasMain => intermediateCode.containsFunction('main');

  Expression mainExpression(List<String> arguments) {
    const Compiler compiler = Compiler();

    final FunctionNode? main = _loweredFunctions['main'];

    if ((main != null) && main.parameters.isNotEmpty) {
      return compiler.expression(
        'main(${arguments.map((e) => '"$e"').join(', ')})',
      );
    } else {
      return compiler.expression('main()');
    }
  }

  String executeMain([List<String>? arguments]) {
    final Expression expression = mainExpression(arguments ?? []);

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    final Node validated = SemanticAnalyzer.validateExpression(
      expression.toNode(),
      _loweredFunctions,
    );
    final Node result = validated.evaluate();

    return format(result.native()).toString();
  }

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
