// used?
@deprecated
library tekartik_pub.src.rpubpath_fs;

import 'dart:async';
import 'package:fs_shim/fs.dart';
import 'package:path/path.dart';
import 'pub_fs.dart';
import 'import.dart';

bool _isToBeIgnored(String baseName) {
  if (baseName == '.' || baseName == '..') {
    return false;
  }

  return baseName.startsWith('.');
}

Stream<Directory> recursivePubDir(List<Directory> dirs,
    {List<String> dependencies}) {
  StreamController<Directory> ctlr = new StreamController();

  Future _handleDir(Directory dir) async {
    FileSystem fs = dir.fs;
    // Ignore folder starting with .
    // don't event go below
    if (!_isToBeIgnored(basename(dir.path))) {
      if (await isPubPackageDir(dir)) {
        if (dependencies is List && !dependencies.isEmpty) {
          Map yaml = await getPubspecYaml(dir);
          if (pubspecYamlHasAnyDependencies(yaml, dependencies)) {
            ctlr.add(dir);
          }
        } else {
          // add package path
          ctlr.add(dir);
        }
      } else {
        List<Future> sub = [];
        await dir.list().listen((FileSystemEntity fse) {
          sub.add(new Future.sync(() async {
            if (await fs.isDirectory(fse.path)) {
              await _handleDir(fs.newDirectory(fse.path));
            }
          }));
        }).asFuture();
        await Future.wait(sub);
      }
    }
  }

  List<Future> futures = [];
  for (Directory dir in dirs) {
    futures.add(new Future.sync(() async {
      if (await dir.fs.isDirectory(dir.path)) {
        await _handleDir(dir);
      } else {
        throw '${dir} not a directory';
      }
    }));
  }

  Future.wait(futures).then((_) {
    ctlr.close();
  });

  return ctlr.stream;
}
