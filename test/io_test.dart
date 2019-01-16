@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'dart:async';
import 'dart:io';

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

import 'test_common.dart';
import 'test_common_io.dart';

void main() => defineTests();

String get packageRoot => '.';

void defineTests() {
  //useVMConfiguration();
  group('io', () {
    PubPackage pkg = PubPackage('.');

    test('equals', () {
      PubPackage pkg1 = PubPackage(packageRoot);
      expect(pkg1, pkg1);
      PubPackage pkg2 = PubPackage(packageRoot);
      expect(pkg1.hashCode, pkg2.hashCode);
      expect(pkg1, pkg2);
    });

    test('version', () async {
      PubPackage pkg = PubPackage(packageRoot);
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      //print(result);
      expect(result.stdout, startsWith("Pub"));
    });

    test('run', () async {
      PubPackage pkg = PubPackage(packageRoot);
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      //print(result);
      expect(result.stdout, startsWith("Pub"));
    });

    Future _testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageRoot(path), expected);
      expect(isPubPackageRootSync(path), expected);
    }

    test('root', () async {
      await _testIsPubPackageRoot('test', false);
      await _testIsPubPackageRoot('..', false);
      await _testIsPubPackageRoot('.', true);
      try {
        await getPubPackageRoot(join('/', 'dummy', 'path'));
        fail('no');
      } catch (_) {}
    });
    // use pk.runCmd and then pkg.pubCmd

    test('success_test', () async {
      var testPath = join('test', 'success_test.dart');
      try {
        await File(join('test', 'data', 'success_test_.dart')).copy(testPath);
        ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: [testPath],
            platforms: ["vm"],
            //reporter: pubRunTestReporterJson,
            reporter: RunTestReporter.JSON,
            concurrency: 1)));

        expect(result.exitCode, 0, reason: result.stdout?.toString());
        expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
        expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
        expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
      } finally {
        try {
          await File(testPath).delete();
        } catch (_) {}
      }
    }, timeout: Timeout(Duration(minutes: 2)));

    test('pbr_success_test_to_fix', () async {
      var testPath = join('test', 'success_test.dart');
      try {
        await File(join('test', 'data', 'success_test_.dart')).copy(testPath);
        ProcessResult result =
            await runCmd(pkg.pbrCmd(['test', '--']..addAll(testRunnerArgs(
                args: [testPath],
                platforms: ["vm"],
                //reporter: pubRunTestReporterJson,
                reporter: RunTestReporter.JSON,
                concurrency: 1))));

        expect(result.exitCode, 0, reason: result.stdout?.toString());
        expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
        expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
        expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
      } finally {
        try {
          await File(testPath).delete();
        } catch (_) {}
      }
    }, skip: true, timeout: Timeout(Duration(minutes: 2)));

    test('pbr_success_test', () async {
      var testPath = join('test', 'success_test.dart');
      try {
        await File(join('test', 'data', 'success_test_.dart')).copy(testPath);
        ProcessResult result =
            await runCmd(pkg.pbrCmd(['test', '--']..addAll(testRunnerArgs(
                args: [testPath],
                platforms: ["vm"],
                //reporter: pubRunTestReporterJson,
                //reporter: RunTestReporter.JSON,
                concurrency: 1))));

        expect(result.exitCode, 0, reason: result.stdout?.toString());
        //expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
        //expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
        //expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
      } finally {
        try {
          await File(testPath).delete();
        } catch (_) {}
      }
    }, timeout: Timeout(Duration(minutes: 2)));
    /*
    test('expanded_success_test', () async {
      ProcessResult result = await devRunCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          //reporter: pubRunTestReporterJson,
          reporter: RunTestReporter.EXPANDED,
          concurrency: 1)));

      expect(result.exitCode, 0);
    });
    */

    test('failure_test', () async {
      var failTestPath = join('test', 'fail_test.dart');
      try {
        if (!Platform.isWindows) {
          await File(join('test', 'data', 'fail_test_.dart'))
              .copy(failTestPath);
          ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
              args: [failTestPath], reporter: RunTestReporter.JSON)));
          //if (!Platform.isWindows) {
          expect(result.exitCode, 1);
          //}
          expect(pubRunTestJsonIsSuccess(result.stdout as String), isFalse);
          expect(pubRunTestJsonSuccessCount(result.stdout as String), 0);
          expect(pubRunTestJsonFailureCount(result.stdout as String), 1);
        }
      } finally {
        try {
          await File(failTestPath).delete();
        } catch (_) {}
      }
    }, timeout: Timeout(Duration(minutes: 2)));

    test('pbr_failure_test_to_fix', () async {
      var failTestPath = join('test', 'fail_test.dart');
      try {
        if (!Platform.isWindows) {
          await File(join('test', 'data', 'fail_test_.dart'))
              .copy(failTestPath);
          ProcessResult result = await runCmd(pkg.pbrCmd(['test', '--']..addAll(
              testRunnerArgs(
                  args: [failTestPath], reporter: RunTestReporter.json))));
          //if (!Platform.isWindows) {
          expect(result.exitCode, 1);
          //}
          expect(pubRunTestJsonIsSuccess(result.stdout as String), isFalse);
          expect(pubRunTestJsonSuccessCount(result.stdout as String), 0);
          expect(pubRunTestJsonFailureCount(result.stdout as String), 1);
        }
      } finally {
        try {
          await File(failTestPath).delete();
        } catch (_) {}
      }
    }, skip: true, timeout: Timeout(Duration(minutes: 2)));

    test('pbr_failure_test', () async {
      var failTestPath = join('test', 'fail_test.dart');
      try {
        if (!Platform.isWindows) {
          await File(join('test', 'data', 'fail_test_.dart'))
              .copy(failTestPath);
          ProcessResult result =
              await runCmd(pkg.pbrCmd(['test', '--']..addAll(testRunnerArgs(
                  args: [failTestPath],
                  //reporter: RunTestReporter.JSON
                ))));
          //if (!Platform.isWindows) {
          expect(result.exitCode, 1);
          //}
          // expect(pubRunTestJsonIsSuccess(result.stdout as String), isFalse);
          // expect(pubRunTestJsonSuccessCount(result.stdout as String), 0);
          // expect(pubRunTestJsonFailureCount(result.stdout as String), 1);

        }
      } finally {
        try {
          await File(failTestPath).delete();
        } catch (_) {}
      }
    }, timeout: Timeout(Duration(minutes: 2)));

    test('getPubspecYaml', () async {
      Map map = await getPubspecYaml(packageRoot);
      expect(map['name'], "tekartik_pub");
    });
    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });

    test('isFlutterPackageRoot', () async {
      expect(await isFlutterPackageRoot(packageRoot), isFalse);
      var dir = Directory(join(outSubPath, 'is_flutter_package_root'));
      await dir.create(recursive: true);
      await File(join(dir.path, 'pubspec.yaml')).writeAsString('''
dependencies:
  flutter:
    sdk: flutter
      ''');
      expect(await isFlutterPackageRoot(dir.path), isTrue);
    });
  });
}
