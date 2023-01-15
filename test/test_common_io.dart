import 'package:fs_shim/src/io/io_file_system.dart';
import 'package:path/path.dart';
import 'package:tekartik_fs_test/test_common.dart';

export 'package:test/test.dart';

class FileSystemTestContextIo extends FileSystemTestContext {
  @override
  final PlatformContext platform = platformContextIo;
  @override
  final FileSystemIo fs = FileSystemIo();

  late final String basePath;

  @override
  String get outPath => joinAll([basePath, ...testDescriptions]);

  /// dir is a single dir
  FileSystemTestContextIo(String dir) {
    basePath = join('.dart_tool', 'tekartik_pub', 'test', dir);
  }
}
