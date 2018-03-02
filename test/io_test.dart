@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim_test/test_io.dart';
import 'package:process_run/cmd_run.dart' hide pubCmd;
import 'package:tekartik_pub/io.dart';

class TestScript extends Script {}

String get testScriptPath => getScriptPath(TestScript);

Directory get pkgDir => new File(testScriptPath).parent.parent as Directory;

void main() => defineTests();

Future<String> get _pubPackageRoot => getPubPackageRoot(testScriptPath);

String get packageRoot => dirname(dirname(testScriptPath));

void defineTests() {
  //useVMConfiguration();
  group('io', () {
    PubPackage pkg = new PubPackage(pkgDir.path);

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
    // use pk.runCmd and then pkg.pubCmd

    test('test', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          //reporter: pubRunTestReporterJson,
          reporter: RunTestReporter.JSON,
          concurrency: 1)));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
      expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
      expect(pubRunTestJsonFailureCount(result.stdout as String), 0);

      // pubCmd
      result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          reporter: RunTestReporter.JSON,
          concurrency: 1)));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout as String), isTrue);
      expect(pubRunTestJsonSuccessCount(result.stdout as String), 1);
      expect(pubRunTestJsonFailureCount(result.stdout as String), 0);

      result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/fail_test_.dart'],
          reporter: RunTestReporter.JSON)));
      if (!Platform.isWindows) {
        expect(result.exitCode, 1);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout as String), isFalse);
      expect(pubRunTestJsonSuccessCount(result.stdout as String), 0);
      expect(pubRunTestJsonFailureCount(result.stdout as String), 1);

      // runPub
      result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          reporter: RunTestReporter.EXPANDED,
          concurrency: 1)));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
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
