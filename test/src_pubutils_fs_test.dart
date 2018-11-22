@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:convert';

import 'package:dev_test/test.dart';
import 'package:tekartik_pub/src/pub_fs.dart';
//import 'package:tekartik_pub/src/pubutils_fs.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_pub/src/pubutils_fs.dart';

void main() {
  test('pubspecYamlGetVersion', () {
    expect(pubspecYamlGetVersion({'version': '1.0.0'}), Version(1, 0, 0));
  });

  test('pubspecYamlGetTestDependenciesPackageName', () async {
    expect(pubspecYamlGetTestDependenciesPackageName({}), isNull);
    expect(
        pubspecYamlGetTestDependenciesPackageName({'test_dependencies': null}),
        []);
    expect(
        pubspecYamlGetTestDependenciesPackageName({
          'test_dependencies': ['one']
        }),
        ['one']);
    expect(
        pubspecYamlGetTestDependenciesPackageName(json.decode(json.encode({
          'test_dependencies': ['one']
        })) as Map),
        ['one']);
  });

  test('pubspecYamlGetDependenciesPackageName', () async {
    expect(pubspecYamlGetDependenciesPackageName({}), isNull);
    expect(
        pubspecYamlGetDependenciesPackageName({'dependencies': null}), isNull);
    expect(
        pubspecYamlGetDependenciesPackageName({
          'dependencies': {'one': null}
        }),
        ['one']);
    expect(
        pubspecYamlGetDependenciesPackageName(json.decode(json.encode({
          'dependencies': {'one': null}
        })) as Map),
        ['one']);
  });
}
