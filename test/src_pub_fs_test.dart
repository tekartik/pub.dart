@TestOn('vm')
library tekartik_pub.test.pub_test;

import 'package:dev_test/test.dart';
import 'package:fs_shim/utils/copy.dart';
import 'package:fs_shim/utils/entity.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_fs_test/test_common.dart';
import 'package:tekartik_pub/src/pub_fs.dart';
import 'package:tekartik_pub/src/pubutils_fs.dart';

void main() => defineTests(memoryFileSystemTestContext);

void defineTests(FileSystemTestContext ctx) {
  //useVMConfiguration();

  group('src_pub_fs', () {
    FsPubPackage pkg;

    test('dir', () async {
      final top = await ctx.prepare();

      expect(await isPubPackageDir(top), isFalse);

      final sub = await createDirectory(childDirectory(top, 'sub'));
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
      final top = await ctx.prepare();
      final src = childDirectory(top, 'src');
      final dst = childDirectory(top, 'dst');
      pkg = FsPubPackage(src);

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

      final dstPubspecYamlFile = childFile(dst, pubspecYamlBasename);
      expect(await dstPubspecYamlFile.exists(), isFalse);
      await pkg.clone(dst);
      expect(await dstPubspecYamlFile.exists(), isTrue);

      final srcWebDir = childDirectory(src, 'web');
      final dstWebDir = childDirectory(dst, 'web');

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

      final list = await dst.list(recursive: true).toList();
      expect(list.length, 1);
      expect(list.first.path, dstPubspecYamlFile.path);
      expect(await dstPubspecYamlFile.exists(), isTrue);
    });

    test('extractPackage', () async {
      // extractPackage
      final top = await ctx.prepare();
      pkg = FsPubPackage(top);
      expect(await pkg.extractPackage(null), isNull);
      expect(await pkg.extractPackage('test'), isNull);
      await childFile(pkg.dir, dotPackagesBasename).writeAsString('''
test:file:///home/alex/.pub-cache/hosted/pub.dartlang.org/test-0.12.7/lib/
test2:lib/
''');
      expect(await pkg.extractPackage(null), isNull);
      final testPackage = await pkg.extractPackage('test');
      expect(testPackage.name, 'test');
      expect(top.fs.path.split(testPackage.dir.path),
          contains('pub.dartlang.org'));
      final test2Package = await pkg.extractPackage('test2');
      expect(test2Package.name, 'test2');
    });

    test('extractVersion', () async {
      final top = await ctx.prepare();
      pkg = FsPubPackage(top);
      //expect(await pkg.extractVersion(), isNull);
      await childFile(pkg.dir, pubspecYamlBasename).writeAsString('''
name: tekartik_pub_test_extract_version
version: 1.0.0
''');
      expect(await pkg.extractVersion(), Version(1, 0, 0));

      // pkg = new FsPubPackage(top);
      // expect(await pkg.extractVersion(), isNull);
      // await childFile(pkg.dir, pubspecYamlBasename).writeAsString('_version: 1.0.0');
      // expect(await pkg.extractVersion(), isNull);
    });

    test('pubRunTestJsonSuccessCount', () {
      final out = '''
{"protocolVersion":"0.1.0","runnerVersion":"0.12.7","type":"start","time":0}
{"test":{"id":0,"name":"loading test/case/one_solo_test_case_test.dart","groupIDs":[],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":0}
{"testID":0,"result":"success","hidden":true,"type":"testDone","time":159}
{"group":{"id":1,"parentID":null,"name":null,"metadata":{"skip":false,"skipReason":null}},"type":"group","time":162}
{"test":{"id":2,"name":"solo_test","groupIDs":[1],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":162}
{"testID":2,"result":"success","hidden":false,"type":"testDone","time":182}
{"test":{"id":3,"name":"dev_test report","groupIDs":[1],"metadata":{"skip":true,"skipReason":"[dev_test] 1 test skipped"}},"type":"testStart","time":183}
{"testID":3,"result":"success","hidden":false,"type":"testDone","time":185}
{"success":true,"type":"done","time":187}
''';
      expect(pubRunTestJsonSuccessCount(out), 2);
      expect(pubRunTestJsonIsSuccess(out), isTrue);
    });

    test('pubRunTestJsonFailureCount', () {
      final out = '''
{"protocolVersion":"0.1.0","runnerVersion":"0.12.6+2","type":"start","time":0}
{"test":{"id":0,"name":"loading test/data/fail_test_.dart","groupIDs":[],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":0}
{"testID":0,"result":"success","hidden":true,"type":"testDone","time":180}
{"group":{"id":1,"parentID":null,"name":null,"metadata":{"skip":false,"skipReason":null}},"type":"group","time":182}
{"test":{"id":2,"name":"failed","groupIDs":[1],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":183}
{"testID":2,"error":"will fail","stackTrace":"package:test                   fail\ntest/data/fail_test_.dart 7:5  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     _Completer.completeError\ntest/data/fail_test_.dart 8:4  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     Future.Future.microtask\ntest/data/fail_test_.dart      main.<fn>\n","isFailure":true,"type":"error","time":345}
{"testID":2,"result":"failure","hidden":false,"type":"testDone","time":346}
{"success":false,"type":"done","time":348}
''';
      expect(pubRunTestJsonFailureCount(out), 1);
      expect(pubRunTestJsonIsSuccess(out), isFalse);
    });
  });
}
