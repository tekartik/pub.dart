import 'package:fs_shim/fs.dart';
import 'package:pub_semver/pub_semver.dart';

/// Interface for packages that have a name.
abstract class PubPackageName {
  /// The name of the package.
  String? get name;
}

/// Interface for packages that have a directory path.
abstract class PubPackageDir {
  /// The directory of the package.
  Directory get dir;
}

/// Interface for packages that have a version.
abstract class PubPackageVersion {
  /// The version of the package.
  Version get version;
}
