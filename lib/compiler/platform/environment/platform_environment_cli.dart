import 'dart:io';
import 'package:primal/compiler/platform/environment/platform_environment_base.dart';

class PlatformEnvironmentCli extends PlatformEnvironmentBase {
  @override
  String getVariable(String name) => Platform.environment[name] ?? '';
}
