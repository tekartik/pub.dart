@TestOn("vm")
library tekartik_pub.test.pubspec_test;

import 'package:dev_test/test.dart';

import 'package:tekartik_pub/pubspec.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart';

import 'package:tekartik_pub/script.dart';

class TestScript extends Script {}

String get testScriptPath => getScriptPath(TestScript);
String get packageRoot => dirname(dirname(testScriptPath));

main() {
  group('activate_package', () {
    test('pubspec.yaml', () async {
      Version version = await extractPubspecYamlVersion(packageRoot);
      expect(version, greaterThan(new Version(0, 1, 0)));
      expect(await extractPackageVersion(packageRoot), version);
    });

    test('pubspec.lock', () async {
      Version processRunVersion =
          await extractPackagePubspecLockVersion('process_run', packageRoot);
      expect(processRunVersion, greaterThanOrEqualTo(new Version(0, 1, 1)));

      expect(
          await extractPackagePubspecLockVersion('tekartik_pub', packageRoot),
          isNull);
    });
  });
}
