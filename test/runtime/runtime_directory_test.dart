import 'dart:io';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';
import '../helpers/resource_helpers.dart';

void main() {
  group('Directory', () {
    test('directory.fromPath', () {
      final Runtime runtime = getRuntime(
        'main = directory.fromPath("test/resources/files")',
      );
      checkResult(runtime, '"$resourcesPath/files"');
    });

    test('directory.exists 1', () {
      final Runtime runtime = getRuntime(
        'main = directory.exists(directory.fromPath("test/resources/files"))',
      );
      checkResult(runtime, true);
    });

    test('directory.exists 2', () {
      final Runtime runtime = getRuntime(
        'main = directory.exists(directory.fromPath("test/resources/filesX"))',
      );
      checkResult(runtime, false);
    });

    test('directory.create', () {
      final String id = DateTime.now().day.toString();
      final Runtime runtime = getRuntime(
        'main = directory.create(directory.fromPath("test/resources/files/temp$id"))',
      );
      final dynamic result = runtime.executeMain();
      expect(result, 'true');
      final bool fileExists = Directory(
        '$resourcesPath/files/temp$id',
      ).existsSync();
      expect(true, fileExists);
    });

    test('directory.delete 1', () {
      final String id = DateTime.now().day.toString();
      final Runtime runtime = getRuntime(
        'main = directory.delete(directory.fromPath("test/resources/files/temp$id"))',
      );
      checkResult(runtime, true);
    });

    test('directory.delete 2', () {
      final Runtime runtime = getRuntime(
        'main = directory.delete(directory.fromPath("test/resources/files/tempX"))',
      );
      checkResult(runtime, false);
    });

    test('directory.copy', () {
      final Runtime runtime = getRuntime('''
directory1 = directory.fromPath("test/resources/files/temp")
directory2 = directory.fromPath("test/resources/files/temp_new")
main = directory.copy(directory1(), directory2())
''');
      checkResult(runtime, true);
    });

    test('directory.move', () {
      final Runtime runtime = getRuntime('''
directory1 = directory.fromPath("test/resources/files/temp_new")
directory2 = directory.fromPath("test/resources/files/temp_extra")
main = directory.move(directory1(), directory2())
''');
      checkResult(runtime, true);
    });

    test('directory.rename', () {
      final Runtime runtime = getRuntime(
        'main = directory.rename(directory.fromPath("test/resources/files/temp_extra"), "temp_new")',
      );
      checkResult(runtime, true);
    });

    test('directory.path', () {
      final Runtime runtime = getRuntime(
        'main = directory.path(directory.fromPath("test/resources/files/temp"))',
      );
      checkResult(runtime, '"$resourcesPath/files/temp"');
    });

    test('directory.name', () {
      final Runtime runtime = getRuntime(
        'main = directory.name(directory.fromPath("test/resources/files/temp"))',
      );
      checkResult(runtime, '"temp"');
    });

    test('directory.parent', () {
      final Runtime runtime = getRuntime(
        'main = directory.parent(directory.fromPath("test/resources/files/temp"))',
      );
      checkResult(runtime, '"$resourcesPath/files"');
    });

    test('directory.list', () {
      final Runtime runtime = getRuntime(
        'main = directory.list(directory.fromPath("test/resources/files/temp"))',
      );
      checkResult(runtime, [
        '"$resourcesPath/files/temp/file_temp.txt"',
        '"$resourcesPath/files/temp/file3.txt"',
      ]);
    });
  });
}
