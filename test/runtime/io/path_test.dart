@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Path', () {
    group('path_join', () {
      test('joins two path segments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("/home/user", "file.txt")',
        );
        checkResult(runtime, '"/home/user/file.txt"');
      });

      test('joins relative paths', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("folder", "subfolder")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('handles trailing separator in first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("/home/user/", "file.txt")',
        );
        checkResult(runtime, '"/home/user/file.txt"');
      });

      test('handles leading separator in second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("/home/user", "/file.txt")',
        );
        // Absolute second path replaces first
        final String result = runtime.executeMain();
        expect(result.contains('file.txt'), isTrue);
      });

      test('joins empty first segment', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("", "file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('joins empty second segment', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("/home/user", "")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('joins two empty segments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("", "")',
        );
        checkResult(runtime, '""');
      });
    });

    group('path_dirname', () {
      test('extracts directory from absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("/home/user/file.txt")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('extracts directory from relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("folder/subfolder/file.txt")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('returns dot for filename only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("file.txt")',
        );
        checkResult(runtime, '"."');
      });

      test('returns slash for root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("/")',
        );
        checkResult(runtime, '"/"');
      });

      test('handles path with trailing slash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("/home/user/")',
        );
        checkResult(runtime, '"/home"');
      });

      test('returns dot for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("")',
        );
        checkResult(runtime, '"."');
      });

      test('returns slash for file in root', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname("/file.txt")',
        );
        checkResult(runtime, '"/"');
      });
    });

    group('path_basename', () {
      test('extracts filename from absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("/home/user/file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('extracts filename from relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("folder/subfolder/file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('returns filename when no directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('extracts last directory name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("/home/user")',
        );
        checkResult(runtime, '"user"');
      });

      test('handles trailing slash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("/home/user/")',
        );
        checkResult(runtime, '"user"');
      });

      test('returns empty for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("")',
        );
        checkResult(runtime, '""');
      });

      test('handles hidden files', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename("/home/user/.gitignore")',
        );
        checkResult(runtime, '".gitignore"');
      });
    });

    group('path_extension', () {
      test('extracts extension from filename', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("/home/user/file.txt")',
        );
        checkResult(runtime, '"txt"');
      });

      test('extracts last extension from multiple dots', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("archive.tar.gz")',
        );
        checkResult(runtime, '"gz"');
      });

      test('returns empty for no extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("Makefile")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty for hidden file without extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension(".gitignore")',
        );
        checkResult(runtime, '""');
      });

      test('extracts extension from hidden file with extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension(".config.json")',
        );
        checkResult(runtime, '"json"');
      });

      test('returns empty for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty for path ending with dot', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("file.")',
        );
        checkResult(runtime, '""');
      });

      test('handles multiple consecutive dots', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension("file..txt")',
        );
        checkResult(runtime, '"txt"');
      });
    });

    group('path_isAbsolute', () {
      test('returns true for absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("/home/user")',
        );
        checkResult(runtime, true);
      });

      test('returns false for relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("folder/file.txt")',
        );
        checkResult(runtime, false);
      });

      test('returns false for dot-relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("./relative")',
        );
        checkResult(runtime, false);
      });

      test('returns false for double-dot path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("../parent")',
        );
        checkResult(runtime, false);
      });

      test('returns false for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("")',
        );
        checkResult(runtime, false);
      });

      test('returns true for root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("/")',
        );
        checkResult(runtime, true);
      });

      test('returns false for filename only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute("file.txt")',
        );
        checkResult(runtime, false);
      });
    });

    group('path_normalize', () {
      test('resolves parent directory references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/home/user/../other")',
        );
        checkResult(runtime, '"/home/other"');
      });

      test('removes current directory references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/home/./user")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('removes redundant separators', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/home//user///file")',
        );
        checkResult(runtime, '"/home/user/file"');
      });

      test('normalizes relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("./folder/./subfolder")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('returns dot for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("")',
        );
        checkResult(runtime, '"."');
      });

      test('returns dot for current directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize(".")',
        );
        checkResult(runtime, '"."');
      });

      test('handles multiple parent references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/a/b/c/../../d")',
        );
        checkResult(runtime, '"/a/d"');
      });

      test('preserves leading double-dot for relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("../folder")',
        );
        checkResult(runtime, '"../folder"');
      });

      test('normalizes root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/")',
        );
        checkResult(runtime, '"/"');
      });

      test('handles complex path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize("/a/b/../c/./d/../e")',
        );
        checkResult(runtime, '"/a/c/e"');
      });
    });

    group('type errors', () {
      test('path_join throws for number first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join(123, "file.txt")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_join throws for number second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join("/home", 456)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_join throws for boolean arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join(true, false)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_join throws for list arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_join([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_dirname throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_dirname throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_dirname throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_dirname([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_basename throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_basename throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_basename throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_basename([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_extension throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_extension throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_extension throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_extension([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_isAbsolute throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_isAbsolute throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_isAbsolute throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_isAbsolute([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_normalize throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_normalize throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path_normalize throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path_normalize([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });
}
