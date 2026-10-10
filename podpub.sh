#!/usr/bin/env bash
#
# podpub.sh: push the SDK's pods to CocoaPods trunk in dependency order.
#
# A pod can go out only after trunk's CDN serves the new version of every pod
# it needs. So the pods go out in rounds. Before each round but the first,
# the script waits until the CDN serves the pods that round needs.
# RELEASING.md explains the rounds.
#
# Run ./podpub.sh --help for the options. It runs under macOS /bin/bash 3.2
# and under bash 5.
#
# For testing only, not for a release:
#   PODPUB_CDN_URL       The CDN base URL. Default https://cdn.cocoapods.org.
#                        A file:// URL to a local directory works.
#   PODPUB_POLL_SECONDS  Seconds between CDN checks while waiting. Default 60.

set -euo pipefail

# The pods, in the rounds they go out in. The pods of a round are pushed one
# after another. Each pod is "<name>.podspec" next to this script.
#
# Rollbar.podspec is never pushed. On trunk, the name "Rollbar" belongs to the
# old rollbar-ios SDK (1.x). A 3.x version under that name would reach every
# app that asks for "Rollbar" with no version, on its next "pod update", and
# break its build.
ROUNDS=(
  "RollbarCommon RollbarCrash"
  "RollbarReport RollbarDeploys"
  "RollbarNotifier"
  "RollbarAUL RollbarCocoaLumberjack"
)
ROUND_COUNT=${#ROUNDS[@]}

CDN_URL=${PODPUB_CDN_URL:-https://cdn.cocoapods.org}
CDN_URL=${CDN_URL%/}
POLL_SECONDS=${PODPUB_POLL_SECONDS:-60}

TAG=""
LINT=0
YES=0
SYNCHRONOUS=0
FROM_ROUND=1
WAIT_MINUTES=60
# Options for both "pod spec lint" and "pod trunk push". Expand it as
# ${POD_OPTIONS[@]+"${POD_OPTIONS[@]}"}: with set -u, bash before 4.4 fails
# on a plain "${POD_OPTIONS[@]}" when the array is empty.
POD_OPTIONS=()

# The pods this run pushed, and the pods it skipped because the CDN already
# serves them at TAG. Space separated.
PUSHED=""
SKIPPED=""

usage() {
  cat <<EOF
Usage: $0 [options]

Pushes the SDK's pods to CocoaPods trunk in $ROUND_COUNT rounds:
  1) ${ROUNDS[0]}
  2) ${ROUNDS[1]}
  3) ${ROUNDS[2]}
  4) ${ROUNDS[3]}
Before each round but the first, it waits until the CDN serves TAG for the
pods that round needs. It skips a pod the CDN already serves at TAG, so a rerun
is safe. It never pushes Rollbar.podspec.

Options:
      --tag TAG           The release tag. It must equal s.version in every
                          podspec. Default: the tag that points at HEAD.
      --lint              Lint the pods with 'pod spec lint', in round order.
                          Push nothing. This is also what happens when there
                          is no tag.
      --synchronous       Pass --synchronous to 'pod trunk push'.
      --allow-warnings    Pass --allow-warnings to pod.
  -v, --verbose           Pass --verbose to pod.
      --from-round N      Start at round N (1 to $ROUND_COUNT), for a rerun. Before
                          round N, wait until the CDN serves the pods it needs.
      --wait-minutes N    The longest wait for the CDN after a round, in
                          minutes. Default 60.
  -y, --yes               Do not ask before pushing.
  -h, --help              Show this help.
EOF
}

die() {
  echo "podpub: $*" >&2
  exit 1
}

usage_error() {
  echo "podpub: $*" >&2
  echo "Run $0 --help for the options." >&2
  exit 2
}

