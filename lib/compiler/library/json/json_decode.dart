import 'dart:convert';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class JsonDecode extends NativeFunctionNode {
  JsonDecode()
    : super(
        name: 'json.decode',
        parameters: [
          Parameter.string('a'),
        ],
      );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class NodeWithArguments extends NativeFunctionNodeWithArguments {
  const NodeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();

    if (a is StringNode) {
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

  Node getValue(dynamic value) {
    if (value == null) {
      throw const RuntimeError('JSON null values are not supported');
    } else if (value is bool) {
      return BooleanNode(value);
    } else if (value is num) {
      return NumberNode(value);
    } else if (value is String) {
      return StringNode(value);
    } else if (value is List) {
      return getList(value);
    } else if (value is Map) {
      return getMap(value);
    } else {
      throw InvalidValueError(value.toString());
    }
  }

  ListNode getList(List<dynamic> element) =>
      ListNode(element.where((e) => e != null).map(getValue).toList());

  MapNode getMap(Map<dynamic, dynamic> element) {
    final Map<Node, Node> result = {};

    element.forEach((key, value) {
      if (value != null) {
        final Node nodeKey = LiteralNode.from(key);
        result[nodeKey] = getValue(value);
      }
    });

    return MapNode(result);
  }
}
