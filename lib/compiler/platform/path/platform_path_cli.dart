import 'package:path/path.dart' as path_library;
import 'package:primal/compiler/platform/path/platform_path_base.dart';

class PlatformPathCli extends PlatformPathBase {
  @override
  String join(String a, String b) => path_library.join(a, b);

  @override
  String dirname(String path) => path_library.dirname(path);

  @override
  String basename(String path) => path_library.basename(path);

  @override
  String extension(String path) {
    final String result = path_library.extension(path);

    return result.startsWith('.') ? result.substring(1) : result;
  }

  @override
  bool isAbsolute(String path) => path_library.isAbsolute(path);

  @override
  String normalize(String path) => path_library.normalize(path);
}
