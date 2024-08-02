import 'package:purified/compiler/library/standard_library.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';
import 'package:purified/compiler/warnings/generic_warning.dart';
import 'package:purified/utils/mapper.dart';

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
