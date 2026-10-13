@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/bin/pubfmt.dart';
import 'package:tekartik_pub/bin/pubget.dart';
import 'package:tekartik_pub/bin/pubupgrade.dart';
import 'package:tekartik_pub/bin/src/pub_workspace_cache.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:test/test.dart';

ProcessCmd binCmd(String bin, List<String> arguments) {
  return DartCmd([join('example', 'bin', '$bin.dart'), ...arguments]);
}

Future<String?> runOutput(ProcessCmd cmd) async {
  return (await runCmd(cmd))!.stdout?.toString();
}

const _unformatted = 'void main() {print( "a" ) ;}\n';

/// Create a package (name and lib/[name].dart unformatted) in [dir].
Future<String> _createPackage(String dir, String name) async {
  await Directory(join(dir, 'lib')).create(recursive: true);
  await File(join(dir, 'pubspec.yaml')).writeAsString('''
name: $name
environment:
  sdk: ^3.0.0
''');
  await File(join(dir, 'lib', '$name.dart')).writeAsString(_unformatted);
  return dir;
}

void main() {
  group('bin', () {
    late Directory top;
    late String package1;
    late String package2;
    setUp(() async {
      // Never format the checkout itself
      top = await Directory.systemTemp.createTemp('tekartik_pub_bin_test_');
      package1 = await _createPackage(join(top.path, 'package1'), 'package1');
      package2 = await _createPackage(
        join(package1, 'sub', 'package2'),
        'package2',
      );
    });
    tearDown(() async {
      await top.delete(recursive: true);
    });
    String readLib(String dir) =>
        File(join(dir, 'lib', '${basename(dir)}.dart')).readAsStringSync();

    test('pubfmt', () async {
      expect(
        await pubFmt([top.path], PubFmtOptions()..forceRecursive = true),
        2,
      );
      expect(readLib(package1), isNot(_unformatted));
      expect(readLib(package2), isNot(_unformatted));
    });
    test('pubfmt dry run', () async {
      expect(
        await pubFmt(
          [top.path],
          PubFmtOptions()
            ..forceRecursive = true
            ..dryRun = true,
        ),
        2,
      );
      expect(readLib(package1), _unformatted);
      expect(readLib(package2), _unformatted);
    });
    test('pubfmt no force recursive', () async {
      expect(
        await pubFmt([package1], PubFmtOptions()..forceRecursive = false),
        1,
      );
      expect(readLib(package1), isNot(_unformatted));
      expect(readLib(package2), _unformatted);
    });
    test('pubget/pubupgrade dry run', () async {
      var options = PubGetOptions()
        ..dryRun = true
        ..offline = true;
      await pubGet([top.path], options);
      await pubUpgrade([top.path], options);
      for (var dir in [package1, package2]) {
        expect(File(join(dir, 'pubspec.lock')).existsSync(), isFalse);
        expect(Directory(join(dir, '.dart_tool')).existsSync(), isFalse);
      }
    });
    test('pubupgrade after pubget in a workspace', () async {
      var workspace = join(top.path, 'workspace');
      await Directory(workspace).create();
      await File(join(workspace, 'pubspec.yaml')).writeAsString('''
name: workspace
environment:
  sdk: ^3.6.0
workspace:
  - member
''');
      var member = await _createPackage(join(workspace, 'member'), 'member');
      await File(
        join(member, 'pubspec.yaml'),
      ).writeAsString('resolution: workspace\n', mode: FileMode.append);
      initPubWorkspacesCache();
      try {
        var options = PubGetOptions()..dryRun = true;
        await pubGet([workspace], options);
        expect(
          pubWorkspacesCache!.getWorkspaceCache(workspace)!.action,
          PubWorkspaceCacheAction.get,
        );
        // The upgrade must not be skipped as already done
        await pubUpgrade([workspace], options);
        expect(
          pubWorkspacesCache!.getWorkspaceCache(workspace)!.action,
          PubWorkspaceCacheAction.upgrade,
        );
      } finally {
        pubWorkspacesCache = null;
      }
    });

    test('version', () async {
      //expect(parseVersion(await runOutput(binCmd('publist', ['--version']))),
      //  binVersion);
    });
  });
}
