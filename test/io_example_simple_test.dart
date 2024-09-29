@TestOn('vm')
library;

import 'dart:io';

import 'package:fs_shim/utils/io/entity.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

import 'test_common_io.dart';

String get pkgDir => '.';

String get simplePkgDir => join(pkgDir, 'example_packages', 'simple');

var longTimeout = const Timeout(Duration(minutes: 2));
var veryLongTimeout = const Timeout(Duration(minutes: 5));

void main() {
  group('io_example_simple', () {
    late PubPackage pkg;

    setUpAll(() async {
      var outDir = await FileSystemTestContextIo('io_example_simple').prepare();
      final simplePkg = PubPackage(simplePkgDir);
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir.path, delete: true);
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
    }, timeout: veryLongTimeout);

    test('test', () async {
      final result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    }, timeout: longTimeout);

    test('build', () async {
      await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));

      final buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html'));
      if (buildIndexHtmlFile.existsSync()) {
        await buildIndexHtmlFile.delete();
      }
      final result = await runCmd(pkg.pubCmd([
        'run',
        'build_runner',
        'build',
        '--output',
        'web:${join('build', 'web')}'
      ]));

      expect(result.exitCode, 0);
      expect(buildIndexHtmlFile.existsSync(), isTrue);
    }, timeout: longTimeout);

    test('deps', () async {
      final result =
          await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    }, timeout: longTimeout);
  });
}
