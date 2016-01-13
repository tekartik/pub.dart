@TestOn("vm")
library tekartik_pub.test.pub_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim/fs.dart';
import 'package:fs_shim/utils/copy.dart';
import 'package:fs_shim/utils/entity.dart';
import 'package:fs_shim_test/context.dart';
import 'package:tekartik_pub/pub_fs.dart';
import 'package:pub_semver/pub_semver.dart';
//import 'package:tekartik_pub/src/pubutils_fs.dart';

void main() => defineTests(memoryFileSystemTestContext);

void defineTests(FileSystemTestContext ctx) {
  //useVMConfiguration();
  //factory = new FsPubPackageFactory();

  group('pub_fs', () {
    FsPubPackage pkg;

    test('dir', () async {
      Directory top = await ctx.prepare();

      expect(await isPubPackageDir(top), isFalse);

      Directory sub = await createDirectory(childDirectory(top, 'sub'));
      await createFile(childFile(top, pubspecYamlBasename));

      expect(await isPubPackageDir(top), isTrue);
      expect(await isPubPackageDir(sub), isFalse);

      expect(
          (await getPubPackageDir(childDirectory(top, 'sub'))).path, top.path);
      expect((await getPubPackageDir(top)).path, top.path);

      expect((await getPubPackageDir(childFile(top, pubspecYamlBasename))).path,
          top.path);
      expect((await getPubPackageDir(top)).path, top.path);
    });
    test('clone', () async {
      Directory top = await ctx.prepare();
      Directory src = childDirectory(top, 'src');
      Directory dst = childDirectory(top, 'dst');
      pkg = new FsPubPackage(src);

      try {
        await pkg.clone(dst);
        fail('should fail no pubspec.yaml');
      } on ArgumentError catch (_) {
        //print(_);
      }

      await src.create();
      try {
        await pkg.clone(dst);
        fail('should fail no pubspec.yaml');
      } on ArgumentError catch (_) {
        //print(_);
      }

      await childFile(src, pubspecYamlBasename).create();

      File dstPubspecYamlFile = childFile(dst, pubspecYamlBasename);
      expect(await dstPubspecYamlFile.exists(), isFalse);
      await pkg.clone(dst);
      expect(await dstPubspecYamlFile.exists(), isTrue);

      Directory srcWebDir = childDirectory(src, 'web');
      Directory dstWebDir = childDirectory(dst, 'web');

      await srcWebDir.create();
      expect(await dstWebDir.exists(), isFalse);
      await pkg.clone(dst);
      expect(await dstWebDir.exists(), isTrue);
      await srcWebDir.delete();
      await pkg.clone(dst);
      // not deleted
      expect(await dstWebDir.exists(), isTrue);
      await pkg.clone(dst, delete: true);
      // not deleted
      expect(await dstWebDir.exists(), isFalse);

      await childDirectory(src, 'build').create();
      await childDirectory(src, 'packages').create();
      await childFile(src, '.packages').create();
      await childFile(src, 'pubspec.lock').create();
      await childFile(src, '.pub').create();

      await pkg.clone(dst, delete: true);

      List<FileSystemEntity> list = await dst.list(recursive: true).toList();
      expect(list.length, 1);
      expect(list.first.path, dstPubspecYamlFile.path);
      expect(await dstPubspecYamlFile.exists(), isTrue);
    });

    test('extractPackage', () async {
      // extractPackage
      Directory top = await ctx.prepare();
      pkg = new FsPubPackage(top);
      expect(await pkg.extractPackage(null), isNull);
      expect(await pkg.extractPackage("test"), isNull);
      await childFile(pkg.dir, dotPackagesBasename).writeAsString('''
test:file:///home/alex/.pub-cache/hosted/pub.dartlang.org/test-0.12.7/lib/
''');
      expect(await pkg.extractPackage(null), isNull);
      FsPubPackage testPackages = await pkg.extractPackage("test");
      expect(testPackages.name, "test");
      expect(top.fs.pathContext.split(testPackages.dir.path),
          contains('pub.dartlang.org'));
    });

    test('extractVersion', () async {
      Directory top = await ctx.prepare();
      pkg = new FsPubPackage(top);
      //expect(await pkg.extractVersion(), isNull);
      await childFile(pkg.dir, pubspecYamlBasename).writeAsString('''
version: 1.0.0
''');
      expect(await pkg.extractVersion(), new Version(1, 0, 0));

      // pkg = new FsPubPackage(top);
      // expect(await pkg.extractVersion(), isNull);
      // await childFile(pkg.dir, pubspecYamlBasename).writeAsString('_version: 1.0.0');
      // expect(await pkg.extractVersion(), isNull);
    });
  });
}
