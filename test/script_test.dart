@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/script.dart';
import 'package:path/path.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;

// This script resolver
class TestScript extends Script {}

// Test directory
String get testDirPath => dirname(getScriptPath(TestScript));

void main() {
  //useVMConfiguration();
  test('script', () async {
    expect(getScriptPath(TestScript), testScriptPath);
    expect(getScriptPath(TestScript), new TestScript().path);
    expect(testDirPath, dirname(testScriptPath));
  });
}
