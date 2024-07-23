import 'dart:io';

class FileReader {
  static String read(String filePath) {
    final File file = File(filePath);

    return file.readAsStringSync();
  }
}
