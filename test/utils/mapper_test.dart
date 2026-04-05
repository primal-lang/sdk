@Tags(['unit'])
library;

import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/utils/mapper.dart';
import 'package:test/test.dart';

void main() {
  group('Mapper', () {
    test('toMap converts empty list to empty map', () {
      final Map<String, FunctionTerm> result = Mapper.toMap([]);
      expect(result, isEmpty);
    });

    test('toMap converts functions to map keyed by name', () {
      final List<FunctionTerm> functions = [
        const FunctionTerm(name: 'add', parameters: [Parameter.number('x')]),
        const FunctionTerm(name: 'sub', parameters: [Parameter.number('y')]),
      ];
      final Map<String, FunctionTerm> result = Mapper.toMap(functions);
      expect(result.length, 2);
      expect(result.containsKey('add'), true);
      expect(result.containsKey('sub'), true);
      expect(result['add']!.name, 'add');
      expect(result['sub']!.name, 'sub');
    });

    test('toMap with duplicate names keeps last entry', () {
      const FunctionTerm first = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('a')],
      );
      const FunctionTerm second = FunctionTerm(
        name: 'f',
        parameters: [Parameter.string('b')],
      );
      final Map<String, FunctionTerm> result = Mapper.toMap([first, second]);
      expect(result.length, 1);
      expect(result['f'], same(second));
    });

    test('toMap with single function', () {
      final List<FunctionTerm> functions = [
        const FunctionTerm(name: 'main', parameters: []),
      ];
      final Map<String, FunctionTerm> result = Mapper.toMap(functions);
      expect(result.length, 1);
      expect(result['main']!.name, 'main');
    });
  });
}