is_whole_number() {
  case $1 in
    '' | *[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

# Prints the pods of round $1 (1 based), space separated.
round_pods() {
  echo "${ROUNDS[$1 - 1]}"
}

# Prints the pods of rounds $1 to the last, space separated.
pods_from_round() {
  local r=$1 pods=""
  while [ "$r" -le "$ROUND_COUNT" ]; do
    pods="$pods $(round_pods "$r")"
    r=$((r + 1))
  done
  echo "${pods# }"
}

# Prints the pods that pod $1 needs at the same version. This is the table in
# RELEASING.md, from the s.dependency lines of the podspecs.
pod_needs() {
  case $1 in
    RollbarReport) echo "RollbarCrash" ;;
    RollbarDeploys) echo "RollbarCommon" ;;
    RollbarNotifier) echo "RollbarCommon RollbarCrash RollbarReport" ;;
    RollbarAUL | RollbarCocoaLumberjack) echo "RollbarCommon RollbarNotifier" ;;
    *) echo "" ;;
  esac
}

# Prints the pods that the pods of round $1 need, once each, in round order.
# The wait before a round is for these pods only. Nothing needs
# RollbarDeploys, so if it cannot go out, --from-round 3 still pushes the rest.
round_needs() {
  local name needs="" result=""
  for name in $(round_pods "$1"); do
    needs="$needs $(pod_needs "$name")"
  done
  for name in $(pods_from_round 1); do
    case "$needs " in
      *" $name "*) result="${result:+$result }$name" ;;
    esac
  done
  echo "$result"
}

format_duration() {
  printf '%dm %02ds' $(($1 / 60)) $(($1 % 60))
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is not installed. $2"
}

# Prints the md5 of $1 in hex. macOS has md5, Linux has md5sum.
md5_hex() {
  if command -v md5 >/dev/null 2>&1; then
    printf %s "$1" | md5 -q
  else
    printf %s "$1" | md5sum | cut -c1-32
  fi
}

# Succeeds when the CDN serves version $2 of pod $1. This is the check in
# RELEASING.md: the CDN lists each pod's versions in a shard file named after
# the first three hex digits of the md5 of the pod's name. A failed curl
# counts as "not yet", and is logged.
cdn_serves() {
  local name=$1 version=$2 hash url versions status
  hash=$(md5_hex "$name")
  url="$CDN_URL/all_pods_versions_${hash:0:1}_${hash:1:1}_${hash:2:1}.txt"
  if versions=$(curl -fsS --max-time 20 "$url"); then
    :
  else
    status=$?
    echo "  The CDN check for $name failed (curl exit $status, $url). Counting it as not yet." >&2
    return 1
  fi
  # A line reads "Name/1.0.0/1.0.1/...".
  printf '%s\n' "$versions" | awk -F/ -v name="$name" -v version="$version" '
    { sub(/\r$/, "") }
    $1 == name { for (i = 2; i <= NF; i++) if ($i == version) found = 1 }
    END { exit (found ? 0 : 1) }'
}

# Prints s.version of pod $1, read from its podspec.
podspec_version() {
  sed -n 's/^[[:space:]]*s\.version[[:space:]]*=[[:space:]]*"\([^"]*\)".*$/\1/p' "$1.podspec"
}

print_summary() {
  echo
  echo "Summary for $TAG:"
  echo "  Pushed: ${PUSHED:-none}"
  echo "  Skipped, the CDN already serves them: ${SKIPPED:-none}"
}

# Lints the pods of rounds FROM_ROUND to the last. Goes on after a failure,
# so one run shows every pod. Exits 1 if any pod failed.
run_lint() {
  local r name passed="" failed=""
  echo "Linting rounds $FROM_ROUND to $ROUND_COUNT with 'pod spec lint'. Nothing is pushed."
  echo "'pod spec lint' downloads the source at the tag from GitHub, and checks the"
  echo "pod against the versions trunk has. So a pod passes only once its tag is on"
  echo "GitHub and trunk has the versions of the pods it needs."
  if [ "$SYNCHRONOUS" -eq 1 ]; then
    echo "--synchronous is for 'pod trunk push' only. The lint does not use it."
  fi
  r=$FROM_ROUND
  while [ "$r" -le "$ROUND_COUNT" ]; do
    echo
    echo "== Round $r: $(round_pods "$r")"
    for name in $(round_pods "$r"); do
      echo "==> pod spec lint $name.podspec"
      if pod spec lint ${POD_OPTIONS[@]+"${POD_OPTIONS[@]}"} "$name.podspec"; then
        passed="${passed:+$passed }$name"
      else
        failed="${failed:+$failed }$name"
      fi
    done
    r=$((r + 1))
  done
  echo
  echo "Lint summary:"
  echo "  Passed: ${passed:-none}"
  echo "  Failed: ${failed:-none}"
  [ -z "$failed" ] || exit 1
}

