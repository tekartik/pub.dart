#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/pub.dart \
  lib/pub_args.dart \
  lib/pub_fs.dart \
  lib/pub_fs_io.dart \
  lib/pub_package.dart \
  lib/pubspec.dart \
  lib/script.dart \

pub run test -p vm,firefox