@TestOn('vm')
library;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';
import 'package:test/test.dart';

import 'test_common.dart';

void main() {
  group('activate_package', () {
    test('PubspecYaml', () async {
      var pubspecYaml = PubspecYaml.fromMap(
        await PubPackage(packageRoot).getPubspecYamlMap(),
      );
      expect(pubspecYaml.name, 'tekartik_pub');
      expect(pubspecYaml.version, greaterThan(Version(0, 10, 0)));
    });
    test('pubspec.yaml', () async {
      final version = await extractPubspecYamlVersion(packageRoot);
      expect(version, greaterThan(Version(0, 1, 0)));
      expect(await extractPackageVersion(packageRoot), version);

      expect(await extractPubspecDependencies(packageRoot), ['process_run']);
    });

    test('pubspec.lock', () async {
      final processRunVersion = await extractPackagePubspecLockVersion(
        'process_run',
        packageRoot,
      );
      expect(processRunVersion, greaterThanOrEqualTo(Version(0, 1, 1)));

      expect(
        await extractPackagePubspecLockVersion('tekartik_pub', packageRoot),
        isNull,
      );
    });
  });
}
