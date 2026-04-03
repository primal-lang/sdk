import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'pipeline_helpers.dart';

void main(List<String> args) {
  final String source = args[0];
  final RuntimeFacade runtime = getRuntime(source);

  print(runtime.executeMain());
}
