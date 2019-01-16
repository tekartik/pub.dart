import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:pub_semver/pub_semver.dart';

export 'package:process_run/cmd_run.dart' hide runCmd;

const String argHelpFlag = 'help';
const String argVersionFlag = 'version';
const String argFixFlag = 'fix';
const String argOneByOneFlag = 'one';
const String argOfflineFlag = "offline";
const String argPackagesDirFlag = "packages-dir";
const String argForceRecursiveFlag = "force-recursive";
const String argDryRunFlag = "dry-run";

final Version binVersion = Version(0, 1, 0);

class PubBinOptions {
  bool dryRun;
  bool oneByOne;
}

void addCommonOptions(ArgParser parser) {
  parser.addFlag(argOneByOneFlag,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argDryRunFlag, abbr: 'd', help: "Don't execture the command");
  parser.addFlag(argVersionFlag, help: 'Version', negatable: false);
}

bool parseCommonOptions(ArgResults argResults) {
  bool version = argResults[argVersionFlag] as bool;
  if (version) {
    stdout.write('$binVersion');
    return true;
  }
  return false;
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
