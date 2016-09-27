@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'package:process_run/process_run.dart';
import 'package:process_run/cmd_run.dart' hide pubCmd;
import 'package:process_run/cmd_run.dart' as _cmd_run;
import 'package:process_run/dartbin.dart';
import 'package:dev_test/test.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:tekartik_pub/pub_fs_io.dart';
import 'package:fs_shim_test/test_io.dart';
import 'pub_fs_test.dart' as pub_fs_test;

class TestScript extends Script {}

Directory get pkgDir => new File(getScriptPath(TestScript)).parent.parent;

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('pub_fs_io', () {
    pub_fs_test
        .defineTests(newIoFileSystemContext(join(pkgDir.path, 'test', 'out')));

    IoFsPubPackage pkg = new IoFsPubPackage(pkgDir);

    test('version', () async {
      IoFsPubPackage pkg = new IoFsPubPackage(pkgDir);
      ProcessResult result = await pkg.runPub(pubArgs(version: true));
      await run(dartExecutable, pubArguments(['--version']));
      expect(result.stdout.startsWith("Pub"), isTrue);
    });

    // use pk.runCmd and then pkg.pubCmd

    test('test', () async {
      ProcessResult result = await pkg.runCmd(_cmd_run.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          //reporter: pubRunTestReporterJson,
          reporter: pubRunTestReporterJson,
          concurrency: 1)));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout), isTrue);
      expect(pubRunTestJsonSuccessCount(result.stdout), 1);
      expect(pubRunTestJsonFailureCount(result.stdout), 0);

      // pubCmd
      result = await runCmd(pkg.pubCmd(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          reporter: pubRunTestReporterJson,
          concurrency: 1)));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout), isTrue);
      expect(pubRunTestJsonSuccessCount(result.stdout), 1);
      expect(pubRunTestJsonFailureCount(result.stdout), 0);

      result = await pkg.runPub(pubRunTestArgs(
          args: ['test/data/fail_test_.dart'],
          reporter: pubRunTestReporterJson));
      if (!Platform.isWindows) {
        expect(result.exitCode, 1);
      }
      expect(pubRunTestJsonIsSuccess(result.stdout), isFalse);
      expect(pubRunTestJsonSuccessCount(result.stdout), 0);
      expect(pubRunTestJsonFailureCount(result.stdout), 1);

      // runPub
      result = await pkg.runPub(pubRunTestArgs(
          args: ['test/data/success_test_.dart'],
          platforms: ["vm"],
          reporter: pubRunTestReporterExpanded,
          concurrency: 1));

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    });

    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });
  });
}
