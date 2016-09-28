import 'pub_fs.dart';

class PubPackage {

  PubPackage(this._fsPubPackage);

  // implementation
  FsPubPackage _fsPubPackage;
  FsPubPackage get fsPubPackage => _fsPubPackage;

  String get name => _fsPubPackage.name;

  String get path => _fsPubPackage.dir.path;



}