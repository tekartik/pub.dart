@TestOn("vm")
library tekartik_pub.test.example_simple_test.dart;

import 'dart:io';

import 'package:dev_test/test.dart';
import 'package:fs_shim/utils/io/entity.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

import 'test_common.dart';

String get pkgDir => '.';

String get simplePkgDir => join(pkgDir, 'example_packages', 'simple');

String get outDir => join(testOutTopPath, joinAll(testDescriptions));

var longTimeout = Timeout(Duration(minutes: 2));
var veryLongTimeout = Timeout(Duration(minutes: 5));

void main() {
  group('io_example_simple', () {
    PubPackage pkg;

    // Order is important in the tests here

    setUpAll(() async {
      PubPackage simplePkg = PubPackage(simplePkgDir);
      // clone the package in a temp output location

      pkg = await simplePkg.clone(outDir, delete: true);
    });

    // fastest test
    test('get_offline', () async {
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
      // Called first to dependencies have changed
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
    }, timeout: veryLongTimeout);

    test('test', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubRunTestArgs()));
      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    }, timeout: longTimeout);

    test('build', () async {
      await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));

      File buildIndexHtmlFile =
          childFile(pkg.dir, join('build', 'web', 'index.html'));
      if (buildIndexHtmlFile.existsSync()) {
        await buildIndexHtmlFile.delete();
      }
      ProcessResult result = await runCmd(pkg.pubCmd([
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
      ProcessResult result =
          await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dev_test'));
    }, timeout: longTimeout);
  });
}
