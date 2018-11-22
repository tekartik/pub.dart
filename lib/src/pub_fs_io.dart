import 'dart:async';

import 'package:fs_shim/fs.dart' as fs;
import 'package:fs_shim/fs_io.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/cmd_run.dart' as _cmd;

import 'pub_fs.dart';
import 'pub_package_fs.dart';

export 'package:fs_shim/fs_io.dart';

export '../pub_args.dart';
export 'pub_fs.dart';
//export 'pub.dart';

final FsPubPackageFactory ioFactory = FsPubPackageFactory((fs.Directory dir,
        [String name]) =>
    IoFsPubPackage(dir as Directory, name));

// deprecated
class IoFsPubPackage extends FsPubPackage
    implements PubPackageDir, PubPackageName {
  IoFsPubPackage(Directory dir, [String name])
      : super.created(ioFactory, dir, name);

  ProcessCmd pubCmd(List<String> args) {
    return _cmd.PubCmd(args)..workingDirectory = dir.path;
  }

  /// main entry point
  @deprecated
  Future<ProcessResult> runPub(List<String> args, {bool verbose}) =>
      runCmd(pubCmd(args), verbose: verbose);

  /// main entry point
  Future<ProcessResult> runCmd(ProcessCmd cmd, {bool verbose}) {
    if (cmd.workingDirectory != dir.path) {
      cmd = cmd.clone()..workingDirectory = dir.path;
    }
    return _cmd.runCmd(cmd, verbose: verbose);
  }
}

/// result must be run with reporter:json
@deprecated
bool pubRunTestJsonProcessResultIsSuccess(ProcessResult result) =>
    pubRunTestJsonIsSuccess(result.stdout as String);

@deprecated
int pubRunTestJsonProcessResultSuccessCount(ProcessResult result) =>
    pubRunTestJsonSuccessCount(result.stdout as String);

@deprecated
int pubRunTestJsonProcessResultFailureCount(ProcessResult result) =>
    pubRunTestJsonFailureCount(result.stdout as String);
