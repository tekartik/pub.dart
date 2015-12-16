@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/pub.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get packageRoot => dirname(dirname(testScriptPath));

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('pub', () {
    group('pub_package', () {
      test('equals', () {
        PubPackage pkg1 = new PubPackage(packageRoot);
        expect(pkg1, pkg1);
        PubPackage pkg2 = new PubPackage(packageRoot);
        expect(pkg1.hashCode, pkg2.hashCode);
        expect(pkg1, pkg2);
      });

      test('pubBuildArgs', () {
        expect(pubBuildArgs(), ['build']);
        expect(pubBuildArgs(output: 'out'), ['build', '--output', 'out']);
        expect(pubBuildArgs(mode: 'debug'), ['build', '--mode', 'debug']);
        expect(pubBuildArgs(format: 'json'), ['build', '--format', 'json']);
        expect(pubBuildArgs(args: ['web']), ['build', 'web']);
      });

      test('pubRunTestArgs', () {
        expect(pubRunTestArgs(), ['run', "test"]);
      });

      test('pubGetArgs', () {
        expect(pubGetArgs(), ['get']);
      });

      test('pubUpgradeArgs', () {
        expect(pubUpgradeArgs(), ['upgrade']);
      });
    });
  });
}
