library tekartik_pub.script;

import 'dart:mirrors';

///
/// Usage
///
String getScriptPath(Type type) =>
    (reflectClass(type).owner as LibraryMirror).uri.toFilePath();

abstract class Script {
  String get path => getScriptPath(this.runtimeType);
}
