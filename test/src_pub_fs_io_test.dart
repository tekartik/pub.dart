@TestOn("vm")
library tekartik_pub.test.pub_fs_io_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim/fs_io.dart';
import 'package:process_run/cmd_run.dart' hide pubCmd;
import 'package:tekartik_pub/src/pub_fs_io.dart';

import 'src_pub_fs_test.dart' as pub_fs_test;
import 'test_common_io.dart';

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('src_pub_fs_io', () {
    pub_fs_test.defineTests(fileSystemTestContextIo);

    IoFsPubPackage pkg = IoFsPubPackage(Directory('.'));

    test('version', () async {
      ProcessResult result = await runCmd(pkg.pubCmd(pubArgs(version: true)));
      expect(result.stdout.startsWith("Pub"), isTrue);
    });

    test('name', () async {
      expect(await pkg.extractPackageName(), 'tekartik_pub');
    });
  });
}
