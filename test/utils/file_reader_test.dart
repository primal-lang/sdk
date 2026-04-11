@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/utils/file_reader.dart';
import 'package:test/test.dart';

void main() {
  group('FileReader', () {
    late File tempFile;
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp;
      tempFile = File('${tempDirectory.path}/primal_test_file_reader.txt');
      tempFile.writeAsStringSync('test content');
    });

    tearDown(() {
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    group('read', () {
      group('basic functionality', () {
        test('returns file contents', () {
          final String result = FileReader.read(tempFile.path);
          expect(result, 'test content');
        });

        test('returns empty string for empty file', () {
          tempFile.writeAsStringSync('');
          final String result = FileReader.read(tempFile.path);
          expect(result, '');
        });
      });

      group('multiline content', () {
        test('returns multiline content with Unix line endings', () {
          tempFile.writeAsStringSync('line1\nline2\nline3');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'line1\nline2\nline3');
        });

        test('returns content with Windows line endings (CRLF)', () {
          tempFile.writeAsStringSync('line1\r\nline2\r\nline3');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'line1\r\nline2\r\nline3');
        });

        test('returns content with mixed line endings', () {
          tempFile.writeAsStringSync('line1\nline2\r\nline3\rline4');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'line1\nline2\r\nline3\rline4');
        });

        test('returns content with trailing newline', () {
          tempFile.writeAsStringSync('content\n');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'content\n');
        });

        test('returns content with multiple trailing newlines', () {
          tempFile.writeAsStringSync('content\n\n\n');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'content\n\n\n');
        });

        test('returns content with leading newlines', () {
          tempFile.writeAsStringSync('\n\ncontent');
          final String result = FileReader.read(tempFile.path);
          expect(result, '\n\ncontent');
        });
      });

      group('whitespace content', () {
        test('returns content with only spaces', () {
          tempFile.writeAsStringSync('   ');
          final String result = FileReader.read(tempFile.path);
          expect(result, '   ');
        });

        test('returns content with only tabs', () {
          tempFile.writeAsStringSync('\t\t\t');
          final String result = FileReader.read(tempFile.path);
          expect(result, '\t\t\t');
        });

        test('returns content with mixed whitespace', () {
          tempFile.writeAsStringSync(' \t \n \t\n');
          final String result = FileReader.read(tempFile.path);
          expect(result, ' \t \n \t\n');
        });

        test('returns content with leading and trailing whitespace', () {
          tempFile.writeAsStringSync('  content  ');
          final String result = FileReader.read(tempFile.path);
          expect(result, '  content  ');
        });
      });

      group('special characters', () {
        test('returns content with unicode characters', () {
          tempFile.writeAsStringSync('Hello \u00e9\u00e8\u00ea \u00e0\u00e2');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'Hello \u00e9\u00e8\u00ea \u00e0\u00e2');
        });

        test('returns content with emoji characters', () {
          tempFile.writeAsStringSync('Hello \u{1F600}\u{1F389}\u{1F680}');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'Hello \u{1F600}\u{1F389}\u{1F680}');
        });

        test('returns content with Chinese characters', () {
          tempFile.writeAsStringSync('\u4f60\u597d\u4e16\u754c');
          final String result = FileReader.read(tempFile.path);
          expect(result, '\u4f60\u597d\u4e16\u754c');
        });

        test('returns content with Arabic characters', () {
          tempFile.writeAsStringSync('\u0645\u0631\u062d\u0628\u0627');
          final String result = FileReader.read(tempFile.path);
          expect(result, '\u0645\u0631\u062d\u0628\u0627');
        });

        test('returns content with special punctuation', () {
          tempFile.writeAsStringSync('!@#\$%^&*()_+-=[]{}|;:\'",.<>?/\\`~');
          final String result = FileReader.read(tempFile.path);
          expect(result, '!@#\$%^&*()_+-=[]{}|;:\'",.<>?/\\`~');
        });

        test('returns content with null character', () {
          tempFile.writeAsStringSync('before\x00after');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'before\x00after');
        });

        test('returns content with escape sequences', () {
          tempFile.writeAsStringSync('tab:\there\nnewline');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'tab:\there\nnewline');
        });
      });

      group('large content', () {
        test('returns content with very long single line', () {
          final String longLine = 'a' * 10000;
          tempFile.writeAsStringSync(longLine);
          final String result = FileReader.read(tempFile.path);
          expect(result, longLine);
          expect(result.length, 10000);
        });

        test('returns content with many lines', () {
          final String manyLines = List.generate(
            1000,
            (index) => 'line$index',
          ).join('\n');
          tempFile.writeAsStringSync(manyLines);
          final String result = FileReader.read(tempFile.path);
          expect(result, manyLines);
          expect(result.split('\n').length, 1000);
        });
      });

      group('error handling', () {
        test('throws FileSystemException on non-existent file', () {
          expect(
            () => FileReader.read('/tmp/primal_nonexistent_12345.txt'),
            throwsA(isA<FileSystemException>()),
          );
        });

        test('throws FileSystemException on directory path', () {
          expect(
            () => FileReader.read(tempDirectory.path),
            throwsA(isA<FileSystemException>()),
          );
        });

        test('throws FileSystemException on empty path', () {
          expect(
            () => FileReader.read(''),
            throwsA(isA<FileSystemException>()),
          );
        });

        test('throws FileSystemException on path with only spaces', () {
          expect(
            () => FileReader.read('   '),
            throwsA(isA<FileSystemException>()),
          );
        });

        test('throws on invalid path characters', () {
          expect(
            () => FileReader.read('/tmp/\x00invalid'),
            throwsA(isA<FileSystemException>()),
          );
        });
      });

      group('path handling', () {
        test('reads file with absolute path', () {
          final String absolutePath = tempFile.absolute.path;
          final String result = FileReader.read(absolutePath);
          expect(result, 'test content');
        });

        test('reads file with spaces in name', () {
          final File fileWithSpaces = File(
            '${tempDirectory.path}/primal test file with spaces.txt',
          );
          fileWithSpaces.writeAsStringSync('spaced content');
          addTearDown(() {
            if (fileWithSpaces.existsSync()) {
              fileWithSpaces.deleteSync();
            }
          });

          final String result = FileReader.read(fileWithSpaces.path);
          expect(result, 'spaced content');
        });

        test('reads file with special characters in name', () {
          final File fileWithSpecialChars = File(
            '${tempDirectory.path}/primal_test_file-with.special_chars.txt',
          );
          fileWithSpecialChars.writeAsStringSync('special name content');
          addTearDown(() {
            if (fileWithSpecialChars.existsSync()) {
              fileWithSpecialChars.deleteSync();
            }
          });

          final String result = FileReader.read(fileWithSpecialChars.path);
          expect(result, 'special name content');
        });

        test('reads file with unicode characters in name', () {
          final File fileWithUnicode = File(
            '${tempDirectory.path}/primal_test_\u00e9\u00e0\u00fc.txt',
          );
          fileWithUnicode.writeAsStringSync('unicode name content');
          addTearDown(() {
            if (fileWithUnicode.existsSync()) {
              fileWithUnicode.deleteSync();
            }
          });

          final String result = FileReader.read(fileWithUnicode.path);
          expect(result, 'unicode name content');
        });
      });

      group('symbolic links', () {
        test('reads content through symbolic link', () {
          final Link symbolicLink = Link(
            '${tempDirectory.path}/primal_test_symlink.txt',
          );

          try {
            symbolicLink.createSync(tempFile.path);
          } on FileSystemException {
            // Skip test if symbolic links are not supported
            return;
          }

          addTearDown(() {
            if (symbolicLink.existsSync()) {
              symbolicLink.deleteSync();
            }
          });

          final String result = FileReader.read(symbolicLink.path);
          expect(result, 'test content');
        });

        test('throws on broken symbolic link', () {
          final File targetFile = File(
            '${tempDirectory.path}/primal_test_target.txt',
          );
          targetFile.writeAsStringSync('target content');

          final Link symbolicLink = Link(
            '${tempDirectory.path}/primal_test_broken_symlink.txt',
          );

          try {
            symbolicLink.createSync(targetFile.path);
          } on FileSystemException {
            // Skip test if symbolic links are not supported
            targetFile.deleteSync();
            return;
          }

          // Delete the target to create a broken link
          targetFile.deleteSync();

          addTearDown(() {
            if (symbolicLink.existsSync()) {
              symbolicLink.deleteSync();
            }
          });

          expect(
            () => FileReader.read(symbolicLink.path),
            throwsA(isA<FileSystemException>()),
          );
        });
      });

      group('file content edge cases', () {
        test('returns single character content', () {
          tempFile.writeAsStringSync('x');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'x');
        });

        test('returns single newline content', () {
          tempFile.writeAsStringSync('\n');
          final String result = FileReader.read(tempFile.path);
          expect(result, '\n');
        });

        test('returns content with consecutive empty lines', () {
          tempFile.writeAsStringSync('line1\n\n\n\nline2');
          final String result = FileReader.read(tempFile.path);
          expect(result, 'line1\n\n\n\nline2');
        });

        test('returns content with BOM stripped by Dart runtime', () {
          // UTF-8 BOM is automatically stripped by Dart's readAsStringSync
          tempFile.writeAsBytesSync([
            0xEF,
            0xBB,
            0xBF,
            ...('content'.codeUnits),
          ]);
          final String result = FileReader.read(tempFile.path);
          // Dart strips the BOM, so the result should not contain it
          expect(result, 'content');
          expect(result.startsWith('\uFEFF'), isFalse);
        });

        test('returns JSON content unchanged', () {
          const String jsonContent = '{"key": "value", "number": 42}';
          tempFile.writeAsStringSync(jsonContent);
          final String result = FileReader.read(tempFile.path);
          expect(result, jsonContent);
        });

        test('returns XML content unchanged', () {
          const String xmlContent =
              '<?xml version="1.0"?><root><item>value</item></root>';
          tempFile.writeAsStringSync(xmlContent);
          final String result = FileReader.read(tempFile.path);
          expect(result, xmlContent);
        });

        test('returns code content unchanged', () {
          const String codeContent = 'void main() {\n  print("Hello");\n}';
          tempFile.writeAsStringSync(codeContent);
          final String result = FileReader.read(tempFile.path);
          expect(result, codeContent);
        });
      });
    });
  });
}
