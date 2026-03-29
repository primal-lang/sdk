@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/utils/file_reader.dart';
import 'package:test/test.dart';

void main() {
  group('FileReader', () {
    late File tempFile;

    setUp(() {
      tempFile = File(
        '${Directory.systemTemp.path}/primal_test_file_reader.txt',
      );
      tempFile.writeAsStringSync('test content');
    });

    tearDown(() {
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    test('read returns file contents', () {
      expect(FileReader.read(tempFile.path), 'test content');
    });

    test('read returns multiline content', () {
      tempFile.writeAsStringSync('line1\nline2\nline3');
      expect(FileReader.read(tempFile.path), 'line1\nline2\nline3');
    });

    test('read returns empty string for empty file', () {
      tempFile.writeAsStringSync('');
      expect(FileReader.read(tempFile.path), '');
    });

    test('read throws on non-existent file', () {
      expect(
        () => FileReader.read('/tmp/primal_nonexistent_12345.txt'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
