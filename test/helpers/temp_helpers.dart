import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Directory createTempTestDirectory([String prefix = 'primal_test_']) {
  final Directory directory = Directory.systemTemp.createTempSync(prefix);

  addTearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  return directory;
}

String primalString(String value) => jsonEncode(value);
