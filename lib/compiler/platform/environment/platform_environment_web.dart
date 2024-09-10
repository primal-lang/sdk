import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/environment/platform_environment_base.dart';

class PlatformEnvironmentWeb extends PlatformEnvironmentBase {
  @override
  String getVariable(String name) =>
      throw const UnimplementedFunctionWebError('env.get');
}
