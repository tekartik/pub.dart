@TestOn('vm')
library tekartik_pub.test.pub_fs_io_test;

import 'package:tekartik_pub/src/pub_fs_io.dart';

import 'src_pub_fs_test.dart' as pub_fs_test;
import 'test_common_io.dart';

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('src_pub_fs_io', () {
    pub_fs_test.defineTests(FileSystemTestContextIo('src_pub_fs_io'));

    final pkg = IoFsPubPackage(Directory('.'));

    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });
  });
}
