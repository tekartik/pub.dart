import 'dart:async';

import 'package:fs_shim/fs.dart' as fs;
import 'package:fs_shim/fs_io.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/cmd_run.dart' as _cmd;

import 'pub_fs.dart';
import 'pub_package.dart';

export 'package:fs_shim/fs_io.dart';

export '../pub_args.dart';
export 'pub_fs.dart';
//export 'pub.dart';


final FsPubPackageFactory ioFactory = new FsPubPackageFactory(
    (fs.Directory dir, [String name]) => new IoFsPubPackage(dir, name));

class IoFsPubPackage extends FsPubPackage
    implements PubPackageDir, PubPackageName {
  IoFsPubPackage(Directory dir, [String name])
      : super.created(ioFactory, dir, name);

  ProcessCmd pubCmd(Iterable<String> args) {
    return _cmd.pubCmd(args)
      ..workingDirectory = dir.path;
  }

  /// main entry point deprecated to prevent permanent use
  ///
  /// to use for debugging only
  @deprecated
  ProcessCmd devPubCmd(Iterable<String> args,
      {bool version, bool help, bool verbose}) {
    return _cmd.pubCmd(args)
      ..workingDirectory = dir.path
      ..connectStderr = true
      ..connectStdout = true;
  }

  /// main entry point
  Future<ProcessResult> runPub(Iterable<String> args,
      {
      bool verbose,
      @deprecated bool connectStdin: false,
      @deprecated bool connectStdout: false,
      @deprecated bool connectStderr: false}) =>
      runCmd(pubCmd(args),
          verbose: verbose,
      // ignore: deprecated_member_use
          connectStdin: connectStdin,
      // ignore: deprecated_member_use
          connectStderr: connectStderr,
      // ignore: deprecated_member_use
          connectStdout: connectStdout);

  /// main entry point deprecated to prevent permanent use
  ///
  /// to use for debugging only
  @deprecated
  Future<ProcessResult> devRunPub(Iterable<String> args,
      {bool connectStdin: false, bool connectStdout, bool connectStderr}) =>
      _devRunCmd(pubCmd(args), connectStdin: connectStdin);

  /// main entry point
  Future<ProcessResult> runCmd(ProcessCmd cmd,
      {
      bool verbose,
      @deprecated bool connectStdin: false,
      @deprecated bool connectStdout: false,
      @deprecated bool connectStderr: false}) {
    if (cmd.workingDirectory != dir.path ||
        // ignore: deprecated_member_use
        connectStdin ||
        // ignore: deprecated_member_use
        connectStdout ||
        // ignore: deprecated_member_use
        connectStderr) {
      cmd = cmd.clone()
        ..workingDirectory = dir.path
      // ignore: deprecated_member_use
        ..connectStdin = connectStdin
      // ignore: deprecated_member_use
        ..connectStderr = connectStderr
      // ignore: deprecated_member_use
        ..connectStdout = connectStdout;
    }
    return _cmd.runCmd(cmd, verbose: verbose);
  }

  /// main entry point deprecated to prevent permanent use
  ///
  /// to use for debugging only
  @deprecated
  Future<ProcessResult> devRunCmd(ProcessCmd cmd,
      {@deprecated bool connectStdin,
      @deprecated bool connectStdout,
      @deprecated bool connectStderr}) =>
      _devRunCmd(cmd.clone()
        ..connectStdin = connectStdin);

  Future<ProcessResult> _devRunCmd(ProcessCmd cmd,
      {@deprecated bool connectStdin,
      @deprecated bool connectStdout,
      @deprecated bool connectStderr}) {
    print(processCmdToDebugString(cmd));
    return _cmd.runCmd(cmd.clone()
      ..workingDirectory = dir.path
      // ignore: deprecated_member_use
      ..connectStdin = connectStdin
      // ignore: deprecated_member_use
      ..connectStderr = true
      // ignore: deprecated_member_use
      ..connectStdout = true,
        verbose: true);
  }
}

/// result must be run with reporter:json
@deprecated
bool pubRunTestJsonProcessResultIsSuccess(ProcessResult result) =>
    pubRunTestJsonIsSuccess(result.stdout);

@deprecated
int pubRunTestJsonProcessResultSuccessCount(ProcessResult result) =>
    pubRunTestJsonSuccessCount(result.stdout);

@deprecated
int pubRunTestJsonProcessResultFailureCount(ProcessResult result) =>
    pubRunTestJsonFailureCount(result.stdout);
