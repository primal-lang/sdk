@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:primal/compiler/platform/file/platform_file_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformFileCli platform;
  late Directory tempDir;

  setUp(() {
    platform = PlatformFileCli();
    tempDir = Directory.systemTemp.createTempSync('primal_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PlatformFileCli', () {
    test('fromPath creates a File object', () {
      final File file = platform.fromPath('${tempDir.path}/test.txt');

      expect(file, isA<File>());
      expect(file.path, equals('${tempDir.path}/test.txt'));
    });

    test('create creates a file', () {
      final File file = File('${tempDir.path}/created.txt');

      expect(platform.create(file), isTrue);
      expect(file.existsSync(), isTrue);
    });

    test('exists returns false for nonexistent file', () {
      final File file = File('${tempDir.path}/nope.txt');

      expect(platform.exists(file), isFalse);
    });

    test('exists returns true for existing file', () {
      final File file = File('${tempDir.path}/yes.txt')..createSync();

      expect(platform.exists(file), isTrue);
    });

    test('write creates file and writes content', () {
      final File file = File('${tempDir.path}/write.txt');

      expect(platform.write(file, 'hello'), isTrue);
      expect(file.readAsStringSync(), equals('hello'));
    });

    test('read returns file content', () {
      final File file = File('${tempDir.path}/read.txt')
        ..writeAsStringSync('content');

      expect(platform.read(file), equals('content'));
    });

    test('length returns file size', () {
      final File file = File('${tempDir.path}/size.txt')
        ..writeAsStringSync('12345');

      expect(platform.length(file), equals(5));
    });

    test('delete removes a file', () {
      final File file = File('${tempDir.path}/del.txt')..createSync();

      expect(platform.delete(file), isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('delete returns false for nonexistent file', () {
      final File file = File('${tempDir.path}/nope.txt');

      expect(platform.delete(file), isFalse);
    });

    test('path returns absolute path', () {
      final File file = File('${tempDir.path}/abs.txt')..createSync();

      expect(platform.path(file), contains(tempDir.path));
    });

    test('name returns filename', () {
      final File file = File('${tempDir.path}/myfile.txt');

      expect(platform.name(file), equals('myfile.txt'));
    });

    test('extension returns file extension without dot', () {
      final File file = File('${tempDir.path}/test.prm');

      expect(platform.extension(file), equals('prm'));
    });

    test('extension returns empty string for no extension', () {
      final File file = File('${tempDir.path}/noext');

      expect(platform.extension(file), equals(''));
    });

    test('rename renames a file', () {
      final File file = File('${tempDir.path}/old.txt')..createSync();

      expect(platform.rename(file, 'new.txt'), isTrue);
      expect(File('${tempDir.path}/new.txt').existsSync(), isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('copy copies a file', () {
      final File source = File('${tempDir.path}/src.txt')
        ..writeAsStringSync('data');
      final File destination = File('${tempDir.path}/dst.txt');

      expect(platform.copy(source, destination), isTrue);
      expect(destination.readAsStringSync(), equals('data'));
      expect(source.existsSync(), isTrue);
    });

    test('move moves a file', () {
      final File source = File('${tempDir.path}/mv_src.txt')
        ..writeAsStringSync('data');
      final File destination = File('${tempDir.path}/mv_dst.txt');

      expect(platform.move(source, destination), isTrue);
      expect(destination.readAsStringSync(), equals('data'));
      expect(source.existsSync(), isFalse);
    });

    test('parent returns parent directory', () {
      final File file = File('${tempDir.path}/child.txt');

      expect(platform.parent(file).path, equals(tempDir.path));
    });

    group('create', () {
      test('creates file in nested non-existent directories', () {
        final File file = File('${tempDir.path}/nested/deep/file.txt');

        expect(platform.create(file), isTrue);
        expect(file.existsSync(), isTrue);
      });
    });

    group('write', () {
      test('creates nested directories when writing', () {
        final File file = File('${tempDir.path}/nested/path/write.txt');

        expect(platform.write(file, 'nested content'), isTrue);
        expect(file.readAsStringSync(), equals('nested content'));
      });

      test('overwrites existing file content', () {
        final File file = File('${tempDir.path}/overwrite.txt')
          ..writeAsStringSync('original');

        expect(platform.write(file, 'updated'), isTrue);
        expect(file.readAsStringSync(), equals('updated'));
      });

      test('writes empty content', () {
        final File file = File('${tempDir.path}/empty_write.txt');

        expect(platform.write(file, ''), isTrue);
        expect(file.readAsStringSync(), equals(''));
      });
    });

    group('read', () {
      test('throws exception for non-existent file', () {
        final File file = File('${tempDir.path}/nonexistent.txt');

        expect(() => platform.read(file), throwsA(isA<FileSystemException>()));
      });

      test('returns empty string for empty file', () {
        final File file = File('${tempDir.path}/empty.txt')..createSync();

        expect(platform.read(file), equals(''));
      });

      test('reads file with multiple lines', () {
        final File file = File('${tempDir.path}/multiline.txt')
          ..writeAsStringSync('line1\nline2\nline3');

        expect(platform.read(file), equals('line1\nline2\nline3'));
      });

      test('reads file with unicode content', () {
        final File file = File('${tempDir.path}/unicode.txt')
          ..writeAsStringSync('Hello \u4e16\u754c \u{1F600}');

        expect(platform.read(file), equals('Hello \u4e16\u754c \u{1F600}'));
      });
    });

    group('length', () {
      test('returns zero for empty file', () {
        final File file = File('${tempDir.path}/empty_len.txt')..createSync();

        expect(platform.length(file), equals(0));
      });

      test('throws exception for non-existent file', () {
        final File file = File('${tempDir.path}/nonexistent_len.txt');

        expect(
          () => platform.length(file),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('rename', () {
      test('returns false for non-existent file', () {
        final File file = File('${tempDir.path}/nonexistent_rename.txt');

        expect(platform.rename(file, 'new_name.txt'), isFalse);
      });

      test('renames file preserving content', () {
        final File file = File('${tempDir.path}/rename_content.txt')
          ..writeAsStringSync('preserved');

        expect(platform.rename(file, 'renamed_content.txt'), isTrue);

        final File renamedFile = File('${tempDir.path}/renamed_content.txt');
        expect(renamedFile.readAsStringSync(), equals('preserved'));
      });
    });

    group('copy', () {
      test('returns false for non-existent source file', () {
        final File source = File('${tempDir.path}/nonexistent_copy.txt');
        final File destination = File('${tempDir.path}/copy_dest.txt');

        expect(platform.copy(source, destination), isFalse);
      });

      test('overwrites existing destination file', () {
        final File source = File('${tempDir.path}/copy_src.txt')
          ..writeAsStringSync('new data');
        final File destination = File('${tempDir.path}/copy_existing.txt')
          ..writeAsStringSync('old data');

        expect(platform.copy(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('new data'));
      });
    });

    group('move', () {
      test('returns false for non-existent source file', () {
        final File source = File('${tempDir.path}/nonexistent_move.txt');
        final File destination = File('${tempDir.path}/move_dest.txt');

        expect(platform.move(source, destination), isFalse);
      });
    });

    group('extension', () {
      test('returns last extension for file with multiple dots', () {
        final File file = File('${tempDir.path}/archive.tar.gz');

        expect(platform.extension(file), equals('gz'));
      });

      test('returns extension for hidden file with extension', () {
        final File file = File('${tempDir.path}/.hidden.txt');

        expect(platform.extension(file), equals('txt'));
      });

      test('returns empty string for hidden file without extension', () {
        final File file = File('${tempDir.path}/.hidden');

        expect(platform.extension(file), equals(''));
      });
    });

    group('fromPath', () {
      test('handles path with spaces', () {
        final File file = platform.fromPath(
          '${tempDir.path}/file with spaces.txt',
        );

        expect(file.path, equals('${tempDir.path}/file with spaces.txt'));
      });

      test('handles path with special characters', () {
        final File file = platform.fromPath(
          '${tempDir.path}/file-name_123.txt',
        );

        expect(file.path, equals('${tempDir.path}/file-name_123.txt'));
      });
    });

    group('path', () {
      test('returns absolute path for relative path input', () {
        final File file = File('relative.txt');

        final String absolutePath = platform.path(file);
        expect(absolutePath.startsWith('/'), isTrue);
        expect(absolutePath.endsWith('relative.txt'), isTrue);
      });
    });

    group('name', () {
      test('returns filename from deeply nested path', () {
        final File file = File('${tempDir.path}/a/b/c/d/deep.txt');

        expect(platform.name(file), equals('deep.txt'));
      });

      test('returns filename for hidden file', () {
        final File file = File('${tempDir.path}/.gitignore');

        expect(platform.name(file), equals('.gitignore'));
      });
    });

    group('parent', () {
      test('returns parent for deeply nested file', () {
        final File file = File('${tempDir.path}/a/b/c/nested.txt');

        expect(platform.parent(file).path, equals('${tempDir.path}/a/b/c'));
      });

      test('returns parent for file in temp directory root', () {
        final File file = File('${tempDir.path}/root_file.txt');

        expect(platform.parent(file).path, equals(tempDir.path));
      });
    });

    group('create (error handling)', () {
      test('returns false when file cannot be created', () {
        // Create a file where a directory would be needed
        final File blocker = File('${tempDir.path}/blocker')..createSync();
        final File file = File('${tempDir.path}/blocker/subdir/file.txt');

        expect(platform.create(file), isFalse);
        blocker.deleteSync();
      });

      test('creates file that already exists without error', () {
        final File file = File('${tempDir.path}/existing.txt')..createSync();

        expect(platform.create(file), isTrue);
        expect(file.existsSync(), isTrue);
      });
    });

    group('write (error handling)', () {
      test('returns false when write fails due to path conflict', () {
        // Create a file where a directory would be needed
        final File blocker = File('${tempDir.path}/write_blocker')
          ..createSync();
        final File file = File('${tempDir.path}/write_blocker/subdir/file.txt');

        expect(platform.write(file, 'content'), isFalse);
        blocker.deleteSync();
      });

      test('writes unicode content correctly', () {
        final File file = File('${tempDir.path}/unicode_write.txt');
        const String unicodeContent =
            'Hello \u4e16\u754c \u{1F600} \u03B1\u03B2\u03B3';

        expect(platform.write(file, unicodeContent), isTrue);
        expect(file.readAsStringSync(), equals(unicodeContent));
      });

      test('writes large content', () {
        final File file = File('${tempDir.path}/large_write.txt');
        final String largeContent = 'x' * 100000;

        expect(platform.write(file, largeContent), isTrue);
        expect(file.readAsStringSync(), equals(largeContent));
      });

      test('writes content with special characters', () {
        final File file = File('${tempDir.path}/special_write.txt');
        const String specialContent = 'Tab:\t Newline:\n Carriage:\r Quote:"\'';

        expect(platform.write(file, specialContent), isTrue);
        expect(file.readAsStringSync(), equals(specialContent));
      });
    });

    group('move (additional cases)', () {
      test('overwrites existing destination file', () {
        final File source = File('${tempDir.path}/move_src_overwrite.txt')
          ..writeAsStringSync('new data');
        final File destination = File('${tempDir.path}/move_dst_existing.txt')
          ..writeAsStringSync('old data');

        expect(platform.move(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('new data'));
        expect(source.existsSync(), isFalse);
      });

      test('moves file to different directory', () {
        final Directory subDir = Directory('${tempDir.path}/subdir')
          ..createSync();
        final File source = File('${tempDir.path}/move_to_subdir.txt')
          ..writeAsStringSync('moving');
        final File destination = File('${subDir.path}/moved.txt');

        expect(platform.move(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('moving'));
        expect(source.existsSync(), isFalse);
      });

      test('returns false when destination directory does not exist', () {
        final File source = File('${tempDir.path}/move_src_no_dest.txt')
          ..writeAsStringSync('data');
        final File destination = File(
          '${tempDir.path}/nonexistent_dir/moved.txt',
        );

        expect(platform.move(source, destination), isFalse);
        expect(source.existsSync(), isTrue);
      });
    });

    group('copy (additional cases)', () {
      test('copies file to different directory', () {
        final Directory subDir = Directory('${tempDir.path}/copy_subdir')
          ..createSync();
        final File source = File('${tempDir.path}/copy_to_subdir.txt')
          ..writeAsStringSync('copying');
        final File destination = File('${subDir.path}/copied.txt');

        expect(platform.copy(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('copying'));
        expect(source.existsSync(), isTrue);
      });

      test('copies empty file', () {
        final File source = File('${tempDir.path}/empty_copy_src.txt')
          ..createSync();
        final File destination = File('${tempDir.path}/empty_copy_dst.txt');

        expect(platform.copy(source, destination), isTrue);
        expect(destination.existsSync(), isTrue);
        expect(destination.readAsStringSync(), equals(''));
      });

      test('returns false when destination directory does not exist', () {
        final File source = File('${tempDir.path}/copy_src_no_dest.txt')
          ..writeAsStringSync('data');
        final File destination = File(
          '${tempDir.path}/nonexistent_copy_dir/copied.txt',
        );

        expect(platform.copy(source, destination), isFalse);
      });

      test('copies file with unicode content', () {
        final File source = File('${tempDir.path}/unicode_copy_src.txt')
          ..writeAsStringSync('Unicode: \u4e16\u754c \u{1F600}');
        final File destination = File('${tempDir.path}/unicode_copy_dst.txt');

        expect(platform.copy(source, destination), isTrue);
        expect(
          destination.readAsStringSync(),
          equals('Unicode: \u4e16\u754c \u{1F600}'),
        );
      });
    });

    group('length (additional cases)', () {
      test('returns byte count for unicode content', () {
        final File file = File('${tempDir.path}/unicode_length.txt')
          ..writeAsStringSync(
            '\u4e16',
          ); // Single Chinese character (3 bytes in UTF-8)

        // UTF-8 encoded Chinese character is 3 bytes
        expect(platform.length(file), equals(3));
      });

      test('returns correct length for multiline content', () {
        final File file = File('${tempDir.path}/multiline_length.txt')
          ..writeAsStringSync('a\nb\nc');

        expect(platform.length(file), equals(5)); // 3 chars + 2 newlines
      });
    });

    group('rename (additional cases)', () {
      test('renames file overwriting existing file', () {
        final File file = File('${tempDir.path}/rename_src.txt')
          ..writeAsStringSync('source content');
        File(
          '${tempDir.path}/rename_target.txt',
        ).writeAsStringSync('target content');

        expect(platform.rename(file, 'rename_target.txt'), isTrue);

        final File renamedFile = File('${tempDir.path}/rename_target.txt');
        expect(renamedFile.readAsStringSync(), equals('source content'));
        expect(file.existsSync(), isFalse);
      });

      test('renames file to same name succeeds', () {
        final File file = File('${tempDir.path}/same_name.txt')..createSync();

        expect(platform.rename(file, 'same_name.txt'), isTrue);
        expect(File('${tempDir.path}/same_name.txt').existsSync(), isTrue);
      });
    });

    group('fromPath (additional cases)', () {
      test('handles empty path', () {
        final File file = platform.fromPath('');

        expect(file, isA<File>());
        expect(file.path, equals(''));
      });

      test('handles path with unicode characters', () {
        final File file = platform.fromPath('${tempDir.path}/\u6587\u4ef6.txt');

        expect(file.path, equals('${tempDir.path}/\u6587\u4ef6.txt'));
      });

      test('handles path ending with separator', () {
        final File file = platform.fromPath('${tempDir.path}/trailing/');

        expect(file.path, equals('${tempDir.path}/trailing/'));
      });
    });

    group('name (additional cases)', () {
      test('returns filename without extension', () {
        final File file = File('${tempDir.path}/noextension');

        expect(platform.name(file), equals('noextension'));
      });

      test('returns filename with multiple dots', () {
        final File file = File('${tempDir.path}/file.name.with.dots.txt');

        expect(platform.name(file), equals('file.name.with.dots.txt'));
      });
    });

    group('extension (additional cases)', () {
      test('returns extension for uppercase extension', () {
        final File file = File('${tempDir.path}/file.TXT');

        expect(platform.extension(file), equals('TXT'));
      });

      test('returns empty string for file ending with dot', () {
        final File file = File('${tempDir.path}/file.');

        expect(platform.extension(file), equals(''));
      });
    });

    group('exists (additional cases)', () {
      test('returns false for directory path', () {
        final Directory dir = Directory('${tempDir.path}/testdir')
          ..createSync();
        final File file = File(dir.path);

        // File.existsSync returns false for directories
        expect(platform.exists(file), isFalse);
      });

      test('returns true after file is created', () {
        final File file = File('${tempDir.path}/created_later.txt');

        expect(platform.exists(file), isFalse);
        file.createSync();
        expect(platform.exists(file), isTrue);
      });

      test('returns false after file is deleted', () {
        final File file = File('${tempDir.path}/deleted_later.txt')
          ..createSync();

        expect(platform.exists(file), isTrue);
        file.deleteSync();
        expect(platform.exists(file), isFalse);
      });
    });

    group('delete (additional cases)', () {
      test('deletes file with content', () {
        final File file = File('${tempDir.path}/delete_with_content.txt')
          ..writeAsStringSync('content to delete');

        expect(platform.delete(file), isTrue);
        expect(file.existsSync(), isFalse);
      });

      test('deletes empty file', () {
        final File file = File('${tempDir.path}/delete_empty.txt')
          ..createSync();

        expect(platform.delete(file), isTrue);
        expect(file.existsSync(), isFalse);
      });

      test('deletes file with unicode name', () {
        final File file = File('${tempDir.path}/\u6587\u4ef6_delete.txt')
          ..createSync();

        expect(platform.delete(file), isTrue);
        expect(file.existsSync(), isFalse);
      });

      test('deletes file with spaces in name', () {
        final File file = File('${tempDir.path}/file with spaces to delete.txt')
          ..createSync();

        expect(platform.delete(file), isTrue);
        expect(file.existsSync(), isFalse);
      });
    });

    group('path (additional cases)', () {
      test('returns consistent path for same file', () {
        final File file = File('${tempDir.path}/consistent.txt');
        final String path1 = platform.path(file);
        final String path2 = platform.path(file);

        expect(path1, equals(path2));
      });

      test('returns path containing filename', () {
        final File file = File('${tempDir.path}/inpath.txt');

        expect(platform.path(file), contains('inpath.txt'));
      });

      test('preserves path with double slashes', () {
        final File file = File('${tempDir.path}//doubleslash.txt');
        final String absolutePath = platform.path(file);

        // The path method does not normalize double slashes
        expect(absolutePath.contains('//'), isTrue);
        expect(absolutePath.endsWith('doubleslash.txt'), isTrue);
      });

      test('returns path for file with unicode name', () {
        final File file = File('${tempDir.path}/\u6587\u4ef6.txt');
        final String absolutePath = platform.path(file);

        expect(absolutePath.contains('\u6587\u4ef6.txt'), isTrue);
      });
    });

    group('read (stress tests)', () {
      test('reads large file content', () {
        final String largeContent = 'x' * 100000;
        final File file = File('${tempDir.path}/large_read.txt')
          ..writeAsStringSync(largeContent);

        expect(platform.read(file), equals(largeContent));
      });

      test('reads file with many lines', () {
        final StringBuffer buffer = StringBuffer();
        for (int i = 0; i < 1000; i++) {
          buffer.writeln('Line $i');
        }
        final String content = buffer.toString();
        final File file = File('${tempDir.path}/many_lines.txt')
          ..writeAsStringSync(content);

        expect(platform.read(file), equals(content));
      });

      test('reads file with only whitespace', () {
        final File file = File('${tempDir.path}/whitespace.txt')
          ..writeAsStringSync('   \t\n\n  \t  ');

        expect(platform.read(file), equals('   \t\n\n  \t  '));
      });

      test('reads file with null bytes in string', () {
        final File file = File('${tempDir.path}/nullbyte.txt')
          ..writeAsStringSync('before\x00after');

        expect(platform.read(file), equals('before\x00after'));
      });
    });

    group('write (stress tests)', () {
      test('writes content with many newlines', () {
        final File file = File('${tempDir.path}/many_newlines.txt');
        final String content = '\n' * 1000;

        expect(platform.write(file, content), isTrue);
        expect(file.readAsStringSync(), equals(content));
      });

      test('writes content with null bytes', () {
        final File file = File('${tempDir.path}/null_bytes.txt');
        const String content = 'before\x00after';

        expect(platform.write(file, content), isTrue);
        expect(file.readAsStringSync(), equals(content));
      });

      test('writes content with mixed line endings', () {
        final File file = File('${tempDir.path}/mixed_endings.txt');
        const String content = 'unix\nwindows\r\nold_mac\r';

        expect(platform.write(file, content), isTrue);
        expect(file.readAsStringSync(), equals(content));
      });
    });

    group('length (stress tests)', () {
      test('returns correct length for large file', () {
        final String largeContent = 'x' * 100000;
        final File file = File('${tempDir.path}/large_length.txt')
          ..writeAsStringSync(largeContent);

        expect(platform.length(file), equals(100000));
      });

      test('returns correct length for file with only newlines', () {
        final File file = File('${tempDir.path}/newlines_length.txt')
          ..writeAsStringSync('\n\n\n\n\n');

        expect(platform.length(file), equals(5));
      });
    });

    group('create (additional edge cases)', () {
      test('creates file with unicode name', () {
        final File file = File('${tempDir.path}/\u6587\u4ef6_create.txt');

        expect(platform.create(file), isTrue);
        expect(file.existsSync(), isTrue);
      });

      test('creates file with spaces in name', () {
        final File file = File('${tempDir.path}/file with spaces.txt');

        expect(platform.create(file), isTrue);
        expect(file.existsSync(), isTrue);
      });

      test('creates file with very long name', () {
        final String longName = 'a' * 200 + '.txt';
        final File file = File('${tempDir.path}/$longName');

        expect(platform.create(file), isTrue);
        expect(file.existsSync(), isTrue);
      });
    });

    group('rename (additional edge cases)', () {
      test('renames file to unicode name', () {
        final File file = File('${tempDir.path}/rename_to_unicode.txt')
          ..createSync();

        expect(platform.rename(file, '\u6587\u4ef6.txt'), isTrue);
        expect(
          File('${tempDir.path}/\u6587\u4ef6.txt').existsSync(),
          isTrue,
        );
      });

      test('renames file to name with spaces', () {
        final File file = File('${tempDir.path}/rename_to_spaces.txt')
          ..createSync();

        expect(platform.rename(file, 'name with spaces.txt'), isTrue);
        expect(
          File('${tempDir.path}/name with spaces.txt').existsSync(),
          isTrue,
        );
      });

      test('renames file with content preserves content', () {
        final File file = File('${tempDir.path}/rename_preserve.txt')
          ..writeAsStringSync('preserved content \u4e16\u754c');

        expect(platform.rename(file, 'renamed_preserve.txt'), isTrue);

        final File renamedFile = File('${tempDir.path}/renamed_preserve.txt');
        expect(
          renamedFile.readAsStringSync(),
          equals('preserved content \u4e16\u754c'),
        );
      });
    });

    group('copy (stress tests)', () {
      test('copies large file', () {
        final String largeContent = 'x' * 100000;
        final File source = File('${tempDir.path}/large_copy_src.txt')
          ..writeAsStringSync(largeContent);
        final File destination = File('${tempDir.path}/large_copy_dst.txt');

        expect(platform.copy(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals(largeContent));
      });

      test('copies file with unicode name', () {
        final File source = File('${tempDir.path}/\u6587\u4ef6_copy_src.txt')
          ..writeAsStringSync('unicode source');
        final File destination = File(
          '${tempDir.path}/\u6587\u4ef6_copy_dst.txt',
        );

        expect(platform.copy(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('unicode source'));
      });
    });

    group('move (stress tests)', () {
      test('moves large file', () {
        final String largeContent = 'x' * 100000;
        final File source = File('${tempDir.path}/large_move_src.txt')
          ..writeAsStringSync(largeContent);
        final File destination = File('${tempDir.path}/large_move_dst.txt');

        expect(platform.move(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals(largeContent));
        expect(source.existsSync(), isFalse);
      });

      test('moves file with unicode name', () {
        final File source = File('${tempDir.path}/\u6587\u4ef6_move_src.txt')
          ..writeAsStringSync('unicode move');
        final File destination = File(
          '${tempDir.path}/\u6587\u4ef6_move_dst.txt',
        );

        expect(platform.move(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('unicode move'));
        expect(source.existsSync(), isFalse);
      });

      test('moves file to unicode destination name', () {
        final File source = File('${tempDir.path}/move_to_unicode.txt')
          ..writeAsStringSync('moving to unicode');
        final File destination = File('${tempDir.path}/\u79fb\u52a8.txt');

        expect(platform.move(source, destination), isTrue);
        expect(destination.readAsStringSync(), equals('moving to unicode'));
        expect(source.existsSync(), isFalse);
      });
    });

    group('parent (additional edge cases)', () {
      test('returns correct parent for file with unicode path', () {
        final Directory unicodeDir = Directory(
          '${tempDir.path}/\u6587\u4ef6\u5939',
        )..createSync();
        final File file = File('${unicodeDir.path}/child.txt');

        expect(platform.parent(file).path, equals(unicodeDir.path));
      });

      test('returns correct parent for file with spaces in path', () {
        final Directory spacesDir = Directory(
          '${tempDir.path}/dir with spaces',
        )..createSync();
        final File file = File('${spacesDir.path}/child.txt');

        expect(platform.parent(file).path, equals(spacesDir.path));
      });
    });

    group('extension (boundary cases)', () {
      test('returns empty string for dotfile only', () {
        final File file = File('${tempDir.path}/.');

        expect(platform.extension(file), equals(''));
      });

      test('returns extension for file with leading dots', () {
        final File file = File('${tempDir.path}/..file.txt');

        expect(platform.extension(file), equals('txt'));
      });

      test('returns very long extension', () {
        final String longExtension = 'a' * 100;
        final File file = File('${tempDir.path}/file.$longExtension');

        expect(platform.extension(file), equals(longExtension));
      });

      test('returns extension with numbers', () {
        final File file = File('${tempDir.path}/file.mp3');

        expect(platform.extension(file), equals('mp3'));
      });

      test('returns extension for file with only extension', () {
        final File file = File('${tempDir.path}/.extension');

        expect(platform.extension(file), equals(''));
      });
    });

    group('name (boundary cases)', () {
      test('returns name for file with very long name', () {
        final String longName = 'a' * 200 + '.txt';
        final File file = File('${tempDir.path}/$longName');

        expect(platform.name(file), equals(longName));
      });

      test('returns name for file with unicode characters', () {
        final File file = File('${tempDir.path}/\u6587\u4ef6\u540d.txt');

        expect(platform.name(file), equals('\u6587\u4ef6\u540d.txt'));
      });

      test('returns name for file with special characters', () {
        final File file = File('${tempDir.path}/file-name_123.test.txt');

        expect(platform.name(file), equals('file-name_123.test.txt'));
      });
    });

    group('exists (boundary cases)', () {
      test('returns false for file with invalid characters', () {
        // NUL character in path - should not exist
        final File file = File('${tempDir.path}/invalid\x00name.txt');

        expect(platform.exists(file), isFalse);
      });

      test('returns true for file with unicode name', () {
        final File file = File('${tempDir.path}/\u6587\u4ef6.txt')
          ..createSync();

        expect(platform.exists(file), isTrue);
      });

      test('returns true for file with spaces in name', () {
        final File file = File('${tempDir.path}/file with spaces.txt')
          ..createSync();

        expect(platform.exists(file), isTrue);
      });
    });

    group('fromPath (boundary cases)', () {
      test('handles very long path', () {
        final String longPath = '${tempDir.path}/${'a' * 200}.txt';
        final File file = platform.fromPath(longPath);

        expect(file.path, equals(longPath));
      });

      test('handles path with dot components', () {
        final File file = platform.fromPath(
          '${tempDir.path}/./subdir/../file.txt',
        );

        expect(file.path, equals('${tempDir.path}/./subdir/../file.txt'));
      });

      test('handles path with multiple extensions', () {
        final File file = platform.fromPath(
          '${tempDir.path}/archive.tar.gz.bak',
        );

        expect(file.path, equals('${tempDir.path}/archive.tar.gz.bak'));
      });
    });
  });
}
