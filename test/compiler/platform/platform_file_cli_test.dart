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
    });
  });
}
