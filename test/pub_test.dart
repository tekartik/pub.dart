@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
//import 'package:process_run/src/process_cmd.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/dartbin.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/pub.dart';
import 'dart:async';
import 'dart:io';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;

void main() => defineTests();

Future<String> get _pubPackageRoot => getPubPackageRoot(testScriptPath);

void defineTests() {
  //useVMConfiguration();
  group('pub', () {
    test('version', () async {
      ProcessResult result =
          await run(dartExecutable, pubArguments(['--version']));
      expect(result.stdout.startsWith("Pub"), isTrue);
    });

    _testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageRoot(path), expected);
      expect(isPubPackageRootSync(path), expected);
    }

    test('root', () async {
      _testIsPubPackageRoot(dirname(testScriptPath), false);
      _testIsPubPackageRoot(dirname(dirname(dirname(testScriptPath))), false);
      _testIsPubPackageRoot(dirname(dirname(testScriptPath)), true);
      expect(await _pubPackageRoot, dirname(dirname(testScriptPath)));
      try {
        await getPubPackageRoot(join('/', 'dummy', 'path'));
        fail('no');
      } catch (e) {}
    });

    group('pub_package', () {
      test('runTest', () async {
        PubPackage pkg = new PubPackage(await _pubPackageRoot);
        ProcessResult result = await runCmd(pkg.testCmd(
            ['test/data/success_test_.dart'],
            platforms: ["vm"],
            reporter: TestReporter.EXPANDED,
            concurrency: 1));

        // on 1.13, current windows is failing
        if (!Platform.isWindows) {
          expect(result.exitCode, 0);
        }
        result =
            await runCmd(pkg.testCmd(['test/data/fail_test_.dart']));
        if (!Platform.isWindows) {
          expect(result.exitCode, 1);
        }
      });
    });
  });
}
