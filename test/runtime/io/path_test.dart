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
    group('path.join', () {
      test('joins two path segments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("/home/user", "file.txt")',
        );
        checkResult(runtime, '"/home/user/file.txt"');
      });

      test('joins relative paths', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("folder", "subfolder")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('handles trailing separator in first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("/home/user/", "file.txt")',
        );
        checkResult(runtime, '"/home/user/file.txt"');
      });

      test('handles leading separator in second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("/home/user", "/file.txt")',
        );
        // Absolute second path replaces first
        final String result = runtime.executeMain();
        expect(result.contains('file.txt'), isTrue);
      });

      test('joins empty first segment', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("", "file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('joins empty second segment', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("/home/user", "")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('joins two empty segments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("", "")',
        );
        checkResult(runtime, '""');
      });
    });

    group('path.dirname', () {
      test('extracts directory from absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("/home/user/file.txt")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('extracts directory from relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("folder/subfolder/file.txt")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('returns dot for filename only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("file.txt")',
        );
        checkResult(runtime, '"."');
      });

      test('returns slash for root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("/")',
        );
        checkResult(runtime, '"/"');
      });

      test('handles path with trailing slash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("/home/user/")',
        );
        checkResult(runtime, '"/home"');
      });

      test('returns dot for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("")',
        );
        checkResult(runtime, '"."');
      });

      test('returns slash for file in root', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname("/file.txt")',
        );
        checkResult(runtime, '"/"');
      });
    });

    group('path.basename', () {
      test('extracts filename from absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("/home/user/file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('extracts filename from relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("folder/subfolder/file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('returns filename when no directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("file.txt")',
        );
        checkResult(runtime, '"file.txt"');
      });

      test('extracts last directory name', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("/home/user")',
        );
        checkResult(runtime, '"user"');
      });

      test('handles trailing slash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("/home/user/")',
        );
        checkResult(runtime, '"user"');
      });

      test('returns empty for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("")',
        );
        checkResult(runtime, '""');
      });

      test('handles hidden files', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename("/home/user/.gitignore")',
        );
        checkResult(runtime, '".gitignore"');
      });
    });

    group('path.extension', () {
      test('extracts extension from filename', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("/home/user/file.txt")',
        );
        checkResult(runtime, '"txt"');
      });

      test('extracts last extension from multiple dots', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("archive.tar.gz")',
        );
        checkResult(runtime, '"gz"');
      });

      test('returns empty for no extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("Makefile")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty for hidden file without extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension(".gitignore")',
        );
        checkResult(runtime, '""');
      });

      test('extracts extension from hidden file with extension', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension(".config.json")',
        );
        checkResult(runtime, '"json"');
      });

      test('returns empty for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty for path ending with dot', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("file.")',
        );
        checkResult(runtime, '""');
      });

      test('handles multiple consecutive dots', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension("file..txt")',
        );
        checkResult(runtime, '"txt"');
      });
    });

    group('path.isAbsolute', () {
      test('returns true for absolute path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("/home/user")',
        );
        checkResult(runtime, true);
      });

      test('returns false for relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("folder/file.txt")',
        );
        checkResult(runtime, false);
      });

      test('returns false for dot-relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("./relative")',
        );
        checkResult(runtime, false);
      });

      test('returns false for double-dot path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("../parent")',
        );
        checkResult(runtime, false);
      });

      test('returns false for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("")',
        );
        checkResult(runtime, false);
      });

      test('returns true for root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("/")',
        );
        checkResult(runtime, true);
      });

      test('returns false for filename only', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute("file.txt")',
        );
        checkResult(runtime, false);
      });
    });

    group('path.normalize', () {
      test('resolves parent directory references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/home/user/../other")',
        );
        checkResult(runtime, '"/home/other"');
      });

      test('removes current directory references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/home/./user")',
        );
        checkResult(runtime, '"/home/user"');
      });

      test('removes redundant separators', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/home//user///file")',
        );
        checkResult(runtime, '"/home/user/file"');
      });

      test('normalizes relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("./folder/./subfolder")',
        );
        checkResult(runtime, '"folder/subfolder"');
      });

      test('returns dot for empty path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("")',
        );
        checkResult(runtime, '"."');
      });

      test('returns dot for current directory', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize(".")',
        );
        checkResult(runtime, '"."');
      });

      test('handles multiple parent references', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/a/b/c/../../d")',
        );
        checkResult(runtime, '"/a/d"');
      });

      test('preserves leading double-dot for relative path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("../folder")',
        );
        checkResult(runtime, '"../folder"');
      });

      test('normalizes root path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/")',
        );
        checkResult(runtime, '"/"');
      });

      test('handles complex path', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize("/a/b/../c/./d/../e")',
        );
        checkResult(runtime, '"/a/c/e"');
      });
    });

    group('type errors', () {
      test('path.join throws for number first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join(123, "file.txt")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.join throws for number second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join("/home", 456)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.join throws for boolean arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join(true, false)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.join throws for list arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.join([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.dirname throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.dirname throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.dirname throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.dirname([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.basename throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.basename throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.basename throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.basename([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.extension throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.extension throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.extension throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.extension([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.isAbsolute throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.isAbsolute throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.isAbsolute throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.isAbsolute([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.normalize throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.normalize throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('path.normalize throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = path.normalize([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });
}
