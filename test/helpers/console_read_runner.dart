import 'package:primal/compiler/runtime/runtime.dart';
import 'pipeline_helpers.dart';

void main(List<String> args) {
  final String source = args[0];
  final Runtime runtime = getRuntime(source);

  print(runtime.executeMain());
}
