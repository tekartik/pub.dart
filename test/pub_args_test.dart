@TestOn("vm")
library tekartik_pub.test.pub_args_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/pub.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get packageRoot => dirname(dirname(testScriptPath));

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('pub_args', () {
    test('pubArgs', () {
      expect(pubArgs(), []);
      expect(pubArgs(version: true), ['--version']);
      expect(pubArgs(help: true), ['--help']);
      expect(pubArgs(verbose: true), ['--verbose']);
    });

    test('pubBuildArgs', () {
      expect(pubBuildArgs(), ['build']);
      expect(pubBuildArgs(output: 'out'), ['build', '--output', 'out']);
      expect(pubBuildArgs(mode: 'debug'), ['build', '--mode', 'debug']);
      expect(pubBuildArgs(format: 'json'), ['build', '--format', 'json']);
      expect(pubBuildArgs(args: ['web']), ['build', 'web']);
    });

    test('pubRunTestArgs', () {
      expect(pubRunTestArgs(), ['run', "test"]);
    });

    test('pubGetArgs', () {
      expect(pubGetArgs(), ['get']);
    });

    test('pubUpgradeArgs', () {
      expect(pubUpgradeArgs(), ['upgrade']);
    });
  });
}
