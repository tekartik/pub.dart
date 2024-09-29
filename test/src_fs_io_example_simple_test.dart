@TestOn('vm')
library;

import 'package:fs_shim/utils/entity.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/src/pub_fs_io.dart';

import 'test_common.dart';
import 'test_common_io.dart';

String get simplePkgDir => join(packageRoot, 'example_packages', 'simple');

var longTimeout = const Timeout(Duration(minutes: 2));

void main() {
  group('src_fs_io_example_simple', () {
    late IoFsPubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      var outDir =
          await FileSystemTestContextIo('src_fs_io_example_simple').prepare();
      final simplePkg = IoFsPubPackage(Directory(simplePkgDir));
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir, delete: true) as IoFsPubPackage;
    });

    // fastest test
    test('get_offline', () async {
      final result = await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      // Called first to dependencies have changed
      expect(result.stdout, contains('Changed '));
    }, timeout: longTimeout);

    test('get', () async {
      var result = await runCmd(pkg.pubCmd(pubGetArgs()));
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
      var result = await runCmd(pkg.pubCmd(pubUpgradeArgs()));
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
      final result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      expect(result.exitCode, 0);
    }, timeout: longTimeout);

    test('build', () async {
      final buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html'));
      if (await buildIndexHtmlFile.exists()) {
        await buildIndexHtmlFile.delete();
      }
      final result = await runCmd(pkg.pubCmd([
        'run',
        'build_runner',
        'build',
        '--output',
        'web:${join('build', 'web')}'
      ]));
      // final result =  await runCmd(pkg.pubCmd(pubBuildArgs()));

      expect(result.exitCode, 0);
      expect(await buildIndexHtmlFile.exists(), isTrue);
    }, timeout: longTimeout);

    test('deps', () async {
      final result =
          await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    });
  });
}
