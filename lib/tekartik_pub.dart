import 'dart:async';

import 'src/pub_fs.dart';

/// Base representation of a pub package.
class PubPackage {
  /// Constructor for [PubPackage].
  PubPackage(this._fsPubPackage);

  // implementation
  final FsPubPackage _fsPubPackage;

  /// The underlying [FsPubPackage] implementation.
  FsPubPackage get fsPubPackage => _fsPubPackage;

  /// Get the name of the package.
  String? get name => _fsPubPackage.name;

  /// Set the name of the package.
  set name(String? name) => _fsPubPackage.name = name;

  /// Get the directory path of the package.
  String get path => _fsPubPackage.dir.path;

  /// Extract the package name from the pubspec.
  Future<String?> extractPackageName() => fsPubPackage.extractPackageName();
}