# Refuses to go on unless TAG equals s.version in every podspec. Checks all
# seven even with --from-round, since a release ships them all at one version.
check_versions() {
  local name version mismatches=""
  for name in $(pods_from_round 1); do
    [ -f "$name.podspec" ] || die "Refusing to push: $name.podspec is missing."
    version=$(podspec_version "$name")
    case $version in
      '' | *$'\n'*) die "Refusing to push: could not read one s.version from $name.podspec." ;;
    esac
    if [ "$version" != "$TAG" ]; then
      mismatches="$mismatches $name ($version)"
    fi
  done
  if [ -n "$mismatches" ]; then
    die "Refusing to push: the tag $TAG does not equal s.version in:$mismatches"
  fi
}

# Refuses to go on unless the tag is on origin, at the same commit as the tag
# here. 'pod trunk push' and every app download the source at the tag from
# GitHub.
check_tag_on_origin() {
  local status remote origin_commit local_commit
  if remote=$(git ls-remote --exit-code --tags origin "refs/tags/$TAG" "refs/tags/$TAG^{}"); then
    :
  else
    status=$?
    if [ "$status" -eq 2 ]; then
      die "Refusing to push: the tag $TAG is not on origin. Push it first: git push origin $TAG"
    fi
    die "Refusing to push: could not check origin for the tag $TAG (git ls-remote exit $status)."
  fi
  # For an annotated tag, the "TAG^{}" line has the commit it points at.
  origin_commit=$(printf '%s\n' "$remote" | awk -v ref="refs/tags/$TAG" '
    $2 == ref { plain = $1 }
    $2 == ref "^{}" { peeled = $1 }
    END { print (peeled != "" ? peeled : plain) }')
  local_commit=$(git rev-parse -q --verify "refs/tags/$TAG^{commit}" || true)
  if [ -z "$local_commit" ]; then
    die "Refusing to push: the tag $TAG is on origin but not in this clone. Fetch it: git fetch origin tag $TAG"
  fi
  if [ "$origin_commit" != "$local_commit" ]; then
    die "Refusing to push: the tag $TAG is at commit ${origin_commit:0:7} on origin and at ${local_commit:0:7} here. Make them the same first."
  fi
}

# Refuses to go on unless the podspecs here are the ones at the tag. The
# podspec goes to trunk from this checkout, and the source from the tag on
# GitHub, so they must match. This catches a podspec edit that is not
# committed, and a HEAD past the tag with other podspecs.
check_podspecs_at_tag() {
  local name changed files=()
  for name in $(pods_from_round 1); do
    files+=("$name.podspec")
  done
  if ! changed=$(git diff --name-only "refs/tags/$TAG^{commit}" -- "${files[@]}"); then
    die "Refusing to push: could not compare the podspecs with the tag $TAG."
  fi
  if [ -n "$changed" ]; then
    die "Refusing to push: these podspecs differ from the ones at the tag $TAG: $(printf '%s' "$changed" | tr '\n' ' '). Check out the tag."
  fi
}

print_plan() {
  local r option options="" tagged
  echo "Plan: push to CocoaPods trunk at $TAG"
  r=1
  while [ "$r" -le "$ROUND_COUNT" ]; do
    if [ "$r" -lt "$FROM_ROUND" ]; then
      echo "  Round $r: $(round_pods "$r") (skipped, --from-round $FROM_ROUND)"
    else
      if [ "$r" -gt 1 ]; then
        echo "  Wait for the CDN to serve $(round_needs "$r")."
      fi
      echo "  Round $r: $(round_pods "$r")"
    fi
    r=$((r + 1))
  done
  echo "  The longest wait is $WAIT_MINUTES minutes, with a CDN check every ${POLL_SECONDS}s."
  echo "  A pod the CDN already serves at $TAG is skipped."
  for option in ${POD_OPTIONS[@]+"${POD_OPTIONS[@]}"} ${PUSH_OPTIONS[@]+"${PUSH_OPTIONS[@]}"}; do
    options="${options:+$options }$option"
  done
  echo "  'pod trunk push' options: ${options:-none}"
  echo "  Rollbar.podspec is not pushed: on trunk, Rollbar is the old rollbar-ios 1.x."
  tagged=$(git rev-parse -q --verify "refs/tags/$TAG^{commit}" || true)
  if [ "$tagged" != "$(git rev-parse HEAD)" ]; then
    echo "  Note: HEAD is not at the tag $TAG, but its podspecs are the same as the tag's."
  fi
}

confirm() {
  local count answer=""
  count=$(pods_from_round "$FROM_ROUND" | wc -w | tr -d ' ')
  printf 'Push %s pods at %s to CocoaPods trunk? [y/N] ' "$count" "$TAG"
  read -r answer || answer=""
  case $answer in
    y | Y | yes | Yes | YES) ;;
    *)
      echo "Stopped. Nothing was pushed."
      exit 1
      ;;
  esac
}

