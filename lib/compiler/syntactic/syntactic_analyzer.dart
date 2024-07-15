import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/analyzer.dart';
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
        result.addAll(state.output);
        state = InitState.empty();
      }
    }

    return result;
  }
}

class InitState extends State<Token, void> {
  const InitState(super.output);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Token input) {
    return this;
  }
}

class ResultState extends State<void, List<FunctionDefinition>> {
  const ResultState(super.output);
}
