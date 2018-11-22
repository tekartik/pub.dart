@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/src/pub_fs_io.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:fs_shim/utils/entity.dart';
import 'test_common.dart';

String get simplePkgDir => join(packageRoot, 'example_packages', 'simple');
Directory get outDir => Directory(join(outSubPath, joinAll(testDescriptions)));

var longTimeout = Timeout(Duration(minutes: 2));

main() {
  group('src_fs_io_example_simple', () {
    IoFsPubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      IoFsPubPackage simplePkg = IoFsPubPackage(Directory(simplePkgDir));
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir, delete: true) as IoFsPubPackage;
    });

    // fastest test
    test('get_offline', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      // Called first to depedencies have changed
      expect(result.stdout, contains('Changed '));
    }, timeout: longTimeout);

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
    }, timeout: longTimeout);

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
    }, timeout: longTimeout);

    test('test', () async {
      await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      expect(result.exitCode, 0);
    }, timeout: longTimeout);

    test('build', () async {
      File buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html')) as File;
      if (await buildIndexHtmlFile.exists()) {
        await buildIndexHtmlFile.delete();
      }
      ProcessResult result = await runCmd(pkg.pubCmd([
        'run',
        'build_runner',
        'build',
        '--output',
        'web:${join('build', 'web')}'
      ]));
      // ProcessResult result = await runCmd(pkg.pubCmd(pubBuildArgs()));

      expect(result.exitCode, 0);
      expect(await buildIndexHtmlFile.exists(), isTrue);
    }, timeout: longTimeout);

    test('deps', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    });
  });
}
