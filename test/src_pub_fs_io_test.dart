@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:fs_shim_test/test_io.dart';
import 'package:process_run/cmd_run.dart' hide pubCmd;
import 'package:tekartik_pub/src/pub_fs_io.dart';

import 'src_pub_fs_test.dart' as pub_fs_test;

class TestScript extends Script {}

Directory get pkgDir =>
    new File(getScriptPath(TestScript)).parent.parent as Directory;

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('src_pub_fs_io', () {
    pub_fs_test
        .defineTests(newIoFileSystemContext(join(pkgDir.path, 'test', 'out')));

    IoFsPubPackage pkg = new IoFsPubPackage(pkgDir);

    test('version', () async {
      IoFsPubPackage pkg = new IoFsPubPackage(pkgDir);
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      expect(result.stdout.startsWith("Pub"), isTrue);
    });

    // use pk.runCmd and then pkg.pubCmd
    /*
    the same test is ran in expanded_success_test hence failing
    test('test', () async {
      ProcessResult result = await pkg.runCmd(_cmd_run.pubCmd(pubRunTestArgs(
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
    */

    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });
  });
}
