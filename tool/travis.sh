#!/bin/bash

# Fast fail the script on failures.
set -xe

dartanalyzer --fatal-warnings .

pub run test -p vm,firefox
pub run build_runner test -- -p vm,chrome