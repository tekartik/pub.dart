import 'package:fs_shim/src/io/io_file_system.dart';
import 'package:tekartik_fs_test/test_common.dart';
import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_pub/src/import.dart';

export 'package:test/test.dart';

final FileSystemTestContextIo fileSystemTestContextIo =
    FileSystemTestContextIo();

class FileSystemTestContextIo extends FileSystemTestContext {
  @override
  final PlatformContext platform = platformContextIo;
  @override
  final FileSystemIo fs = FileSystemIo();

  FileSystemTestContextIo() {
    basePath = join('.dart_tool', 'tekartik_pub', 'test');
  }
}
