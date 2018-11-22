@TestOn("vm")
library tekartik_pub.test.pubspec_test;

import 'package:dev_test/test.dart';

import 'package:tekartik_pub/pubspec.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart';

import 'package:tekartik_pub/io.dart';

import 'test_common.dart';

main() {
  group('activate_package', () {
    test('pubspec.yaml', () async {
      Version version = await extractPubspecYamlVersion(packageRoot);
      expect(version, greaterThan(Version(0, 1, 0)));
      expect(await extractPackageVersion(packageRoot), version);

      expect(await extractPubspecDependencies(packageRoot), ['process_run']);
    });

    test('pubspec.lock', () async {
      Version processRunVersion =
          await extractPackagePubspecLockVersion('process_run', packageRoot);
      expect(processRunVersion, greaterThanOrEqualTo(Version(0, 1, 1)));

      expect(
          await extractPackagePubspecLockVersion('tekartik_pub', packageRoot),
          isNull);
    });

    test('.packages', () async {
      PubPackage selfPkg = PubPackage(packageRoot);

      PubPackage pkg = await extractPackage(selfPkg.name, selfPkg.path);
      expect(pkg, selfPkg);
      pkg = await extractPackage('process_run', selfPkg.path);
      //expect(pkg, selfPkg);
      expect(isAbsolute(pkg.path), isTrue);
      expect(pkg.path, isNot(selfPkg.path));
    });
  });
}
