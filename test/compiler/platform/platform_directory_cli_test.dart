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

    test('move moves a directory', () {
      final Directory source = Directory('${tempDir.path}/mv_src')
        ..createSync();
      File('${source.path}/f.txt').createSync();
      final Directory destination = Directory('${tempDir.path}/mv_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
    });
  });
}
