@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'package:dev_test/test.dart';
import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/pub_io.dart';
import 'dart:io';
import 'package:tekartik_pub/pub_fs_io.dart' as fs;
import 'package:fs_shim/utils/entity.dart' as fs;
import 'package:tekartik_pub/script.dart';
import 'test_common.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get projectTop => dirname(dirname(testScriptPath));
String get simpleProjectTop => join(projectTop, 'example', 'simple');

class TestScript extends Script {}

fs.Directory get pkgDir => new fs.File(getScriptPath(TestScript)).parent.parent;
fs.Directory get simplePkgDir =>
    fs.childDirectory(pkgDir, join('example', 'simple'));
fs.Directory get outDir =>
    fs.childDirectory(pkgDir, join(testOutTopPath, joinAll(testDescriptions)));
main() {
  group('example_simple', () {
    fs.IoFsPubPackage fsPkg;
    IoPubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      // use fs for cloning
      fs.IoFsPubPackage simplePkg = new fs.IoFsPubPackage(simplePkgDir);
      // clone the package in a temp output location

      fsPkg = await simplePkg.clone(outDir, delete: true);

      pkg = new IoPubPackage(fsPkg.dir.path);
    });

    test('get', () async {
      ProcessResult result = await runCmd(
          pkg.pubCmd(pubGetArgs(offline: true))..connectStderr = false);
      expect(result.exitCode, 0);
    });
    test('upgrade', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubUpgradeArgs(offline: true, dryRun: true)));
      expect(result.exitCode, 0);
    });
    test('test', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    });
    test('build', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubBuildArgs()));
      expect(result.exitCode, 0);
    });
  });
}
