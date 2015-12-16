@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'package:dev_test/test.dart';
import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/pub_io.dart';
import 'dart:io';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get projectTop => dirname(dirname(testScriptPath));
String get simpleProjectTop => join(projectTop, 'example', 'simple');

main() {
  group('example_simple', () {
    test('get', () async {
      IoPubPackage pkg = new IoPubPackage(simpleProjectTop);
      ProcessResult result = await runCmd(
          pkg.pubCmd(pubGetArgs(offline: true))..connectStderr = true);
      expect(result.exitCode, 0);
    });
    test('upgrade', () async {
      IoPubPackage pkg = new IoPubPackage(simpleProjectTop);
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubUpgradeArgs(offline: true, dryRun: true)));
      expect(result.exitCode, 0);
    });
    test('test', () async {
      IoPubPackage pkg = new IoPubPackage(simpleProjectTop);
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    });
    test('build', () async {
      IoPubPackage pkg = new IoPubPackage(simpleProjectTop);
      ProcessResult result = await runCmd(pkg.pubCmd(pubBuildArgs()));
      expect(result.exitCode, 0);
    });
  });
}
