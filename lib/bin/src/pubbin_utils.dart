import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:pub_semver/pub_semver.dart';

export 'package:process_run/cmd_run.dart' hide runCmd;

const String argHelpFlag = 'help';
const String argVerboseFlag = 'verbose';
const String argVersionFlag = 'version';
const String argFixFlag = 'fix';
const String argOneByOneFlag = 'one';
const String argOfflineFlag = 'offline';
const String argPackagesDirFlag = 'packages-dir';
const String argForceRecursiveFlag = 'force-recursive';
const String argDryRunFlag = 'dry-run';

final Version binVersion = Version(0, 1, 0);

class PubBinOptions {
  bool? dryRun;
  bool? oneByOne;
}

void addCommonOptions(ArgParser parser) {
  parser.addFlag(argOneByOneFlag,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argDryRunFlag, abbr: 'd', help: "Don't execture the command");
  parser.addFlag(argVersionFlag, help: 'Version', negatable: false);
  parser.addFlag(argVerboseFlag, abbr: 'v', help: 'Verbose', negatable: false);
}

bool parseCommonOptions(ArgResults argResults) {
  final version = argResults[argVersionFlag] as bool;
  if (version) {
    stdout.write('$binVersion');
    return true;
  }
  return false;
}

Future<ProcessResult?> runCmd(ProcessCmd cmd, {PubBinOptions? options}) async {
  void writeWorkingDirectory() {
    if (cmd.workingDirectory != '.' && cmd.workingDirectory != null) {
      stdout.writeln('[${cmd.workingDirectory}]');
    }
  }

  if (options?.dryRun == true) {
    writeWorkingDirectory();
    stdout.writeln('\$ $cmd');
    return null;
  }
  ProcessResult result;
  if (options?.oneByOne == true) {
    writeWorkingDirectory();
    result = await cmd_run.runCmd(cmd, verbose: true);
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  } else {
    result = await cmd_run.runCmd(cmd);
    writeWorkingDirectory();
    stdout.writeln('\$ $cmd');
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  }
  return result;
}

/// Limit to 10 concurrent tasks
Future limitConcurrentTasks(List<Future> futures) async {
  // limit to 10
  if (futures.length > 10) {
    await futures.removeAt(0);
  }
}
