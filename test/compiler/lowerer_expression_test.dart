@Tags(['compiler'])
library;

import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:test/test.dart';

/// Test double for [FunctionTerm] since it is abstract.
class TestFunctionTerm extends FunctionTerm {
  const TestFunctionTerm({required super.name, required super.parameters});
}

void main() {
  const Location defaultLocation = Location(row: 1, column: 1);

  // Create mock functions for testing identifier lowering
  final Map<String, FunctionTerm> functions = {
    'myVar': const TestFunctionTerm(name: 'myVar', parameters: []),
    'foo': const TestFunctionTerm(name: 'foo', parameters: []),
    'add': const TestFunctionTerm(
      name: 'add',
      parameters: [
        Parameter.number('a'),
        Parameter.number('b'),
      ],
    ),
    'outer': const TestFunctionTerm(
      name: 'outer',
      parameters: [Parameter.any('x')],
    ),
    'inner': const TestFunctionTerm(
      name: 'inner',
      parameters: [Parameter.any('x')],
    ),
  };
  final Lowerer lowerer = Lowerer(functions);

  group('Lowerer.lowerTerm', () {
    group('SemanticBooleanNode', () {
      test('lowers true', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: true,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BooleanTerm>());
        expect((term as BooleanTerm).value, isTrue);
      });

      test('lowers false', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: false,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BooleanTerm>());
        expect((term as BooleanTerm).value, isFalse);
      });
    });

    group('SemanticNumberNode', () {
      test('lowers integer', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 42,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(42));
      });

      test('lowers decimal', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 3.14,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(3.14));
      });
    });

    group('SemanticStringNode', () {
      test('lowers string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: 'hello',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals('hello'));
      });

      test('lowers empty string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: '',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals(''));
      });
    });

    group('SemanticIdentifierNode', () {
      test('lowers identifier to FunctionReferenceTerm', () {
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: defaultLocation,
          name: 'myVar',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<FunctionReferenceTerm>());
        expect((term as FunctionReferenceTerm).name, equals('myVar'));
      });
    });

    group('SemanticBoundVariableNode', () {
      test('lowers bound variable', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BoundVariableTerm>());
        expect((term as BoundVariableTerm).name, equals('x'));
      });
    });

    group('SemanticListNode', () {
      test('lowers empty list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        expect((term as ListTerm).value, isEmpty);
      });

      test('lowers list with elements', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticNumberNode(location: defaultLocation, value: 1),
            SemanticNumberNode(location: defaultLocation, value: 2),
            SemanticNumberNode(location: defaultLocation, value: 3),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(3));
        expect((list.value[0] as NumberTerm).value, equals(1));
        expect((list.value[1] as NumberTerm).value, equals(2));
        expect((list.value[2] as NumberTerm).value, equals(3));
      });

      test('lowers nested list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticListNode(
              location: defaultLocation,
              value: [
                SemanticNumberNode(location: defaultLocation, value: 1),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm outer = term as ListTerm;
        expect(outer.value.length, equals(1));
        expect(outer.value[0], isA<ListTerm>());
        final ListTerm inner = outer.value[0] as ListTerm;
        expect((inner.value[0] as NumberTerm).value, equals(1));
      });
    });

    group('SemanticMapNode', () {
      test('lowers empty map', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        expect((term as MapTerm).value, isEmpty);
      });

      test('lowers map with entries', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'a'),
              value: SemanticNumberNode(location: defaultLocation, value: 1),
            ),
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'b'),
              value: SemanticNumberNode(location: defaultLocation, value: 2),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(2));
      });
    });

    group('SemanticCallNode', () {
      test('lowers call with no arguments', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'foo',
          ),
          arguments: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.callee, isA<FunctionReferenceTerm>());
        expect((call.callee as FunctionReferenceTerm).name, equals('foo'));
        expect(call.arguments, isEmpty);
      });

      test('lowers call with arguments', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
          ),
          arguments: [
            SemanticNumberNode(location: defaultLocation, value: 1),
            SemanticNumberNode(location: defaultLocation, value: 2),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.arguments.length, equals(2));
        expect((call.arguments[0] as NumberTerm).value, equals(1));
        expect((call.arguments[1] as NumberTerm).value, equals(2));
      });

      test('lowers nested call', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'outer',
          ),
          arguments: [
            SemanticCallNode(
              location: defaultLocation,
              callee: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'inner',
              ),
              arguments: [
                SemanticNumberNode(location: defaultLocation, value: 42),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm outer = term as CallTerm;
        expect(outer.arguments.length, equals(1));
        expect(outer.arguments[0], isA<CallTerm>());
        final CallTerm inner = outer.arguments[0] as CallTerm;
        expect((inner.callee as FunctionReferenceTerm).name, equals('inner'));
      });
    });
  });
}
