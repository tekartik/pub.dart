@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_pub/io.dart';
import 'dart:io';
import 'package:fs_shim/utils/io/entity.dart';
import 'package:tekartik_pub/script.dart';
import 'package:process_run/cmd_run.dart';

class TestScript extends Script {}

Directory get pkgDir => new File(getScriptPath(TestScript)).parent.parent;
Directory get simplePkgDir => childDirectory(pkgDir, join('example', 'simple'));
Directory get outDir =>
    childDirectory(pkgDir, join('test', 'out', joinAll(testDescriptions)));

main() {
  group('io_example_simple', () {
    PubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      PubPackage simplePkg = new PubPackage(simplePkgDir.path);
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir.path, delete: true);
    });

    // fastest test
    test('get_offline', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      // Called first to depedencies have changed
      expect(result.stdout, contains('Changed '));
    });

    test('get', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubGetArgs()));
      expect(result.stdout, contains('Got dependencies'));

      // offline

      result = await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      expect(result.stdout, contains('Got dependencies'));

      // dry run
      result =
          await runCmd(pkg.pubCmd(pubGetArgs(offline: true, dryRun: true)));
      expect(result.stdout, contains('No dependencies'));
    });

    test('upgrade', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubUpgradeArgs()));
      expect(result.stdout, contains('Resolving dependencies'));

      // offline

      result = await runCmd(pkg.pubCmd(pubUpgradeArgs(offline: true)));
      expect(result.stdout, contains('Resolving dependencies'));

      // dry run
      result =
          await runCmd(pkg.pubCmd(pubUpgradeArgs(offline: true, dryRun: true)));
      expect(result.stdout, contains('No dependencies'));
    });

    test('test', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    });

    test('build', () async {
      File buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html'));
      if (await buildIndexHtmlFile.exists()) {
        await buildIndexHtmlFile.delete();
      }
      ProcessResult result = await runCmd(pkg.pubCmd(pubBuildArgs()));

      expect(result.exitCode, 0);
      expect(await buildIndexHtmlFile.exists(), isTrue);
    });

    test('deps', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    });
  });
}