# Waits until the CDN serves TAG for every pod that round $1 needs. Checks
# every POLL_SECONDS, for up to WAIT_MINUTES. On timeout, exits 1.
wait_for_cdn() {
  local r=$1 pods name missing start elapsed deadline
  pods=$(round_needs "$r")
  start=$SECONDS
  deadline=$((start + WAIT_MINUTES * 60))
  echo
  echo "Waiting for the CDN to serve what round $r needs ($pods) at $TAG."
  while :; do
    missing=""
    for name in $pods; do
      cdn_serves "$name" "$TAG" || missing="$missing $name"
    done
    elapsed=$((SECONDS - start))
    if [ -z "$missing" ]; then
      echo "The CDN serves what round $r needs. Waited $(format_duration "$elapsed")."
      return 0
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      print_summary
      echo >&2
      echo "podpub: after $(format_duration "$elapsed"), the CDN still does not serve $TAG for:$missing" >&2
      echo "podpub: rerun with --from-round $r. It waits for those pods first." >&2
      exit 1
    fi
    echo "  Not yet:$missing (waited $(format_duration "$elapsed"))"
    sleep "$POLL_SECONDS"
  done
}

push_round() {
  local r=$1 name status round_pushed=""
  echo
  echo "== Round $r: $(round_pods "$r")"
  for name in $(round_pods "$r"); do
    if cdn_serves "$name" "$TAG"; then
      echo "The CDN already serves $name $TAG. Skipping it."
      SKIPPED="${SKIPPED:+$SKIPPED }$name"
      continue
    fi
    echo "==> pod trunk push $name.podspec"
    # No "pod repo update" after a push: "pod trunk push" updates the trunk
    # source itself before it validates the pod (update_master_repo in
    # cocoapods-trunk's push.rb).
    if pod trunk push ${POD_OPTIONS[@]+"${POD_OPTIONS[@]}"} ${PUSH_OPTIONS[@]+"${PUSH_OPTIONS[@]}"} "$name.podspec"; then
      PUSHED="${PUSHED:+$PUSHED }$name"
      round_pushed="${round_pushed:+$round_pushed }$name"
    else
      status=$?
      print_summary
      echo >&2
      echo "podpub: 'pod trunk push' failed for $name (exit $status)." >&2
      # The skip check asks the CDN, which lists a pod about 20 minutes after
      # its push. A rerun before that pushes the pod again, and trunk refuses
      # it as a duplicate.
      if [ -n "$round_pushed" ]; then
        echo "podpub: this run pushed $round_pushed in round $r. Before the rerun, wait until the CDN serves $round_pushed (about 20 minutes after the push), or trunk refuses it as a duplicate." >&2
      fi
      echo "podpub: if pod said $name is a duplicate entry, trunk already has it. Wait until the CDN serves it, then rerun." >&2
      echo "podpub: fix the cause and rerun with --from-round $r. Pods the CDN serves by then are skipped." >&2
      exit 1
    fi
  done
}

