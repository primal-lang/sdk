@Tags(['compiler'])
library;

import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:test/test.dart';

void main() {
  const lowerer = Lowerer();
  const defaultLocation = Location(row: 1, column: 1);

  BooleanToken boolToken(bool value) => BooleanToken(
    Lexeme(value: value.toString(), location: defaultLocation),
  );

  NumberToken numToken(num value) => NumberToken(
    Lexeme(value: value.toString(), location: defaultLocation),
  );

  StringToken strToken(String value) => StringToken(
    Lexeme(value: value, location: defaultLocation),
  );

  IdentifierToken idToken(String value) => IdentifierToken(
    Lexeme(value: value, location: defaultLocation),
  );

  group('Lowerer.lowerExpression', () {
    group('BooleanExpression', () {
      test('lowers true', () {
        final expression = BooleanExpression(boolToken(true));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<BooleanNode>());
        expect((node as BooleanNode).value, isTrue);
      });

      test('lowers false', () {
        final expression = BooleanExpression(boolToken(false));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<BooleanNode>());
        expect((node as BooleanNode).value, isFalse);
      });
    });

    group('NumberExpression', () {
      test('lowers integer', () {
        final expression = NumberExpression(numToken(42));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<NumberNode>());
        expect((node as NumberNode).value, equals(42));
      });

      test('lowers decimal', () {
        final expression = NumberExpression(numToken(3.14));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<NumberNode>());
        expect((node as NumberNode).value, equals(3.14));
      });
    });

    group('StringExpression', () {
      test('lowers string', () {
        final expression = StringExpression(strToken('hello'));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<StringNode>());
        expect((node as StringNode).value, equals('hello'));
      });

      test('lowers empty string', () {
        final expression = StringExpression(strToken(''));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<StringNode>());
        expect((node as StringNode).value, equals(''));
      });
    });

    group('IdentifierExpression', () {
      test('lowers identifier', () {
        final expression = IdentifierExpression(idToken('myVar'));
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<IdentifierNode>());
        expect((node as IdentifierNode).value, equals('myVar'));
      });
    });

    group('ListExpression', () {
      test('lowers empty list', () {
        const expression = ListExpression(
          location: defaultLocation,
          value: [],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<ListNode>());
        expect((node as ListNode).value, isEmpty);
      });

      test('lowers list with elements', () {
        final expression = ListExpression(
          location: defaultLocation,
          value: [
            NumberExpression(numToken(1)),
            NumberExpression(numToken(2)),
            NumberExpression(numToken(3)),
          ],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<ListNode>());
        final list = node as ListNode;
        expect(list.value.length, equals(3));
        expect((list.value[0] as NumberNode).value, equals(1));
        expect((list.value[1] as NumberNode).value, equals(2));
        expect((list.value[2] as NumberNode).value, equals(3));
      });

      test('lowers nested list', () {
        final expression = ListExpression(
          location: defaultLocation,
          value: [
            ListExpression(
              location: defaultLocation,
              value: [NumberExpression(numToken(1))],
            ),
          ],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<ListNode>());
        final outer = node as ListNode;
        expect(outer.value.length, equals(1));
        expect(outer.value[0], isA<ListNode>());
        final inner = outer.value[0] as ListNode;
        expect((inner.value[0] as NumberNode).value, equals(1));
      });
    });

    group('MapExpression', () {
      test('lowers empty map', () {
        const expression = MapExpression(
          location: defaultLocation,
          value: [],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<MapNode>());
        expect((node as MapNode).value, isEmpty);
      });

      test('lowers map with entries', () {
        final expression = MapExpression(
          location: defaultLocation,
          value: [
            MapEntryExpression(
              location: defaultLocation,
              key: StringExpression(strToken('a')),
              value: NumberExpression(numToken(1)),
            ),
            MapEntryExpression(
              location: defaultLocation,
              key: StringExpression(strToken('b')),
              value: NumberExpression(numToken(2)),
            ),
          ],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<MapNode>());
        final map = node as MapNode;
        expect(map.value.length, equals(2));
      });
    });

    group('CallExpression', () {
      test('lowers call with no arguments', () {
        final expression = CallExpression(
          callee: IdentifierExpression(idToken('foo')),
          arguments: [],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<CallNode>());
        final call = node as CallNode;
        expect(call.callee, isA<IdentifierNode>());
        expect((call.callee as IdentifierNode).value, equals('foo'));
        expect(call.arguments, isEmpty);
      });

      test('lowers call with arguments', () {
        final expression = CallExpression(
          callee: IdentifierExpression(idToken('add')),
          arguments: [
            NumberExpression(numToken(1)),
            NumberExpression(numToken(2)),
          ],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<CallNode>());
        final call = node as CallNode;
        expect(call.arguments.length, equals(2));
        expect((call.arguments[0] as NumberNode).value, equals(1));
        expect((call.arguments[1] as NumberNode).value, equals(2));
      });

      test('lowers nested call', () {
        final expression = CallExpression(
          callee: IdentifierExpression(idToken('outer')),
          arguments: [
            CallExpression(
              callee: IdentifierExpression(idToken('inner')),
              arguments: [NumberExpression(numToken(42))],
            ),
          ],
        );
        final node = lowerer.lowerExpression(expression);

        expect(node, isA<CallNode>());
        final outer = node as CallNode;
        expect(outer.arguments.length, equals(1));
        expect(outer.arguments[0], isA<CallNode>());
        final inner = outer.arguments[0] as CallNode;
        expect((inner.callee as IdentifierNode).value, equals('inner'));
      });
    });
  });
}
