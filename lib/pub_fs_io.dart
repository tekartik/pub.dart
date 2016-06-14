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
import 'dart:convert';

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
          {bool connectStdin: false,
          bool connectStdout: false,
          bool connectStderr: false}) =>
      runCmd(pubCmd(args),
          connectStdin: connectStdin,
          connectStderr: connectStderr,
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
      {bool connectStdin: false,
      bool connectStdout: false,
      bool connectStderr: false}) {
    if (cmd.workingDirectory != dir.path ||
        connectStdin ||
        connectStdout ||
        connectStderr) {
      return _cmd.runCmd(cmd.clone()
        ..workingDirectory = dir.path
        ..connectStdin = connectStdin
        ..connectStderr = connectStderr
        ..connectStdout = connectStdout);
    } else {
      return _cmd.runCmd(cmd);
    }
  }

  /// main entry point deprecated to prevent permanent use
  ///
  /// to use for debugging only
  @deprecated
  Future<ProcessResult> devRunCmd(ProcessCmd cmd,
          {bool connectStdin: false, bool connectStdout, bool connectStderr}) =>
      _devRunCmd(cmd.clone()..connectStdin = connectStdin);

  Future<ProcessResult> _devRunCmd(ProcessCmd cmd,
      {bool connectStdin: false, bool connectStdout, bool connectStderr}) {
    print(processCmdToDebugString(cmd));
    return _cmd.runCmd(cmd.clone()
      ..workingDirectory = dir.path
      ..connectStdin = connectStdin
      ..connectStderr = true
      ..connectStdout = true);
  }
}

/// result must be run with reporter:json
bool pubRunTestJsonProcessResultIsSuccess(ProcessResult result) {
  try {
    Map map = JSON.decode(LineSplitter.split(result.stdout).last);
    return map['success'];
  } catch (_) {
    return false;
  }
}

int pubRunTestJsonProcessResultSuccessCount(ProcessResult result) {
  //int _warn;
  //print('# ${processResultToDebugString(result)}');
  int count = 0;
  for (String line in LineSplitter.split(result.stdout)) {
    try {
      var map = JSON.decode(line);
      //print(map);
      if (map is Map) {
        // {testID: 0, result: success, hidden: true, type: testDone, time: 199}
        // {testID: 2, result: success, hidden: false, type: testDone, time: 251}
        //
        // {protocolVersion: 0.1.0, runnerVersion: 0.12.6+2, type: start, time: 0}
        // {test: {id: 0, name: loading test/data/success_test_.dart, groupIDs: [], metadata: {skip: false, skipReason: null}}, type: testStart, time: 0}
        // {testID: 0, result: success, hidden: true, type: testDone, time: 224}
        // {group: {id: 1, parentID: null, name: null, metadata: {skip: false, skipReason: null}}, type: group, time: 227}
        // {test: {id: 2, name: success, groupIDs: [1], metadata: {skip: false, skipReason: null}}, type: testStart, time: 227}
        // {testID: 2, result: success, hidden: false, type: testDone, time: 251}
        if (map['testID'] != null) {
          //print('1 $map');
          if ((map['result'] == 'success') && (map['hidden'] != true)) {
            //print('2 $map');
            count++;
          }
        }
      }
    } catch (_) {}
  }

  return count;
}

/*
{"protocolVersion":"0.1.0","runnerVersion":"0.12.6+2","type":"start","time":0}
{"test":{"id":0,"name":"loading test/data/fail_test_.dart","groupIDs":[],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":0}
{"testID":0,"result":"success","hidden":true,"type":"testDone","time":180}
{"group":{"id":1,"parentID":null,"name":null,"metadata":{"skip":false,"skipReason":null}},"type":"group","time":182}
{"test":{"id":2,"name":"failed","groupIDs":[1],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":183}
{"testID":2,"error":"will fail","stackTrace":"package:test                   fail\ntest/data/fail_test_.dart 7:5  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     _Completer.completeError\ntest/data/fail_test_.dart 8:4  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     Future.Future.microtask\ntest/data/fail_test_.dart      main.<fn>\n","isFailure":true,"type":"error","time":345}
{"testID":2,"result":"failure","hidden":false,"type":"testDone","time":346}
{"success":false,"type":"done","time":348}
 */
int pubRunTestJsonProcessResultFailureCount(ProcessResult result) {
  int count = 0;
  for (String line in LineSplitter.split(result.stdout)) {
    try {
      var map = JSON.decode(line);
      //print(map);
      if (map is Map) {
        // {"testID":2,"result":"failure","hidden":false,"type":"testDone","time":346}
        if (map['testID'] != null) {
          if ((map['result'] == 'failure') && (map['hidden'] != true)) {
            count++;
          }
        }
      }
    } catch (_) {}
  }

  return count;
}
