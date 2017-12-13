@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
//import 'package:process_run/src/process_cmd.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/dartbin.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/src/pub_io.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get packageRoot => dirname(dirname(testScriptPath));

void main() => defineTests();

Future<String> get _pubPackageRoot => getPubPackageRoot(testScriptPath);

void defineTests() {
  //useVMConfiguration();
  group('src_pub_io', () {
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
      await _testIsPubPackageRoot(dirname(testScriptPath), false);
      await _testIsPubPackageRoot(
          dirname(dirname(dirname(testScriptPath))), false);
      await _testIsPubPackageRoot(dirname(dirname(testScriptPath)), true);
      expect(await _pubPackageRoot, dirname(dirname(testScriptPath)));
      try {
        await getPubPackageRoot(join('/', 'dummy', 'path'));
        fail('no');
      } catch (e) {}
    });

    group('pub_package', () {
      test('runTest', () async {
        IoPubPackage pkg = new IoPubPackage(await _pubPackageRoot);
        ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: ['test/data/success_test_.dart'],
            platforms: ["vm"],
            reporter: RunTestReporter.JSON,
            concurrency: 1)));

        // on 1.13, current windows is failing
        if (!Platform.isWindows) {
          expect(result.exitCode, 0);
        }
        Map testResult = JSON.decode(LineSplitter.split(result.stdout).last);
        expect(testResult['success'], isTrue);

        result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: ['test/data/fail_test_.dart'],
            reporter: RunTestReporter.JSON)));
        if (!Platform.isWindows) {
          expect(result.exitCode, 1);
        }
        testResult = JSON.decode(LineSplitter.split(result.stdout).last);
        expect(testResult['success'], isFalse);
      });

      test('name', () async {
        IoPubPackage pkg = new IoPubPackage(await _pubPackageRoot);
        expect(pkg.name, 'tekartik_pub');
      });
    });
  });
}
