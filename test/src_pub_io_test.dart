@TestOn('vm')
library tekartik_pub.test.pub_test;

import 'dart:async';

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/src/pub_io.dart';
import 'package:test/test.dart';

import 'test_common.dart';

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('src_pub_io', () {
    test('version', () async {
      final result =
          await runCmd(PubCmd(['--version'])..includeParentEnvironment = false);
      expect(result.stdout, startsWith('Pub'));
    });

    Future _testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageRoot(path), expected, reason: path);
      expect(isPubPackageRootSync(path), expected, reason: path);
    }

    test('isPubPackageRoot', () async {
      await _testIsPubPackageRoot(join(packageRoot, 'test'), false);
      await _testIsPubPackageRoot('.', true);
      await _testIsPubPackageRoot(absolute(packageRoot), true);
      await _testIsPubPackageRoot(normalize(absolute(packageRoot)), true);
      await _testIsPubPackageRoot(packageRoot, true);
      await _testIsPubPackageRoot(
          dirname(normalize(absolute(packageRoot))), false);
    });

    test('getPubPackageRoot', () async {
      expect(await getPubPackageRoot(join(packageRoot, 'test')), packageRoot);
      expect(await getPubPackageRoot(join(packageRoot, 'test', 'data')),
          packageRoot);
      expect(await getPubPackageRoot(packageRoot), packageRoot);
      try {
        await getPubPackageRoot(join('/', 'dummy', 'path'));
        fail('no');
      } catch (_) {}
    });

    group('pub_package', () {
      /*
      same test in expanded_success test hence failing
      test('runTest', () async {
        IoPubPackage pkg = new IoPubPackage(await _pubPackageRoot);
        final result =  await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: ['test/data/success_test_.dart'],
            platforms: ['vm'],
            reporter: RunTestReporter.JSON,
            concurrency: 1)));

        // on 1.13, current windows is failing
        if (!Platform.isWindows) {
          expect(result.exitCode, 0);
        }
        Map testResult = JSON
            .decode(LineSplitter.split(result.stdout as String).last) as Map;
        expect(testResult['success'], isTrue);

        result = await runCmd(pkg.pubCmd(pubRunTestArgs(
            args: ['test/data/fail_test_.dart'],
            reporter: RunTestReporter.JSON)));
        if (!Platform.isWindows) {
          expect(result.exitCode, 1);
        }
        testResult = JSON
            .decode(LineSplitter.split(result.stdout as String).last) as Map;
        expect(testResult['success'], isFalse);
      });
      */

      test('name', () async {
        final pkg = IoPubPackage(packageRoot);
        expect(pkg.name, 'tekartik_pub');
      });
    });
  });
}
