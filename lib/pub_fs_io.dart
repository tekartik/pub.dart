library tekartik_io_tools.pub_fs_io;

import 'package:process_run/cmd_run.dart';
import 'package:process_run/cmd_run.dart' as _cmd;
import 'pub_fs.dart';
//export 'pub.dart';
import 'pub_package.dart';
import 'package:fs_shim/fs.dart' as fs;
import 'package:fs_shim/fs_io.dart';
export 'package:fs_shim/fs_io.dart';
export 'pub_args.dart';
export 'pub_fs.dart';
import 'dart:async';

final FsPubPackageFactory ioFactory = new FsPubPackageFactory(
    (fs.Directory dir, [String name]) => new IoFsPubPackage(dir, name));

class IoFsPubPackage extends FsPubPackage
    implements PubPackageDir, PubPackageName {
  IoFsPubPackage(Directory dir, [String name])
      : super.created(ioFactory, dir, name);

  ProcessCmd pubCmd(Iterable<String> args,
      {bool version, bool help, bool verbose}) {
    return _cmd.pubCmd(args)..workingDirectory = dir.path;
  }

  /// main entry point
  Future<ProcessResult> runPub(Iterable<String> args,
          {bool connectIo: false}) =>
      runCmd(pubCmd(args), connectIo: connectIo);

  /// main entry point
  Future<ProcessResult> runCmd(ProcessCmd cmd, {bool connectIo: false}) {
    if (cmd.workingDirectory != dir.path || connectIo) {
      return _cmd.runCmd(cmd.clone()
        ..workingDirectory = dir.path
        ..connectStdin = connectIo
        ..connectStderr = connectIo
        ..connectStdout = connectIo);
    } else {
      return _cmd.runCmd(cmd);
    }
  }
}
