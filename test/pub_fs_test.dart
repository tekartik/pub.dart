@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
//import 'package:process_run/src/process_cmd.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/dartbin.dart';
import 'package:dev_test/test.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:tekartik_pub/pub.dart' show pubRunTestArgs, TestReporter;
import 'dart:async';
import 'package:tekartik_pub/pub_fs.dart';
import 'package:tekartik_pub/pub_fs_io.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
//String get packageRoot => dirname(dirname(testScriptPath));

void main() => defineTests();

Future<Directory> get _pubPackageDir =>
    getPubPackageDir(new Directory(testScriptPath));

void defineTests() {
  //useVMConfiguration();
  group('pub_io', () {
    test('version', () async {
      ProcessResult result =
          await run(dartExecutable, pubArguments(['--version']));
      expect(result.stdout.startsWith("Pub"), isTrue);
    });

    _testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageDir(new Directory(path)), expected);
    }

    test('root', () async {
      await _testIsPubPackageRoot(dirname(testScriptPath), false);
      await _testIsPubPackageRoot(
          dirname(dirname(dirname(testScriptPath))), false);
      await _testIsPubPackageRoot(dirname(dirname(testScriptPath)), true);
      expect((await _pubPackageDir).path, dirname(dirname(testScriptPath)));
      try {
        await getPubPackageDir(new Directory(join('/', 'dummy', 'path')));
        fail('no');
      } catch (e) {}
    });

    group('pub_package', () {
      test('runTest', () async {
        FsPubPackage pkg = new FsPubPackage(await _pubPackageDir);
        ProcessResult result = await runCmd(pkg.prepareCmd(pubCmd(
            pubRunTestArgs(
                args: ['test/data/success_test_.dart'],
                platforms: ["vm"],
                reporter: TestReporter.EXPANDED,
                concurrency: 1))));

        // on 1.13, current windows is failing
        if (!Platform.isWindows) {
          expect(result.exitCode, 0);
        }

        IoFsPubPackage ioPkg = new IoFsPubPackage(await _pubPackageDir);
        result = await runCmd(
            ioPkg.pubCmd(pubRunTestArgs(args: ['test/data/fail_test_.dart'])));
        if (!Platform.isWindows) {
          expect(result.exitCode, 1);
        }
      });

      test('name', () async {
        FsPubPackage pkg = new FsPubPackage(await _pubPackageDir);
        expect(await pkg.extractPackageName(), 'tekartik_pub');
      });
    });
  });
}
