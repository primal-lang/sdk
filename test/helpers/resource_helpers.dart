import 'dart:io';

String loadFile(String path) {
  final File file = File('./test/resources/$path');

  return file.readAsStringSync();
}

String get resourcesPath => File('test/resources').absolute.path;
