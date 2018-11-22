import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/cmd_run.dart' hide runCmd;
export 'package:process_run/cmd_run.dart' hide runCmd;

const String argHelpFlag = 'help';
const String argFixFlag = 'fix';
const String argOneByOneFlag = 'one';
const String argOfflineFlag = "offline";
const String argPackagesDirFlag = "packages-dir";
const String argForceRecursiveFlag = "force-recursive";
const String argDryRunFlag = "dry-run";

class PubBinOptions {
  bool dryRun;
  bool oneByOne;
}

void addCommonOptions(ArgParser parser) {
  parser.addFlag(argOneByOneFlag,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argDryRunFlag, abbr: 'd', help: "Don't execture the command");
}

Future<ProcessResult> runCmd(ProcessCmd cmd, {PubBinOptions options}) async {
  void _writeWorkingDirectory() {
    if (cmd.workingDirectory != '.' && cmd.workingDirectory != null) {
      stdout.writeln('[${cmd.workingDirectory}]');
    }
  }

  if (options?.dryRun == true) {
    _writeWorkingDirectory();
    stdout.writeln('\$ $cmd');
    return null;
  }
  ProcessResult result;
  if (options?.oneByOne == true) {
    _writeWorkingDirectory();
    result = await cmd_run.runCmd(cmd, verbose: true);
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  } else {
    result = await cmd_run.runCmd(cmd);
    _writeWorkingDirectory();
    stdout.writeln('\$ $cmd');
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  }
  return result;
}
