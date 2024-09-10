import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/environment/platform_environment_base.dart';
import 'package:primal/compiler/platform/file/platform_file_base.dart';

abstract class PlatformBase {
  PlatformConsoleBase get console;

  PlatformEnvironmentBase get environment;

  PlatformFileBase get file;
}
