#!/usr/bin/env bash
shopt -s nullglob
set -e

declare -a PODSPECS=(RollbarCommon RollbarCrashReport RollbarNotifier RollbarSwift RollbarDeploys RollbarAUL RollbarCocoaLumberjack)
declare -a OPTIONS=()

function help {
  echo "Usage: $ $0 [-v|--verbose] [--tag <TAG>]"
  echo "Options:"
  echo "      --tag <TAG>      Tag with version matching podspec."
  echo "  -v, --verbose        Show more debugging information."
  echo "      --help           Print help information."
}

while [ $# -gt 0 ]; do
  case $1 in
    -v|--verbose|--allow-warnings)
      OPTIONS+=($1)
      shift
      ;;
    --tag)
      TAG=$2
      shift 2
      ;;
    --help)
      help
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [ -z ${TAG:=$(git tag --points-at HEAD)} ]; then
  echo "WARN: Couldn't figure out git tag, only lint is available."

  for PODSPEC in ${PODSPECS[@]}; do
    pod spec lint $(IFS=$' '; echo ${OPTIONS[*]}) $PODSPEC.podspec
  done
else
  for PODSPEC in ${PODSPECS[@]}; do
    pod trunk push $(IFS=$' '; echo ${OPTIONS[*]}) $PODSPEC.podspec
  done
fi

exit 0
