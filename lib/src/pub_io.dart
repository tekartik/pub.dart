library tekartik_io_tools.pub_io;

import 'package:process_run/cmd_run.dart';
import '../pub.dart';
export '../pub.dart';
import '../pub_package.dart';
import '../pubspec.dart';
import 'package:fs_shim/fs_io.dart';
export '../pub_args.dart';

_pubCmd(Iterable<String> args) {
  return pubCmd(args);
}

class IoPubPackage extends PubPackage implements PubPackageDir, PubPackageName {
  Directory get dir => new Directory(path);
  IoPubPackage(String path) : super(path);

  ProcessCmd pubCmd(Iterable<String> args) {
    return _pubCmd(args)..workingDirectory = path;
  }

  String _name;
  String get name {
    if (_name == null) {
      _name = extractPubspecYamlNameSync(path);
    }
    return _name;
  }
}
