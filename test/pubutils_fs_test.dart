@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim/fs.dart';
import 'package:fs_shim/utils/copy.dart';
import 'package:fs_shim/utils/entity.dart';
import 'package:fs_shim_test/context.dart';
import 'package:tekartik_pub/pub_fs.dart';
//import 'package:tekartik_pub/src/pubutils_fs.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  test('pubspecYamlGetVersion', () {
    expect(pubspecYamlGetVersion({'version': '1.0.0'}), new Version(1, 0, 0));
  });
}
