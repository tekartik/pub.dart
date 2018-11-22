import 'dart:io';

import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/cmd_run.dart' hide runCmd;
export 'package:process_run/cmd_run.dart' hide runCmd;

Future<ProcessResult> runCmd(ProcessCmd cmd, {bool oneByOne}) async {
  void _writeWorkingDirectory() {
    if (cmd.workingDirectory != '.' && cmd.workingDirectory != null) {
      stdout.writeln('[${cmd.workingDirectory}]');
    }
  }

  ProcessResult result;
  if (oneByOne == true) {
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
