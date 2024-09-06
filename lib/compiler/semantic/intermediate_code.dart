import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/mapper.dart';

class IntermediateCode {
  final Map<String, FunctionNode> functions;
  final List<GenericWarning> warnings;

  IntermediateCode({
    required this.functions,
    required this.warnings,
  });

  factory IntermediateCode.empty() => IntermediateCode(
        functions: Mapper.toMap(StandardLibrary.get()),
        warnings: [],
      );
}
