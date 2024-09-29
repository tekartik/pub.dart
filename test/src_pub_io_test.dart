@TestOn('vm')
library;

import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_pub/src/pub_io.dart';
import 'package:test/test.dart';

import 'test_common.dart';

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('src_pub_io', () {
    Future testIsPubPackageRoot(String path, bool expected) async {
      expect(await isPubPackageRoot(path), expected, reason: path);
      expect(isPubPackageRootSync(path), expected, reason: path);
    }

    test('isPubPackageRoot', () async {
      await testIsPubPackageRoot(join(packageRoot, 'test'), false);
      await testIsPubPackageRoot('.', true);
      await testIsPubPackageRoot(absolute(packageRoot), true);
      await testIsPubPackageRoot(normalize(absolute(packageRoot)), true);
      await testIsPubPackageRoot(packageRoot, true);
      await testIsPubPackageRoot(
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
