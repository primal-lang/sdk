import 'package:primal/compiler/platform/path/platform_path_base.dart';

class PlatformPathWeb extends PlatformPathBase {
  @override
  String join(String a, String b) {
    if (a.isEmpty) {
      return b;
    }

    if (b.isEmpty) {
      return a;
    }

    final bool aEndsWithSeparator = a.endsWith('/');
    final bool bStartsWithSeparator = b.startsWith('/');

    if (aEndsWithSeparator && bStartsWithSeparator) {
      return a + b.substring(1);
    } else if (aEndsWithSeparator || bStartsWithSeparator) {
      return a + b;
    } else {
      return '$a/$b';
    }
  }

  @override
  String dirname(String path) {
    if (path.isEmpty) {
      return '.';
    }

    final String normalized = path.replaceAll(RegExp(r'/+$'), '');

    if (normalized.isEmpty) {
      return '/';
    }

    final int lastSeparator = normalized.lastIndexOf('/');

    if (lastSeparator == -1) {
      return '.';
    }

    if (lastSeparator == 0) {
      return '/';
    }

    return normalized.substring(0, lastSeparator);
  }

  @override
  String basename(String path) {
    if (path.isEmpty) {
      return '';
    }

    final String normalized = path.replaceAll(RegExp(r'/+$'), '');

    if (normalized.isEmpty) {
      return '';
    }

    final int lastSeparator = normalized.lastIndexOf('/');

    if (lastSeparator == -1) {
      return normalized;
    }

    return normalized.substring(lastSeparator + 1);
  }

  @override
  String extension(String path) {
    final String name = basename(path);

    if (name.isEmpty) {
      return '';
    }

    final int dotIndex = name.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == 0 || dotIndex == name.length - 1) {
      return '';
    }

    return name.substring(dotIndex + 1);
  }

  @override
  bool isAbsolute(String path) => path.startsWith('/');

  @override
  String normalize(String path) {
    if (path.isEmpty) {
      return '.';
    }

    final bool isAbsolutePath = path.startsWith('/');
    final List<String> segments = path.split('/');
    final List<String> result = [];

    for (final String segment in segments) {
      if (segment == '.' || segment.isEmpty) {
        continue;
      } else if (segment == '..') {
        if (result.isNotEmpty && result.last != '..') {
          result.removeLast();
        } else if (!isAbsolutePath) {
          result.add('..');
        }
      } else {
        result.add(segment);
      }
    }

    if (result.isEmpty) {
      return isAbsolutePath ? '/' : '.';
    }

    final String normalized = result.join('/');

    return isAbsolutePath ? '/$normalized' : normalized;
  }
}
