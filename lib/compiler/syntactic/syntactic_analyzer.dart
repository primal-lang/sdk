import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/utils/list_iterator.dart';

class SyntacticAnalyzer {
  final List<Token> tokens;

  const SyntacticAnalyzer({required this.tokens});

  List<FunctionDefinition> analyze() {
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
  final List<FunctionDefinition> result = [];

  void process(Token token) {
    switch (state) {
      case State.init:
        _processInit(token);
        break;
    }
  }

  void _processInit(Token token) {
    print(token);
  }
}

enum State {
  init,
}
