@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'dart:io';

import 'package:dev_test/test.dart';
import 'package:path/path.dart';

import 'package:process_run/cmd_run.dart' hide pubCmd;
import 'package:tekartik_pub/io.dart';
import 'test_common_io.dart';

void main() => defineTests();

String get packageRoot => '.';

void defineTests() {
  //useVMConfiguration();
  group('io', () {
    PubPackage pkg = new PubPackage('.');

    test('equals', () {
      PubPackage pkg1 = new PubPackage(packageRoot);
      expect(pkg1, pkg1);
      PubPackage pkg2 = new PubPackage(packageRoot);
      expect(pkg1.hashCode, pkg2.hashCode);
      expect(pkg1, pkg2);
    });

    test('version', () async {
      PubPackage pkg = new PubPackage(packageRoot);
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      //print(result);
      expect(result.stdout, startsWith("Pub"));
    });

    test('run', () async {
      PubPackage pkg = new PubPackage(packageRoot);
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      //print(result);
      expect(result.stdout, startsWith("Pub"));
    });

    _testIsPubPackageRoot(String path, bool expected) async {
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
      } catch (e) {}
    });
    // use pk.runCmd and then pkg.pubCmd

    test('success_test', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          //reporter: pubRunTestReporterJson,
          reporter: RunTestReporter.JSON,
          concurrency: 1)));

      expect(result.exitCode, 0);
      expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
      expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
      expect(pubRunTestJsonFailureCount(result.stdout as String), 0);
    });

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
      if (!Platform.isWindows) {
        ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: ['test/data/fail_test_.dart'],
            reporter: RunTestReporter.JSON)));
        //if (!Platform.isWindows) {
        expect(result.exitCode, 1);
        //}
        expect(pubRunTestJsonIsSuccess(result.stdout as String), isFalse);
        expect(pubRunTestJsonSuccessCount(result.stdout as String), 0);
        expect(pubRunTestJsonFailureCount(result.stdout as String), 1);
      }
    });

    test('getPubspecYaml', () async {
      Map map = await getPubspecYaml(packageRoot);
      expect(map['name'], "tekartik_pub");
    });
    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });
  });
}