run_push() {
  local r
  check_versions
  check_tag_on_origin
  check_podspecs_at_tag
  print_plan
  if [ "$YES" -eq 0 ]; then
    confirm
  fi
  r=$FROM_ROUND
  while [ "$r" -le "$ROUND_COUNT" ]; do
    if [ "$r" -gt 1 ]; then
      wait_for_cdn "$r"
    fi
    push_round "$r"
    r=$((r + 1))
  done
  print_summary
  if [ -n "$PUSHED" ]; then
    echo "The CDN serves the last pods about 20 minutes after their push."
  fi
}

while [ $# -gt 0 ]; do
  case $1 in
    --tag)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        usage_error "--tag needs a value."
      fi
      TAG=$2
      shift 2
      ;;
    --lint)
      LINT=1
      shift
      ;;
    --synchronous)
      SYNCHRONOUS=1
      shift
      ;;
    --allow-warnings)
      POD_OPTIONS+=(--allow-warnings)
      shift
      ;;
    -v | --verbose)
      POD_OPTIONS+=(--verbose)
      shift
      ;;
    --from-round)
      if [ $# -lt 2 ] || ! is_whole_number "$2" || [ "$2" -lt 1 ] || [ "$2" -gt "$ROUND_COUNT" ]; then
        usage_error "--from-round needs a round from 1 to $ROUND_COUNT."
      fi
      # 10#: with a leading zero, bash arithmetic would read it as octal.
      FROM_ROUND=$((10#$2))
      shift 2
      ;;
    --wait-minutes)
      if [ $# -lt 2 ] || ! is_whole_number "$2" || [ "$2" -lt 1 ]; then
        usage_error "--wait-minutes needs a whole number of minutes, 1 or more."
      fi
      WAIT_MINUTES=$((10#$2))
      shift 2
      ;;
    -y | --yes)
      YES=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage_error "Unknown option: $1"
      ;;
  esac
done

if ! is_whole_number "$POLL_SECONDS" || [ "$POLL_SECONDS" -lt 1 ]; then
  die "PODPUB_POLL_SECONDS must be a whole number of seconds, 1 or more."
fi

# Options for "pod trunk push" only. Expand it like POD_OPTIONS.
PUSH_OPTIONS=()
if [ "$SYNCHRONOUS" -eq 1 ]; then
  PUSH_OPTIONS+=(--synchronous)
fi

# The podspecs sit next to this script.
cd "$(dirname "${BASH_SOURCE[0]}")"

require_command pod "Install CocoaPods (https://cocoapods.org) and try again."

if [ "$LINT" -eq 1 ]; then
  run_lint
  exit 0
fi

require_command git "Install git and try again."

if [ -z "$TAG" ]; then
  TAG=$(git tag --points-at HEAD)
  case $TAG in
    *$'\n'*)
      die "More than one tag points at HEAD ($(printf '%s' "$TAG" | tr '\n' ' ')). Pick one with --tag."
      ;;
  esac
  if [ -z "$TAG" ]; then
    echo "No tag points at HEAD and there is no --tag, so nothing can be pushed."
    echo "Linting only."
    echo
    run_lint
    exit 0
  fi
fi

require_command curl "Install curl and try again."
if ! command -v md5 >/dev/null 2>&1 && ! command -v md5sum >/dev/null 2>&1; then
  die "Neither md5 nor md5sum is installed. The CDN check needs one."
fi

run_push
