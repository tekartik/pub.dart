import 'package:pub_semver/pub_semver.dart';
import 'package:fs_shim/fs.dart';

abstract class PubPackageName {
  String get name;
}

abstract class PubPackageDir {
  Directory get dir;
}

abstract class PubPackageVersion {
  Version get version;
}
