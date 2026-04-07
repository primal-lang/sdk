@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:primal/compiler/platform/directory/platform_directory_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformDirectoryCli platform;
  late Directory tempDir;

  setUp(() {
    platform = PlatformDirectoryCli();
    tempDir = Directory.systemTemp.createTempSync('primal_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PlatformDirectoryCli', () {
    test('fromPath creates a Directory object', () {
      final Directory directory = platform.fromPath(tempDir.path);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(tempDir.path));
    });

    test('exists returns true for existing directory', () {
      expect(platform.exists(tempDir), isTrue);
    });

    test('exists returns false for nonexistent directory', () {
      final Directory directory = Directory('${tempDir.path}/nope');

      expect(platform.exists(directory), isFalse);
    });

    test('create creates a directory', () {
      final Directory directory = Directory('${tempDir.path}/newdir');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('create creates nested directories', () {
      final Directory directory = Directory('${tempDir.path}/a/b/c');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('delete removes a directory', () {
      final Directory directory = Directory('${tempDir.path}/todelete')
        ..createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('delete returns false for nonexistent directory', () {
      final Directory directory = Directory('${tempDir.path}/nope');

      expect(platform.delete(directory), isFalse);
    });

    test('path returns absolute path', () {
      expect(platform.path(tempDir), contains(tempDir.path));
    });

    test('name returns directory name', () {
      final Directory directory = Directory('${tempDir.path}/mydir')
        ..createSync();

      expect(platform.name(directory), equals('mydir'));
    });

    test('parent returns parent directory', () {
      final Directory directory = Directory('${tempDir.path}/child')
        ..createSync();

      expect(platform.parent(directory).path, equals(tempDir.path));
    });

    test('rename renames a directory', () {
      final Directory directory = Directory('${tempDir.path}/old')
        ..createSync();

      expect(platform.rename(directory, 'new'), isTrue);
      expect(Directory('${tempDir.path}/new').existsSync(), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('list returns directory contents', () {
      File('${tempDir.path}/a.txt').createSync();
      File('${tempDir.path}/b.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(tempDir);

      expect(contents.length, equals(2));
    });

    test('copy copies directory with contents', () {
      final Directory source = Directory('${tempDir.path}/src')..createSync();
      File('${source.path}/file.txt').writeAsStringSync('data');
      final Directory destination = Directory('${tempDir.path}/dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/file.txt').readAsStringSync(),
        equals('data'),
      );
    });

    test('copy recursively copies subdirectories', () {
      final Directory source = Directory('${tempDir.path}/src2')..createSync();
      final Directory subDirectory = Directory('${source.path}/sub')
        ..createSync();
      File('${subDirectory.path}/nested.txt').writeAsStringSync('nested');
      final Directory destination = Directory('${tempDir.path}/dst2');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/sub/nested.txt').readAsStringSync(),
        equals('nested'),
      );
    });

    test('copy copies empty directory', () {
      final Directory source = Directory('${tempDir.path}/empty_src')
        ..createSync();
      final Directory destination = Directory('${tempDir.path}/empty_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(destination.listSync(), isEmpty);
    });

    test('copy returns false for nonexistent source', () {
      final Directory source = Directory('${tempDir.path}/nonexistent_src');
      final Directory destination = Directory('${tempDir.path}/copy_dst');

      expect(platform.copy(source, destination), isFalse);
    });

    test('move moves a directory', () {
      final Directory source = Directory('${tempDir.path}/mv_src')
        ..createSync();
      File('${source.path}/f.txt').createSync();
      final Directory destination = Directory('${tempDir.path}/mv_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
    });

    test('move returns false for nonexistent source', () {
      final Directory source = Directory('${tempDir.path}/nonexistent_mv');
      final Directory destination = Directory('${tempDir.path}/mv_dst_fail');

      expect(platform.move(source, destination), isFalse);
    });

    test('rename returns false for nonexistent directory', () {
      final Directory directory = Directory(
        '${tempDir.path}/nonexistent_rename',
      );

      expect(platform.rename(directory, 'newname'), isFalse);
    });

    test('delete removes directory with contents recursively', () {
      final Directory directory = Directory('${tempDir.path}/delete_recursive')
        ..createSync();
      final Directory subDirectory = Directory('${directory.path}/subdir')
        ..createSync();
      File('${directory.path}/file.txt').createSync();
      File('${subDirectory.path}/nested.txt').createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('list returns empty list for empty directory', () {
      final Directory emptyDirectory = Directory('${tempDir.path}/empty_list')
        ..createSync();

      final List<FileSystemEntity> contents = platform.list(emptyDirectory);

      expect(contents, isEmpty);
    });

    test('list returns files and subdirectories', () {
      final Directory directory = Directory('${tempDir.path}/mixed')
        ..createSync();
      File('${directory.path}/file.txt').createSync();
      Directory('${directory.path}/subdir').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.length, equals(2));
      expect(contents.whereType<File>().length, equals(1));
      expect(contents.whereType<Directory>().length, equals(1));
    });

    test('path returns absolute path for relative directory', () {
      final Directory directory = Directory('.');

      final String result = platform.path(directory);

      expect(result, startsWith('/'));
    });

    test('name returns directory name for deeply nested path', () {
      final Directory directory = Directory('${tempDir.path}/a/b/c/deep')
        ..createSync(recursive: true);

      expect(platform.name(directory), equals('deep'));
    });

    test('parent returns correct parent for deeply nested directory', () {
      final Directory directory = Directory('${tempDir.path}/level1/level2')
        ..createSync(recursive: true);

      final Directory parentDirectory = platform.parent(directory);

      expect(parentDirectory.path, endsWith('level1'));
    });

    test('fromPath with empty string creates directory object', () {
      final Directory directory = platform.fromPath('');

      expect(directory, isA<Directory>());
      expect(directory.path, equals(''));
    });

    test('create returns true for already existing directory', () {
      final Directory directory = Directory('${tempDir.path}/already_exists')
        ..createSync();

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('copy preserves file content across multiple files', () {
      final Directory source = Directory('${tempDir.path}/multi_src')
        ..createSync();
      File('${source.path}/a.txt').writeAsStringSync('content_a');
      File('${source.path}/b.txt').writeAsStringSync('content_b');
      final Directory destination = Directory('${tempDir.path}/multi_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/a.txt').readAsStringSync(),
        equals('content_a'),
      );
      expect(
        File('${destination.path}/b.txt').readAsStringSync(),
        equals('content_b'),
      );
    });

    test('move preserves file content', () {
      final Directory source = Directory('${tempDir.path}/mv_content_src')
        ..createSync();
      File('${source.path}/data.txt').writeAsStringSync('important_data');
      final Directory destination = Directory('${tempDir.path}/mv_content_dst');

      expect(platform.move(source, destination), isTrue);
      expect(
        File('${destination.path}/data.txt').readAsStringSync(),
        equals('important_data'),
      );
    });
  });
}
