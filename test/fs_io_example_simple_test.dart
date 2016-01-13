@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_pub/pub_fs_io.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:fs_shim/utils/entity.dart';
import 'package:tekartik_pub/script.dart';
import 'package:tekartik_pub/pub_io.dart';
import 'test_common.dart';

class TestScript extends Script {}

Directory get pkgDir => new File(getScriptPath(TestScript)).parent.parent;
Directory get simplePkgDir => childDirectory(pkgDir, join('example', 'simple'));
Directory get outDir =>
    childDirectory(pkgDir, join(testOutTopPath, joinAll(testDescriptions)));

main() {
  group('fs_io_example_simple', () {
    IoFsPubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      IoFsPubPackage simplePkg = new IoFsPubPackage(simplePkgDir);
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir, delete: true);

      ProcessResult result = await pkg.runPub(pubGetArgs(offline: true));
      expect(result.stdout, contains('Changed '));
    });

    // fastest test
    test('get_offline', () async {
      ProcessResult result = await pkg.runPub(pubGetArgs(offline: true));
      // Called first to depedencies have changed
      expect(result.stdout, contains('Got dependencies'));
    });

    test('get', () async {
      ProcessResult result = await pkg.runPub(pubGetArgs());
      expect(result.stdout, contains('Got dependencies'));

      // offline

      result = await pkg.runPub(pubGetArgs(offline: true));
      expect(result.stdout, contains('Got dependencies'));

      // dry run
      result = await pkg.runPub(pubGetArgs(offline: true, dryRun: true));
      expect(result.stdout, contains('No dependencies'));
    });

    test('upgrade', () async {
      ProcessResult result = await pkg.runPub(pubUpgradeArgs());
      expect(result.stdout, contains('Resolving dependencies'));

      // offline

      result = await pkg.runPub(pubUpgradeArgs(offline: true));
      expect(result.stdout, contains('Resolving dependencies'));

      // dry run
      result = await pkg.runPub(pubUpgradeArgs(offline: true, dryRun: true));
      expect(result.stdout, contains('No dependencies'));
    });

    test('test', () async {
      ProcessResult result =
          await pkg.runPub(pubRunTestArgs(reporter: pubRunTestReporterJson));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
      expect(pubRunTestJsonProcessResultIsSuccess(result), isTrue);
      expect(pubRunTestJsonProcessResultSuccessCount(result), 1);
    });

    test('build', () async {
      File buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html'));
      if (await buildIndexHtmlFile.exists()) {
        await buildIndexHtmlFile.delete();
      }
      ProcessResult result = await pkg.runPub(pubBuildArgs());

      expect(result.exitCode, 0);
      expect(await buildIndexHtmlFile.exists(), isTrue);
    });

    test('deps', () async {
      ProcessResult result =
          await pkg.runPub(pubDepsArgs(style: pubDepsStyleCompact));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    });
  });
}