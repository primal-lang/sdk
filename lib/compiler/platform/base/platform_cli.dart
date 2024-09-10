import 'package:primal/compiler/platform/base/platform_base.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/console/platform_console_cli.dart';
import 'package:primal/compiler/platform/environment/platform_environment_base.dart';
import 'package:primal/compiler/platform/environment/platform_environment_cli.dart';
import 'package:primal/compiler/platform/file/platform_file_base.dart';
import 'package:primal/compiler/platform/file/platform_file_cli.dart';

class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleCli();

  @override
  PlatformEnvironmentBase get environment => PlatformEnvironmentCli();

  @override
  PlatformFileBase get file => PlatformFileCli();
}
