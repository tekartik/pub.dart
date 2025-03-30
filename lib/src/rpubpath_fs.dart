// used?
@Deprecated('Use dev_test')
library;

import 'import.dart';

bool _isToBeIgnored(String baseName) {
  if (baseName == '.' || baseName == '..') {
    return false;
  }

  return baseName.startsWith('.');
}

Stream<Directory> recursivePubDir(
  List<Directory> dirs, {
  List<String>? dependencies,
}) {
  final ctlr = StreamController<Directory>();

  Future handleDir(Directory dir) async {
    final fs = dir.fs;
    // Ignore folder starting with .
    // don't event go below
    if (!_isToBeIgnored(basename(dir.path))) {
      if (await isPubPackageDir(dir)) {
        if (dependencies is List && dependencies!.isNotEmpty) {
          final yaml = (await getPubspecYaml(dir))!;
          if (pubspecYamlHasAnyDependencies(yaml, dependencies)) {
            ctlr.add(dir);
          }
        } else {
          // add package path
          ctlr.add(dir);
        }
      } else {
        final sub = <Future>[];
        await dir.list().listen((FileSystemEntity fse) {
          sub.add(
            Future.sync(() async {
              if (await fs.isDirectory(fse.path)) {
                await handleDir(fs.directory(fse.path));
              }
            }),
          );
        }).asFuture<void>();
        await Future.wait(sub);
      }
    }
  }

  final futures = <Future>[];
  for (final dir in dirs) {
    futures.add(
      Future.sync(() async {
        if (await dir.fs.isDirectory(dir.path)) {
          await handleDir(dir);
        } else {
          throw '$dir not a directory';
        }
      }),
    );
  }

  Future.wait(futures).then((_) {
    ctlr.close();
  });

  return ctlr.stream;
}
