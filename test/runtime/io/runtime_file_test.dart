@TestOn('vm')
library;

import 'dart:io';
import 'dart:math';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/resource_helpers.dart';

void main() {
  group('File', () {
    test('file.fromPath', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath("test/resources/files/file1.txt")',
      );
      checkResult(runtime, '"$resourcesPath/files/file1.txt"');
    });

    test('file.exists returns true for existing file', () {
      final Runtime runtime = getRuntime(
        'main = file.exists(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, true);
    });

    test('file.exists returns false for non-existing file', () {
      final Runtime runtime = getRuntime(
        'main = file.exists(file.fromPath("test/resources/files/file0.txt"))',
      );
      checkResult(runtime, false);
    });

    test('file.read', () {
      final Runtime runtime = getRuntime(
        'main = file.read(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('file.write', () {
      final String value = Random().nextInt(10000).toString();
      final Runtime runtime = getRuntime('''
testFile(file, value) = file.write(file, value)
main = testFile(file.fromPath("test/resources/files/temp/file_temp.txt"), "$value")
''');
      checkResult(runtime, true);
    });

    test('file.length', () {
      final Runtime runtime = getRuntime(
        'main = file.length(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, 13);
    });

    test('file.create', () {
      final String id = DateTime.now().day.toString();
      final Runtime runtime = getRuntime(
        'main = file.create(file.fromPath("test/resources/files/temp/file$id.txt"))',
      );
      final dynamic result = runtime.executeMain();
      expect(result, 'true');
      final bool fileExists = File(
        '$resourcesPath/files/temp/file$id.txt',
      ).existsSync();
      expect(true, fileExists);
    });

    test('file.delete returns true for existing file', () {
      final String id = DateTime.now().day.toString();
      final Runtime runtime = getRuntime(
        'main = file.delete(file.fromPath("test/resources/files/temp/file$id.txt"))',
      );
      checkResult(runtime, true);
    });

    test('file.delete returns false for non-existing file', () {
      final Runtime runtime = getRuntime(
        'main = file.delete(file.fromPath("test/resources/files/temp2/file1.txt"))',
      );
      checkResult(runtime, false);
    });

    test('file.path', () {
      final Runtime runtime = getRuntime(
        'main = file.path(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, '"$resourcesPath/files/file1.txt"');
    });

    test('file.name', () {
      final Runtime runtime = getRuntime(
        'main = file.name(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, '"file1.txt"');
    });

    test('file.extension', () {
      final Runtime runtime = getRuntime(
        'main = file.extension(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, '"txt"');
    });

    test('file.copy', () {
      final Runtime runtime = getRuntime('''
file1 = file.fromPath("test/resources/files/file1.txt")
file2 = file.fromPath("test/resources/files/file2.txt")
main = file.copy(file1(), file2())
''');
      checkResult(runtime, true);
    });

    test('file.move', () {
      final Runtime runtime = getRuntime('''
file1 = file.fromPath("test/resources/files/file2.txt")
file2 = file.fromPath("test/resources/files/temp/file2.txt")
main = file.move(file1(), file2())
''');
      checkResult(runtime, true);
    });

    test('file.parent', () {
      final Runtime runtime = getRuntime(
        'main = file.parent(file.fromPath("test/resources/files/file1.txt"))',
      );
      checkResult(runtime, '"$resourcesPath/files"');
    });

    test('file.rename', () {
      final Runtime runtime = getRuntime(
        'main = file.rename(file.fromPath("test/resources/files/temp/file2.txt"), "file3.txt")',
      );
      checkResult(runtime, true);
    });
  });
}
