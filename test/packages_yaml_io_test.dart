@TestOn('vm')
library tekartik_pub.test.packages_yaml_io_test;

import 'dart:io';

import 'package:dev_test/test.dart';
import 'package:tekartik_pub/packages_yaml_io.dart';

void main() {
  group('io', () {
    test('yamlMap', () async {
      expect(
          File(await pubGetPackageFilePath(
                  '.', 'tekartik_lints', 'recommended.yaml'))
              .existsSync(),
          isTrue);
      expect(
          File(await pubGetPackageFilePath(
                  '.', 'tekartik_lints', 'recommended.yaml_'))
              .existsSync(),
          isFalse);
      try {
        expect(
            File(await pubGetPackageFilePath(
                    '.', 'tekartik_lints_', 'recommended.yaml'))
                .existsSync(),
            isFalse);
        fail('should fail');
      } catch (e) {
        expect(e, isNot(const TypeMatcher<TestFailure>()));
      }
    });
  });
}
