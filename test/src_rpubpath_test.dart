@TestOn('vm')
library tekartik_pub.test.src_rpubpath_test;

import 'package:path/path.dart';
import 'package:tekartik_pub/src/rpubpath.dart';
import 'package:test/test.dart';

import 'test_common.dart';

void main() => defineTests();

void defineTests() {
  test('rpubpath', () async {
    //clearOutFolderSync();
    var paths = <String>[];
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

    var failed = false;
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

  test('findTargetDartDirectories', () async {
    var paths = await findTargetDartDirectories('.');
    expect(paths, unorderedEquals(['example', 'lib', 'test', 'tool']));
  });

  test('extract', () async {
    var yaml = getPackageYamlSync(packageRoot)!;
    expect(
        pubspecYamlGetDependenciesPackageName(yaml),
        unorderedEquals([
          'dev_test',
          'path',
          'process_run',
          'yaml',
          'fs_shim',
          'pub_semver',
          'args',
          'tekartik_common_utils'
        ]));
    expect(pubspecYamlGetTestDependenciesPackageName(yaml), ['process_run']);

    yaml = {};
    expect(pubspecYamlGetTestDependenciesPackageName(yaml), isNull);
    yaml = {'test_dependencies': null};
    expect(pubspecYamlGetTestDependenciesPackageName(yaml), []);
    yaml = {'test_dependencies': []};
    expect(pubspecYamlGetTestDependenciesPackageName(yaml), []);
    yaml = {
      'test_dependencies': ['process_run']
    };
    expect(pubspecYamlGetTestDependenciesPackageName(yaml), ['process_run']);

    yaml = {
      'dependencies': {'process_run': 'any'}
    };
    expect(pubspecYamlGetDependenciesPackageName(yaml), ['process_run']);
  });
}
