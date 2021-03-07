import 'package:fs_shim/fs.dart';
import 'package:pub_semver/pub_semver.dart';

abstract class PubPackageName {
  String? get name;
}

abstract class PubPackageDir {
  Directory get dir;
}

abstract class PubPackageVersion {
  Version get version;
}
