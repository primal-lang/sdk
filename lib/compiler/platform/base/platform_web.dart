import 'package:primal/compiler/platform/base/platform_base.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/console/platform_console_web.dart';
import 'package:primal/compiler/platform/environment/platform_environment_base.dart';
import 'package:primal/compiler/platform/environment/platform_environment_web.dart';
import 'package:primal/compiler/platform/file/platform_file_base.dart';
import 'package:primal/compiler/platform/file/platform_file_web.dart';

class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleWeb();

  @override
  PlatformEnvironmentBase get environment => PlatformEnvironmentWeb();

  @override
  PlatformFileBase get file => PlatformFileWeb();
}
