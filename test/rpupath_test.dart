@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'dart:mirrors';
import 'package:path/path.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/pub.dart';
import 'package:tekartik_pub/src/rpubpath.dart';
import 'dart:async';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get packageRoot => dirname(dirname(testScriptPath));

void main() => defineTests();

Future<String> get _pubPackageRoot => getPubPackageRoot(testScriptPath);

void defineTests() {
  test('rpubpath', () async {
    String pubPackageRoot = await _pubPackageRoot;
    //clearOutFolderSync();
    List<String> paths = [];
    await recursivePubPath([pubPackageRoot]).listen((String path) {
      paths.add(path);
    }).asFuture();
    expect(paths, [pubPackageRoot]);

    // with criteria
    paths = [];
    await recursivePubPath([pubPackageRoot], dependencies: ['test'])
        .listen((String path) {
      paths.add(path);
    }).asFuture();
    expect(paths, [pubPackageRoot]);

    paths = [];
    await recursivePubPath([pubPackageRoot], dependencies: ['unittest'])
        .listen((String path) {
      paths.add(path);
    }).asFuture();
    expect(paths, []);

    bool failed = false;
    try {
      await recursivePubPath([join('/', 'dummy', 'path')]).last;
    } catch (e) {
      failed = true;
    }
    expect(failed, isTrue);
  });

  test('extract', () async {
    Map yaml = getPackageYamlSync(packageRoot);
    expect(await pubspecYamlGetDependenciesPackageName(yaml),
        unorderedEquals(['process_run', 'yaml']));
    expect(
        await pubspecYamlGetTestDependenciesPackageName(yaml), ['process_run']);
  });
}
