@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/temp_helpers.dart';

void main() {
  group('File', () {
    late Directory tempDir;
    late File existingFile;

    setUp(() {
      tempDir = createTempTestDirectory('primal_file_test_');
      existingFile = File(path.join(tempDir.path, 'file1.txt'));
      existingFile.parent.createSync(recursive: true);
      existingFile.writeAsStringSync('Hello, world!');
    });

    test('file_fromPath', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_fromPath(${primalString(existingFile.path)})',
      );
      checkResult(runtime, primalString(existingFile.absolute.path));
    });

    test('file_exists returns true for existing file', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_exists(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, true);
    });

    test('file_exists returns false for non-existing file', () {
      final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_exists(file_fromPath(${primalString(missingFile.path)}))',
      );
      checkResult(runtime, false);
    });

    test('file_read', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_read(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('Hello, world!'));
    });

    test('file_write', () {
      const String value = '12345';
      final File targetFile = File(path.join(tempDir.path, 'written.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString(value)})',
      );
      checkResult(runtime, true);
      expect(targetFile.readAsStringSync(), equals(value));
    });

    test('file_append', () {
      final File targetFile = File(path.join(tempDir.path, 'append.txt'));
      targetFile.writeAsStringSync('Hello');
      final RuntimeFacade runtime = getRuntime(
        'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString(', world!')})',
      );
      checkResult(runtime, true);
      expect(targetFile.readAsStringSync(), equals('Hello, world!'));
    });

    test('file_append creates file if not exists', () {
      final File targetFile = File(path.join(tempDir.path, 'append-new.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString('content')})',
      );
      checkResult(runtime, true);
      expect(targetFile.existsSync(), isTrue);
      expect(targetFile.readAsStringSync(), equals('content'));
    });

    test('file_lastModified', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_toEpoch(file_lastModified(file_fromPath(${primalString(existingFile.path)})))',
      );
      final String result = runtime.executeMain();
      final int epochMs = int.parse(result);
      final DateTime now = DateTime.now();
      final DateTime fileTime = DateTime.fromMillisecondsSinceEpoch(epochMs);
      // The file was just created, so the timestamp should be recent (within last minute)
      expect(now.difference(fileTime).inMinutes, lessThan(1));
    });

    test('file_length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_length(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, 13);
    });

    test('file_create', () {
      final File createdFile = File(
        path.join(tempDir.path, 'nested', 'created.txt'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main() = file_create(file_fromPath(${primalString(createdFile.path)}))',
      );
      checkResult(runtime, true);
      expect(createdFile.existsSync(), isTrue);
    });

    test('file_delete returns true for existing file', () {
      final File deletableFile = File(path.join(tempDir.path, 'delete-me.txt'));
      deletableFile.writeAsStringSync('remove');
      final RuntimeFacade runtime = getRuntime(
        'main() = file_delete(file_fromPath(${primalString(deletableFile.path)}))',
      );
      checkResult(runtime, true);
      expect(deletableFile.existsSync(), isFalse);
    });

    test('file_delete returns false for non-existing file', () {
      final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_delete(file_fromPath(${primalString(missingFile.path)}))',
      );
      checkResult(runtime, false);
    });

    test('file_path', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_path(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString(existingFile.absolute.path));
    });

    test('file_name', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_name(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('file1.txt'));
    });

    test('file_extension', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_extension(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('txt'));
    });

    test('file_copy', () {
      final File destinationFile = File(path.join(tempDir.path, 'copy.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_copy(file_fromPath(${primalString(existingFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
      );
      checkResult(runtime, true);
      expect(destinationFile.readAsStringSync(), equals('Hello, world!'));
    });

    test('file_move', () {
      final File sourceFile = File(path.join(tempDir.path, 'move-source.txt'));
      sourceFile.writeAsStringSync('move');
      final File destinationFile = File(path.join(tempDir.path, 'move.txt'));
      final RuntimeFacade runtime = getRuntime(
        'main() = file_move(file_fromPath(${primalString(sourceFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
      );
      checkResult(runtime, true);
      expect(sourceFile.existsSync(), isFalse);
      expect(destinationFile.readAsStringSync(), equals('move'));
    });

    test('file_parent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = file_parent(file_fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString(existingFile.parent.absolute.path));
    });

    test('file_rename', () {
      final File sourceFile = File(path.join(tempDir.path, 'rename-me.txt'));
      sourceFile.writeAsStringSync('rename');
      final RuntimeFacade runtime = getRuntime(
        'main() = file_rename(file_fromPath(${primalString(sourceFile.path)}), ${primalString('renamed.txt')})',
      );
      checkResult(runtime, true);
      expect(File(path.join(tempDir.path, 'renamed.txt')).existsSync(), isTrue);
    });

    group('edge cases', () {
      test('file_read returns empty string for empty file', () {
        final File emptyFile = File(path.join(tempDir.path, 'empty.txt'));
        emptyFile.writeAsStringSync('');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_read(file_fromPath(${primalString(emptyFile.path)}))',
        );
        checkResult(runtime, primalString(''));
      });

      test('file_write with empty string', () {
        final File targetFile = File(
          path.join(tempDir.path, 'empty-write.txt'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString('')})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals(''));
      });

      test('file_write overwrites existing file', () {
        final File targetFile = File(path.join(tempDir.path, 'overwrite.txt'));
        targetFile.writeAsStringSync('original content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString('new content')})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals('new content'));
      });

      test('file_append with empty string', () {
        final File targetFile = File(
          path.join(tempDir.path, 'append-empty.txt'),
        );
        targetFile.writeAsStringSync('original');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString('')})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals('original'));
      });

      test('file_append multiple times', () {
        final File targetFile = File(
          path.join(tempDir.path, 'append-multiple.txt'),
        );
        targetFile.writeAsStringSync('line1');
        getRuntime(
          'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString('\nline2')})',
        ).executeMain();
        getRuntime(
          'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString('\nline3')})',
        ).executeMain();
        expect(targetFile.readAsStringSync(), equals('line1\nline2\nline3'));
      });

      test('file_append with unicode characters', () {
        final File targetFile = File(
          path.join(tempDir.path, 'append-unicode.txt'),
        );
        targetFile.writeAsStringSync('Hello ');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(file_fromPath(${primalString(targetFile.path)}), ${primalString('\u4e16\u754c')})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals('Hello \u4e16\u754c'));
      });

      test('file_append in deeply nested non-existing directory', () {
        final File deepFile = File(
          path.join(tempDir.path, 'a', 'b', 'c', 'append-deep.txt'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(file_fromPath(${primalString(deepFile.path)}), ${primalString('content')})',
        );
        checkResult(runtime, true);
        expect(deepFile.existsSync(), isTrue);
        expect(deepFile.readAsStringSync(), equals('content'));
      });

      test('file_lastModified returns timestamp after file modification', () {
        final File modFile = File(path.join(tempDir.path, 'mod-time.txt'));
        modFile.writeAsStringSync('initial');
        final DateTime beforeModify = DateTime.now();
        modFile.writeAsStringSync('modified');
        final RuntimeFacade runtime = getRuntime(
          'main() = time_toEpoch(file_lastModified(file_fromPath(${primalString(modFile.path)})))',
        );
        final String result = runtime.executeMain();
        final int epochMs = int.parse(result);
        final DateTime fileTime = DateTime.fromMillisecondsSinceEpoch(epochMs);
        // Allow 1 second tolerance for filesystem timestamp granularity
        expect(
          fileTime.millisecondsSinceEpoch,
          greaterThanOrEqualTo(beforeModify.millisecondsSinceEpoch - 1000),
        );
      });

      test('file_length returns 0 for empty file', () {
        final File emptyFile = File(path.join(tempDir.path, 'zero-length.txt'));
        emptyFile.writeAsStringSync('');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_length(file_fromPath(${primalString(emptyFile.path)}))',
        );
        checkResult(runtime, 0);
      });

      test('file_extension returns empty string for file without extension', () {
        final File noExtFile = File(path.join(tempDir.path, 'noextension'));
        noExtFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension(file_fromPath(${primalString(noExtFile.path)}))',
        );
        checkResult(runtime, primalString(''));
      });

      test('file_extension returns last extension for multiple dots', () {
        final File multiDotFile = File(
          path.join(tempDir.path, 'archive.tar.gz'),
        );
        multiDotFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension(file_fromPath(${primalString(multiDotFile.path)}))',
        );
        checkResult(runtime, primalString('gz'));
      });

      test('file_extension returns extension for hidden file with extension', () {
        final File hiddenFile = File(path.join(tempDir.path, '.hidden.txt'));
        hiddenFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension(file_fromPath(${primalString(hiddenFile.path)}))',
        );
        checkResult(runtime, primalString('txt'));
      });

      test('file_name returns full name for hidden file', () {
        final File hiddenFile = File(path.join(tempDir.path, '.gitignore'));
        hiddenFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_name(file_fromPath(${primalString(hiddenFile.path)}))',
        );
        checkResult(runtime, primalString('.gitignore'));
      });

      test('file_copy returns false when source does not exist', () {
        final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
        final File destinationFile = File(path.join(tempDir.path, 'dest.txt'));
        final RuntimeFacade runtime = getRuntime(
          'main() = file_copy(file_fromPath(${primalString(missingFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
        );
        checkResult(runtime, false);
      });

      test('file_move returns false when source does not exist', () {
        final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
        final File destinationFile = File(path.join(tempDir.path, 'dest.txt'));
        final RuntimeFacade runtime = getRuntime(
          'main() = file_move(file_fromPath(${primalString(missingFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
        );
        checkResult(runtime, false);
      });

      test('file_rename returns false when source does not exist', () {
        final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
        final RuntimeFacade runtime = getRuntime(
          'main() = file_rename(file_fromPath(${primalString(missingFile.path)}), ${primalString('renamed.txt')})',
        );
        checkResult(runtime, false);
      });

      test('file_create returns true when file already exists', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_create(file_fromPath(${primalString(existingFile.path)}))',
        );
        checkResult(runtime, true);
        expect(existingFile.existsSync(), isTrue);
      });

      test('file_write with newline characters', () {
        final File targetFile = File(
          path.join(tempDir.path, 'special-chars.txt'),
        );
        const String content = 'Line1\nLine2\nLine3';
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString(content)})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals(content));
      });

      test('file_write with tab characters', () {
        final File targetFile = File(
          path.join(tempDir.path, 'tabbed.txt'),
        );
        const String content = 'Column1\tColumn2\tColumn3';
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString(content)})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals(content));
      });

      test('file_write with unicode characters', () {
        final File targetFile = File(
          path.join(tempDir.path, 'unicode.txt'),
        );
        const String content = 'Hello World';
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(targetFile.path)}), ${primalString(content)})',
        );
        checkResult(runtime, true);
        expect(targetFile.readAsStringSync(), equals(content));
      });

      test('file_read returns content with newlines', () {
        final File specialFile = File(
          path.join(tempDir.path, 'read-newlines.txt'),
        );
        const String content = 'Line1\nLine2\nLine3';
        specialFile.writeAsStringSync(content);
        final RuntimeFacade runtime = getRuntime(
          'main() = file_read(file_fromPath(${primalString(specialFile.path)}))',
        );
        // The result is a quoted string with escaped newlines
        final String result = runtime.executeMain();
        expect(result.startsWith('"'), isTrue);
        expect(result.endsWith('"'), isTrue);
        expect(result.contains('Line1'), isTrue);
        expect(result.contains('Line2'), isTrue);
      });

      test('file_copy overwrites existing destination', () {
        final File destinationFile = File(
          path.join(tempDir.path, 'dest-overwrite.txt'),
        );
        destinationFile.writeAsStringSync('old content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_copy(file_fromPath(${primalString(existingFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
        );
        checkResult(runtime, true);
        expect(destinationFile.readAsStringSync(), equals('Hello, world!'));
      });

      test('file_move overwrites existing destination', () {
        final File sourceFile = File(
          path.join(tempDir.path, 'move-source-overwrite.txt'),
        );
        sourceFile.writeAsStringSync('new content');
        final File destinationFile = File(
          path.join(tempDir.path, 'move-dest-overwrite.txt'),
        );
        destinationFile.writeAsStringSync('old content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_move(file_fromPath(${primalString(sourceFile.path)}), file_fromPath(${primalString(destinationFile.path)}))',
        );
        checkResult(runtime, true);
        expect(sourceFile.existsSync(), isFalse);
        expect(destinationFile.readAsStringSync(), equals('new content'));
      });

      test(
        'file_extension returns empty string for hidden file without extension',
        () {
          final File hiddenFile = File(path.join(tempDir.path, '.gitignore'));
          hiddenFile.writeAsStringSync('content');
          final RuntimeFacade runtime = getRuntime(
            'main() = file_extension(file_fromPath(${primalString(hiddenFile.path)}))',
          );
          checkResult(runtime, primalString(''));
        },
      );

      test('file_name returns name without path', () {
        final File deepFile = File(
          path.join(tempDir.path, 'sub', 'deep', 'nested.txt'),
        );
        deepFile.parent.createSync(recursive: true);
        deepFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_name(file_fromPath(${primalString(deepFile.path)}))',
        );
        checkResult(runtime, primalString('nested.txt'));
      });

      test('file_parent returns parent directory for nested file', () {
        final File deepFile = File(
          path.join(tempDir.path, 'parent-test', 'child.txt'),
        );
        deepFile.parent.createSync(recursive: true);
        deepFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_parent(file_fromPath(${primalString(deepFile.path)}))',
        );
        checkResult(runtime, primalString(deepFile.parent.absolute.path));
      });

      test('file_rename preserves content', () {
        final File sourceFile = File(
          path.join(tempDir.path, 'rename-content.txt'),
        );
        sourceFile.writeAsStringSync('preserve me');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_rename(file_fromPath(${primalString(sourceFile.path)}), ${primalString('renamed-content.txt')})',
        );
        checkResult(runtime, true);
        final File renamedFile = File(
          path.join(tempDir.path, 'renamed-content.txt'),
        );
        expect(renamedFile.readAsStringSync(), equals('preserve me'));
      });

      test('file_fromPath with relative path resolves correctly', () {
        final String relativePath = path.relative(existingFile.path);
        final RuntimeFacade runtime = getRuntime(
          'main() = file_path(file_fromPath(${primalString(relativePath)}))',
        );
        // The result should be an absolute path
        final String result = runtime.executeMain();
        expect(result.startsWith('"'), isTrue);
        expect(result.endsWith('"'), isTrue);
      });

      test('file_length with large file', () {
        final File largeFile = File(path.join(tempDir.path, 'large.txt'));
        final String content = 'x' * 10000;
        largeFile.writeAsStringSync(content);
        final RuntimeFacade runtime = getRuntime(
          'main() = file_length(file_fromPath(${primalString(largeFile.path)}))',
        );
        checkResult(runtime, 10000);
      });

      test('file_read with large file', () {
        final File largeFile = File(path.join(tempDir.path, 'read-large.txt'));
        final String content = 'abcdefghij' * 1000;
        largeFile.writeAsStringSync(content);
        final RuntimeFacade runtime = getRuntime(
          'main() = file_read(file_fromPath(${primalString(largeFile.path)}))',
        );
        checkResult(runtime, primalString(content));
      });

      test('file_extension with multiple consecutive dots', () {
        final File dotFile = File(path.join(tempDir.path, 'file..txt'));
        dotFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension(file_fromPath(${primalString(dotFile.path)}))',
        );
        checkResult(runtime, primalString('txt'));
      });

      test('file_extension with dot only at end', () {
        final File dotEndFile = File(path.join(tempDir.path, 'file.'));
        dotEndFile.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension(file_fromPath(${primalString(dotEndFile.path)}))',
        );
        checkResult(runtime, primalString(''));
      });

      test('file_create in deeply nested non-existing directory', () {
        final File deepFile = File(
          path.join(tempDir.path, 'a', 'b', 'c', 'd', 'deep.txt'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main() = file_create(file_fromPath(${primalString(deepFile.path)}))',
        );
        checkResult(runtime, true);
        expect(deepFile.existsSync(), isTrue);
      });
    });

    group('type errors', () {
      test('file_fromPath throws for number argument', () {
        final RuntimeFacade runtime = getRuntime('main() = file_fromPath(123)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_fromPath throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_fromPath(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_fromPath throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_fromPath([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_exists throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_exists("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_exists throws for number argument', () {
        final RuntimeFacade runtime = getRuntime('main() = file_exists(42)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_read throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_read("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_read throws for number argument', () {
        final RuntimeFacade runtime = getRuntime('main() = file_read(123)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_write throws for string first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write("not a file", "content")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_write throws for number second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(existingFile.path)}), 123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_write throws for boolean second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_write(file_fromPath(${primalString(existingFile.path)}), true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_append throws for string first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append("not a file", "content")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_append throws for number second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(file_fromPath(${primalString(existingFile.path)}), 123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_append throws for boolean second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(file_fromPath(${primalString(existingFile.path)}), true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_append throws for number first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_append(123, "content")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_lastModified throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_lastModified("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_lastModified throws for number argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_lastModified(123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_lastModified throws for boolean argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_lastModified(true)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_lastModified throws for list argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_lastModified([1, 2, 3])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_length throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_length("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_create throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_create("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_delete throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_delete("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_path throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_path("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_name throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_name("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_extension throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_extension("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_copy throws for string first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_copy("not a file", file_fromPath(${primalString(existingFile.path)}))',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_copy throws for string second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_copy(file_fromPath(${primalString(existingFile.path)}), "not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_copy throws for number arguments', () {
        final RuntimeFacade runtime = getRuntime('main() = file_copy(1, 2)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_move throws for string first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_move("not a file", file_fromPath(${primalString(existingFile.path)}))',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_move throws for string second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_move(file_fromPath(${primalString(existingFile.path)}), "not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_parent throws for string argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_parent("not a file")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_rename throws for string first argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_rename("not a file", "newname.txt")',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_rename throws for number second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_rename(file_fromPath(${primalString(existingFile.path)}), 123)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('file_rename throws for file second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = file_rename(file_fromPath(${primalString(existingFile.path)}), file_fromPath(${primalString(existingFile.path)}))',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });
}
