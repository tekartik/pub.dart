import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:pub_semver/pub_semver.dart';

export 'package:process_run/cmd_run.dart' hide runCmd;

/// Argument flag for help.
const String argHelpFlag = 'help';

/// Argument flag for verbose logging.
const String argVerboseFlag = 'verbose';

/// Argument flag for version.
const String argVersionFlag = 'version';

/// Argument flag for fix.
const String argFixFlag = 'fix';

/// Argument flag for running one by one.
const String argOneByOneFlag = 'one';

/// Argument flag for offline mode.
const String argOfflineFlag = 'offline';

/// Argument flag for packages directory.
const String argPackagesDirFlag = 'packages-dir';

/// Argument flag for force recursive.
const String argForceRecursiveFlag = 'force-recursive';

/// Argument flag for ignore errors.
const String argIgnoreErrorsFlag = 'ignore-errors';

/// Argument flag for dry run.
const String argDryRunFlag = 'dry-run';

/// Version of the bin utilities.
final Version binVersion = Version(0, 1, 0);

/// Common binary options.
class PubBinOptions {
  /// Whether to run in dry run mode.
  bool? dryRun;

  /// Whether to run commands one by one.
  bool? oneByOne;
}

/// Add common options to the argument parser.
void addCommonOptions(ArgParser parser) {
  parser.addFlag(
    argOneByOneFlag,
    abbr: 'o',
    help: 'One at a time',
    defaultsTo: Platform.isWindows,
  );
  parser.addFlag(argDryRunFlag, abbr: 'd', help: "Don't execture the command");
  parser.addFlag(argVersionFlag, help: 'Version', negatable: false);
  parser.addFlag(argVerboseFlag, abbr: 'v', help: 'Verbose', negatable: false);
}

/// Parse common options from the argument results.
bool parseCommonOptions(ArgResults argResults) {
  final version = argResults[argVersionFlag] as bool;
  if (version) {
    stdout.write('$binVersion');
    return true;
  }
  return false;
}

/// Run a command with the given options.
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
