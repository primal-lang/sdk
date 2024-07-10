import 'package:dry/models/abstract_syntax_tree.dart';
import 'package:dry/models/token.dart';
import 'package:dry/utils/list_iterator.dart';

class SyntacticAnalyzer {
  final List<Token> tokens;

  const SyntacticAnalyzer({required this.tokens});

  AbstractSyntaxTree analyze() {
    final ListIterator<Token> iterator = ListIterator(tokens);

    final StateMachine stateMachine = StateMachine();

    while (iterator.hasNext) {
      stateMachine.process(iterator.next);
    }

    return stateMachine.result;
  }
}

class StateMachine {
  String accumulated = '';
  State state = State.init;
  final AbstractSyntaxTree result = AbstractSyntaxTree();

  void process(Token token) {
    switch (state) {
      case State.init:
        _processInit(token);
        break;
    }
  }

  void _processInit(Token token) {}
}

enum State {
  init,
}
