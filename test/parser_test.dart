import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/parser.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Parser', () {
    test('Expression 1', () {
      final List<Token> tokens = getTokens('(2 - 1) * 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      print(expression.text);
    });
  });
}
