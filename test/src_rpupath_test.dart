@TestOn("vm")
library tekartik_pub.test.src_rpubpath_test;

import 'package:path/path.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/src/rpubpath.dart';

import 'test_common.dart';

void main() => defineTests();

void defineTests() {
  test('rpubpath', () async {
    //clearOutFolderSync();
    List<String> paths = [];
    await recursivePubPath([packageRoot]).listen((String path) {
      paths.add(path);
    }).asFuture();
    expect(paths, [packageRoot]);

    // with criteria
    paths = [];
    await recursivePubPath([packageRoot], dependencies: ['test'])
        .listen((String path) {
      paths.add(path);
    }).asFuture();
    expect(paths, [packageRoot]);

    paths = [];
    await recursivePubPath([packageRoot], dependencies: ['unittest'])
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

  test('recursiveDartEntities', () async {
    var paths = await recursiveDartEntities('.');
    expect(paths, contains('test'));
    expect(paths, isNot(contains('.dart_tool')));
    expect(paths, contains(join('test', 'io_test.dart')));
    expect(paths, contains(join('test', 'data', 'fail_test_.dart')));
  });

  test('extract', () async {
    Map yaml = getPackageYamlSync(packageRoot);
    expect(
        await pubspecYamlGetDependenciesPackageName(yaml),
        unorderedEquals([
          'pub_semver',
          'process_run',
          'yaml',
          'fs_shim',
          'args',
          'tekartik_common_utils',
        ]));
    expect(
        await pubspecYamlGetTestDependenciesPackageName(yaml), ['process_run']);

    yaml = {};
    expect(await pubspecYamlGetTestDependenciesPackageName(yaml), isNull);
    yaml = {'test_dependencies': null};
    expect(await pubspecYamlGetTestDependenciesPackageName(yaml), []);
    yaml = {'test_dependencies': []};
    expect(await pubspecYamlGetTestDependenciesPackageName(yaml), []);
    yaml = {
      'test_dependencies': ['process_run']
    };
    expect(
        await pubspecYamlGetTestDependenciesPackageName(yaml), ['process_run']);

    yaml = {
      'dependencies': {'process_run': 'any'}
    };
    expect(await pubspecYamlGetDependenciesPackageName(yaml), ['process_run']);
  });
}
