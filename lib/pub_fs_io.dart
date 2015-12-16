library tekartik_io_tools.pub_io;

import 'package:process_run/cmd_run.dart';
import 'pub_fs.dart';
//export 'pub.dart';
import 'pub_package.dart';
import 'package:fs_shim/fs_io.dart';
export 'pub_args.dart';
export 'pub_fs.dart';

_pubCmd(Iterable<String> args) {
  return pubCmd(args);
}

class IoFsPubPackage extends FsPubPackage
    implements PubPackageDir, PubPackageName {
  IoFsPubPackage(Directory dir) : super(dir);

  ProcessCmd pubCmd(Iterable<String> args) {
    return _pubCmd(args)..workingDirectory = dir.path;
  }
}
