import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  // TODO(momo): pass it as a parameter
  static Scope<FunctionNode> SCOPE = const Scope();

  Runtime(this.intermediateCode) {
    SCOPE = Scope(intermediateCode.functions);
  }

  bool get hasMain => intermediateCode.functions.containsKey('main');

  Expression mainExpression(List<String> arguments) {
    const Compiler compiler = Compiler();

    final FunctionNode? main = intermediateCode.functions['main'];

    if ((main != null) && main.parameters.isNotEmpty) {
      return compiler.expression('main(${arguments.join(', ')})');
    } else {
      return compiler.expression('main()');
    }
  }

  String executeMain([List<String>? arguments]) {
    final Expression expression = mainExpression(arguments ?? []);

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    // TODO(momo): evaluate expression semantically before executing it
    final Node node = expression.toNode();

    return format(node.native()).toString();
  }

  dynamic format(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is num) {
      return value;
    } else if (value is String) {
      return '"$value"';
    } else if (value is List) {
      return getList(value);
    } else if (value is Map) {
      return getMap(value);
    } else {
      throw InvalidValueError(value.toString());
    }
  }

  dynamic getList(List<dynamic> element) => element.map(format).toList();

  dynamic getMap(Map<dynamic, dynamic> element) {
    final Map<dynamic, dynamic> result = {};

    element.forEach((key, value) {
      result[format(key)] = format(value);
    });

    return result;
  }
}
