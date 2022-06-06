@TestOn('vm')
library tekartik_pub.test.pub_fs_io_test;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';
import 'package:test/test.dart';

import 'test_common.dart';
import 'test_common_io.dart';

void main() => defineTests();

String get packageRoot => '.';

void defineTests() {
  //useVMConfiguration();
  group('io', () {
    final pkg = PubPackage('.');

    test('equals', () {
      final pkg1 = PubPackage(packageRoot);
      expect(pkg1, pkg1);
      final pkg2 = PubPackage(packageRoot);
      expect(pkg1.hashCode, pkg2.hashCode);
      expect(pkg1, pkg2);
    });

    Future testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageRoot(path), expected);
      expect(isPubPackageRootSync(path), expected);
    }

    test('root', () async {
      await testIsPubPackageRoot('test', false);
      await testIsPubPackageRoot('..', false);
      await testIsPubPackageRoot('.', true);
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
        final result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: [testPath],
            platforms: ['vm'],
            //reporter: pubRunTestReporterJson,
            reporter: RunTestReporter.json,
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
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('pbr_success_test_to_fix', () async {
      var testPath = join('test', 'success_test.dart');
      try {
        await File(join('test', 'data', 'success_test_.dart')).copy(testPath);
        final result = await runCmd(pkg.pbrCmd([
          'test',
          '--',
          ...testRunnerArgs(
              args: [testPath],
              platforms: ['vm'],
              //reporter: pubRunTestReporterJson,
              reporter: RunTestReporter.json,
              concurrency: 1)
        ]));

        expect(result.exitCode, 0, reason: result.stdout?.toString());
        expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
        expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
        expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
      } finally {
        try {
          await File(testPath).delete();
        } catch (_) {}
      }
    }, skip: true, timeout: const Timeout(Duration(minutes: 2)));

    test('pbr_success_test', () async {
      var testPath = join('test', 'success_test.dart');
      try {
        await File(join('test', 'data', 'success_test_.dart')).copy(testPath);
        final result = await runCmd(pkg.pbrCmd([
          'test',
          '--',
          ...testRunnerArgs(
              args: [testPath],
              platforms: ['vm'],
              //reporter: pubRunTestReporterJson,
              //reporter: RunTestReporter.JSON,
              concurrency: 1)
        ]));

        expect(result.exitCode, 0, reason: result.stdout?.toString());
        //expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
        //expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
        //expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
      } finally {
        try {
          await File(testPath).delete();
        } catch (_) {}
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
    /*
    test('expanded_success_test', () async {
      final result =  await devRunCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ['vm'],
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
          final result = await runCmd(pkg.pubCmd(pubRunTestArgs(
              args: [failTestPath], reporter: RunTestReporter.json)));
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
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('pbr_failure_test_to_fix', () async {
      var failTestPath = join('test', 'fail_test.dart');
      try {
        if (!Platform.isWindows) {
          await File(join('test', 'data', 'fail_test_.dart'))
              .copy(failTestPath);
          final result = await runCmd(pkg.pbrCmd([
            'test',
            '--',
            ...testRunnerArgs(
                args: [failTestPath], reporter: RunTestReporter.json)
          ]));
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
    }, skip: true, timeout: const Timeout(Duration(minutes: 2)));

    test('pbr_failure_test', () async {
      var failTestPath = join('test', 'fail_test.dart');
      try {
        if (!Platform.isWindows) {
          await File(join('test', 'data', 'fail_test_.dart'))
              .copy(failTestPath);
          final result = await runCmd(pkg.pbrCmd([
            'test',
            '--',
            ...testRunnerArgs(args: [failTestPath])
          ]
              //reporter: RunTestReporter.JSON
              ));
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
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('getPubspecYaml', () async {
      final map = await getPubspecYaml(packageRoot);
      expect(map!['name'], 'tekartik_pub');
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
