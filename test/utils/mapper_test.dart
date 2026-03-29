@Tags(['unit'])
library;

import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/utils/mapper.dart';
import 'package:test/test.dart';

void main() {
  group('Mapper', () {
    test('toMap converts empty list to empty map', () {
      final Map<String, FunctionNode> result = Mapper.toMap([]);
      expect(result, isEmpty);
    });

    test('toMap converts functions to map keyed by name', () {
      final List<FunctionNode> functions = [
        FunctionNode(name: 'add', parameters: [Parameter.number('x')]),
        FunctionNode(name: 'sub', parameters: [Parameter.number('y')]),
      ];
      final Map<String, FunctionNode> result = Mapper.toMap(functions);
      expect(result.length, 2);
      expect(result.containsKey('add'), true);
      expect(result.containsKey('sub'), true);
      expect(result['add']!.name, 'add');
      expect(result['sub']!.name, 'sub');
    });

    test('toMap with duplicate names keeps last entry', () {
      final FunctionNode first = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('a')],
      );
      final FunctionNode second = FunctionNode(
        name: 'f',
        parameters: [Parameter.string('b')],
      );
      final Map<String, FunctionNode> result = Mapper.toMap([first, second]);
      expect(result.length, 1);
      expect(result['f'], same(second));
    });

    test('toMap with single function', () {
      final List<FunctionNode> functions = [
        const FunctionNode(name: 'main', parameters: []),
      ];
      final Map<String, FunctionNode> result = Mapper.toMap(functions);
      expect(result.length, 1);
      expect(result['main']!.name, 'main');
    });
  });
}
