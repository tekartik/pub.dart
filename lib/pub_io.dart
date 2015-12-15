library tekartik_io_tools.pub_utils;

import 'package:process_run/cmd_run.dart';
import 'pub.dart';
export 'pub.dart';
import 'pubspec.dart';

_pubCmd(Iterable<String> args) {
  return pubCmd(args);
}

class IoPubPackage extends PubPackage {
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
