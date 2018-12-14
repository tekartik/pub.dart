# tekartik_pub.dart

Pub and package helpers

[![Build Status](https://travis-ci.org/tekartik/tekartik_pub.dart.svg?branch=master)](https://travis-ci.org/tekartik/tekartik_pub.dart)

# API

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

# Commands

## pubget

Recursively call `pub get`

   pubget
    
## pubupgrade

Recursively call `pub upgrade`

   pubupgrade
   
## Activation

### From git repository

    pub global activate -s git git://github.com/tekartik/pub.dart

### From local path

    pub global activate -s path .

## command line version test

    dart bin/publist.dart --version
    dart bin/pubget.dart --version
    dart bin/pubupgrade.dart --version
    dart bin/pubfmt.dart --version
    dart bin/pubanalyze.dart --version
    
    dart bin/publist.dart
    dart bin/pubget.dart
    dart bin/pubupgrade.dart --offline
        