import 'package:dry/compiler/analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/utils/list_iterator.dart';

class SyntacticAnalyzer
    extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = InitState.empty();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

      if (state is ResultState) {
        result.addAll(state.accumulated);
        state = InitState.empty();
      }
    }

    return result;
  }
}

class InitState extends State<void, Token> {
  const InitState(super.accumulated);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Token value) {
    return this;
  }
}

class ResultState extends State<List<FunctionDefinition>, void> {
  const ResultState(super.accumulated);
}
