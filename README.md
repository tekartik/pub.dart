# tekartik_pub.dart

Pub and package helpers

[![Build Status](https://travis-ci.org/tekartik/tekartik_pub.dart.svg?branch=master)](https://travis-ci.org/tekartik/tekartik_pub.dart)

## Usage

````
import 'package:tekartik_pub/pub_fs_io.dart';

main() async {
  IoFsPubPackage pkg = new IoFsPubPackage(Directory.current);

  // Run all tests
  ProcessResult result = await pkg.runPub(pubRunTestArgs());
  print('exitCode: ${result.exitCode}');
}
````