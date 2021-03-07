import 'dart:async';

import 'src/pub_fs.dart';

class PubPackage {
  PubPackage(this._fsPubPackage);

  // implementation
  final FsPubPackage _fsPubPackage;

  FsPubPackage get fsPubPackage => _fsPubPackage;

  String? get name => _fsPubPackage.name;

  set name(String? name) => _fsPubPackage.name = name;

  String get path => _fsPubPackage.dir.path;

  Future<String?> extractPackageName() => fsPubPackage.extractPackageName();
}
