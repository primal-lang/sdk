import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/mapper.dart';

class IntermediateCode {
  final Map<String, FunctionPrototype> functions;
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
