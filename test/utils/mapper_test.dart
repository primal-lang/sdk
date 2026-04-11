@Tags(['unit'])
library;

import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/utils/mapper.dart';
import 'package:test/test.dart';

/// Test double for [FunctionTerm] since it is abstract.
class TestFunctionTerm extends FunctionTerm {
  const TestFunctionTerm({required super.name, required super.parameters});
}

void main() {
  group('Mapper', () {
    group('toMap', () {
      group('empty and single element cases', () {
        test('converts empty list to empty map', () {
          final Map<String, FunctionTerm> result = Mapper.toMap([]);
          expect(result, isEmpty);
        });

        test('converts single function to single-entry map', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(name: 'main', parameters: []),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);
          expect(result.length, 1);
          expect(result.containsKey('main'), true);
          expect(result['main']!.name, 'main');
        });

        test('converts single function with no parameters', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'noParams',
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result.length, 1);
          expect(result['noParams']!.parameters, isEmpty);
        });
      });

      group('multiple functions', () {
        test('converts multiple functions to map keyed by name', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(
              name: 'add',
              parameters: [Parameter.number('x')],
            ),
            const TestFunctionTerm(
              name: 'subtract',
              parameters: [Parameter.number('y')],
            ),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);
          expect(result.length, 2);
          expect(result.containsKey('add'), true);
          expect(result.containsKey('subtract'), true);
          expect(result['add']!.name, 'add');
          expect(result['subtract']!.name, 'subtract');
        });

        test('converts many functions correctly', () {
          final List<FunctionTerm> functions = List.generate(
            100,
            (int index) => TestFunctionTerm(
              name: 'function$index',
              parameters: const [Parameter.number('param')],
            ),
          );
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);
          expect(result.length, 100);
          for (int index = 0; index < 100; index++) {
            expect(result.containsKey('function$index'), true);
          }
        });

        test('handles functions with varying parameter counts', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(name: 'zero', parameters: []),
            const TestFunctionTerm(
              name: 'one',
              parameters: [Parameter.number('a')],
            ),
            const TestFunctionTerm(
              name: 'two',
              parameters: [Parameter.number('a'), Parameter.number('b')],
            ),
            const TestFunctionTerm(
              name: 'three',
              parameters: [
                Parameter.number('a'),
                Parameter.number('b'),
                Parameter.number('c'),
              ],
            ),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);
          expect(result.length, 4);
          expect(result['zero']!.parameters.length, 0);
          expect(result['one']!.parameters.length, 1);
          expect(result['two']!.parameters.length, 2);
          expect(result['three']!.parameters.length, 3);
        });
      });

      group('duplicate handling', () {
        test('keeps last entry when duplicate names exist', () {
          const TestFunctionTerm first = TestFunctionTerm(
            name: 'duplicate',
            parameters: [Parameter.number('a')],
          );
          const TestFunctionTerm second = TestFunctionTerm(
            name: 'duplicate',
            parameters: [Parameter.string('b')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            first,
            second,
          ]);
          expect(result.length, 1);
          expect(result['duplicate'], same(second));
        });

        test('keeps last entry with three duplicates', () {
          const TestFunctionTerm first = TestFunctionTerm(
            name: 'triple',
            parameters: [Parameter.number('x')],
          );
          const TestFunctionTerm second = TestFunctionTerm(
            name: 'triple',
            parameters: [Parameter.string('y')],
          );
          const TestFunctionTerm third = TestFunctionTerm(
            name: 'triple',
            parameters: [Parameter.boolean('z')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            first,
            second,
            third,
          ]);
          expect(result.length, 1);
          expect(result['triple'], same(third));
        });

        test('handles mixed unique and duplicate names', () {
          const TestFunctionTerm unique1 = TestFunctionTerm(
            name: 'unique1',
            parameters: [],
          );
          const TestFunctionTerm duplicateFirst = TestFunctionTerm(
            name: 'duplicate',
            parameters: [Parameter.number('a')],
          );
          const TestFunctionTerm unique2 = TestFunctionTerm(
            name: 'unique2',
            parameters: [],
          );
          const TestFunctionTerm duplicateSecond = TestFunctionTerm(
            name: 'duplicate',
            parameters: [Parameter.string('b')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            unique1,
            duplicateFirst,
            unique2,
            duplicateSecond,
          ]);
          expect(result.length, 3);
          expect(result['unique1'], same(unique1));
          expect(result['unique2'], same(unique2));
          expect(result['duplicate'], same(duplicateSecond));
        });
      });

      group('parameter types', () {
        test('handles function with boolean parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withBoolean',
            parameters: [Parameter.boolean('flag')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withBoolean']!.parameters.first.name, 'flag');
        });

        test('handles function with string parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withString',
            parameters: [Parameter.string('text')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withString']!.parameters.first.name, 'text');
        });

        test('handles function with list parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withList',
            parameters: [Parameter.list('items')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withList']!.parameters.first.name, 'items');
        });

        test('handles function with vector parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withVector',
            parameters: [Parameter.vector('elements')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withVector']!.parameters.first.name, 'elements');
        });

        test('handles function with set parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withSet',
            parameters: [Parameter.set('uniqueItems')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withSet']!.parameters.first.name, 'uniqueItems');
        });

        test('handles function with stack parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withStack',
            parameters: [Parameter.stack('stackData')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withStack']!.parameters.first.name, 'stackData');
        });

        test('handles function with queue parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withQueue',
            parameters: [Parameter.queue('queueData')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withQueue']!.parameters.first.name, 'queueData');
        });

        test('handles function with map parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withMap',
            parameters: [Parameter.map('mapping')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withMap']!.parameters.first.name, 'mapping');
        });

        test('handles function with timestamp parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withTimestamp',
            parameters: [Parameter.timestamp('time')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withTimestamp']!.parameters.first.name, 'time');
        });

        test('handles function with file parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withFile',
            parameters: [Parameter.file('inputFile')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withFile']!.parameters.first.name, 'inputFile');
        });

        test('handles function with directory parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withDirectory',
            parameters: [Parameter.directory('folder')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withDirectory']!.parameters.first.name, 'folder');
        });

        test('handles function with function parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withFunction',
            parameters: [Parameter.function('callback')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withFunction']!.parameters.first.name, 'callback');
        });

        test('handles function with any parameter', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'withAny',
            parameters: [Parameter.any('value')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['withAny']!.parameters.first.name, 'value');
        });

        test('handles function with mixed parameter types', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'mixedParameters',
            parameters: [
              Parameter.number('count'),
              Parameter.string('label'),
              Parameter.boolean('enabled'),
              Parameter.list('items'),
              Parameter.function('transformer'),
            ],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['mixedParameters']!.parameters.length, 5);
          expect(result['mixedParameters']!.parameters[0].name, 'count');
          expect(result['mixedParameters']!.parameters[1].name, 'label');
          expect(result['mixedParameters']!.parameters[2].name, 'enabled');
          expect(result['mixedParameters']!.parameters[3].name, 'items');
          expect(result['mixedParameters']!.parameters[4].name, 'transformer');
        });
      });

      group('function names', () {
        test('handles function with single character name', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'x',
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result.containsKey('x'), true);
        });

        test('handles function with long name', () {
          const String longName =
              'veryLongFunctionNameThatExceedsNormalNamingConventions';
          const TestFunctionTerm function = TestFunctionTerm(
            name: longName,
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result.containsKey(longName), true);
        });

        test('handles function with underscore in name', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'my_function_name',
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result.containsKey('my_function_name'), true);
        });

        test('handles function with numeric suffix in name', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'function123',
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result.containsKey('function123'), true);
        });

        test('distinguishes between similar names', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(name: 'func', parameters: []),
            const TestFunctionTerm(name: 'Func', parameters: []),
            const TestFunctionTerm(name: 'FUNC', parameters: []),
            const TestFunctionTerm(name: 'func1', parameters: []),
            const TestFunctionTerm(name: 'func_', parameters: []),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);
          expect(result.length, 5);
          expect(result.containsKey('func'), true);
          expect(result.containsKey('Func'), true);
          expect(result.containsKey('FUNC'), true);
          expect(result.containsKey('func1'), true);
          expect(result.containsKey('func_'), true);
        });
      });

      group('immutability and side effects', () {
        test('does not modify the original list', () {
          final List<FunctionTerm> originalList = [
            const TestFunctionTerm(name: 'first', parameters: []),
            const TestFunctionTerm(name: 'second', parameters: []),
          ];
          final int originalLength = originalList.length;
          final FunctionTerm originalFirst = originalList[0];
          final FunctionTerm originalSecond = originalList[1];

          Mapper.toMap(originalList);

          expect(originalList.length, originalLength);
          expect(originalList[0], same(originalFirst));
          expect(originalList[1], same(originalSecond));
        });

        test('returns a mutable map', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(name: 'existing', parameters: []),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);

          const TestFunctionTerm newFunction = TestFunctionTerm(
            name: 'added',
            parameters: [],
          );
          result['added'] = newFunction;

          expect(result.length, 2);
          expect(result.containsKey('added'), true);
        });

        test('modifications to returned map do not affect original list', () {
          final List<FunctionTerm> functions = [
            const TestFunctionTerm(name: 'original', parameters: []),
          ];
          final Map<String, FunctionTerm> result = Mapper.toMap(functions);

          result.remove('original');

          expect(functions.length, 1);
          expect(functions[0].name, 'original');
        });
      });

      group('identity preservation', () {
        test('preserves function term identity in map', () {
          const TestFunctionTerm function = TestFunctionTerm(
            name: 'identity',
            parameters: [Parameter.number('value')],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([function]);
          expect(result['identity'], same(function));
        });

        test('preserves all function term identities in map', () {
          const TestFunctionTerm first = TestFunctionTerm(
            name: 'first',
            parameters: [],
          );
          const TestFunctionTerm second = TestFunctionTerm(
            name: 'second',
            parameters: [],
          );
          const TestFunctionTerm third = TestFunctionTerm(
            name: 'third',
            parameters: [],
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            first,
            second,
            third,
          ]);
          expect(result['first'], same(first));
          expect(result['second'], same(second));
          expect(result['third'], same(third));
        });
      });

      group('CustomFunctionTerm integration', () {
        test('handles CustomFunctionTerm correctly', () {
          const CustomFunctionTerm customFunction = CustomFunctionTerm(
            name: 'customAdd',
            parameters: [Parameter.number('x'), Parameter.number('y')],
            term: BoundVariableTerm('x'),
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            customFunction,
          ]);
          expect(result.length, 1);
          expect(result.containsKey('customAdd'), true);
          expect(result['customAdd'], same(customFunction));
        });

        test('handles mixed TestFunctionTerm and CustomFunctionTerm', () {
          const TestFunctionTerm testFunction = TestFunctionTerm(
            name: 'testFunction',
            parameters: [Parameter.number('a')],
          );
          const CustomFunctionTerm customFunction = CustomFunctionTerm(
            name: 'customFunction',
            parameters: [Parameter.string('b')],
            term: BoundVariableTerm('b'),
          );
          final Map<String, FunctionTerm> result = Mapper.toMap([
            testFunction,
            customFunction,
          ]);
          expect(result.length, 2);
          expect(result['testFunction'], same(testFunction));
          expect(result['customFunction'], same(customFunction));
        });
      });
    });
  });
}
