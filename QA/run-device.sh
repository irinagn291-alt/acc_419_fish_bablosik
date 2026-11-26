#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
: "${GF_SIMULATOR_UDID:?Run this script through the factory simulator pool}"
kind="${1:-iphone}"
mkdir -p "QA/$kind"
xcrun simctl boot "$GF_SIMULATOR_UDID"
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
attempt=0
while :; do
 suffix=""
 if [ "$attempt" -gt 0 ]; then suffix="-retry$attempt"; fi
 result="QA/$kind/results$suffix.xcresult"
 log="QA/$kind/tests$suffix.log"
 set +e
 xcodebuild -project AnglerLog.xcodeproj -scheme ReedLedger -configuration Debug -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 -derivedDataPath Artifacts/DerivedData -resultBundlePath "$result" CODE_SIGNING_ALLOWED=NO test > "$log" 2>&1
 status=$?
 set -e
 xcrun xcresulttool export attachments --path "$result" --output-path "QA/$kind/attachments$suffix" || true
 printf '%s\n' "$status" > "QA/$kind/latest-status"
 printf '%s\n' "$result" > "QA/$kind/latest-result"
 if [ "$status" -eq 0 ] || [ "$attempt" -ge 2 ]; then break; fi
 # Allow a bounded repair of a failed test while the same owned foreground
 # session is alive. All device work remains inside this pool-wrapped script.
 touch "QA/$kind/awaiting-repair"
 received=0
 for ((n=0;n<300;n++)); do
  if [ -f "QA/$kind/retry-request" ]; then received=1; break; fi
  sleep 1
 done
 rm -f "QA/$kind/awaiting-repair"
 if [ "$received" -ne 1 ]; then break; fi
 rm -f "QA/$kind/retry-request"
 attempt=$((attempt+1))
done
xcrun simctl launch "$GF_SIMULATOR_UDID" com.anglerlog.app -AppleLanguages '(en)' -AppleLocale en_US || true
sleep 2
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "QA/$kind/final-journal.png" || true
xcrun simctl ui "$GF_SIMULATOR_UDID" appearance dark
xcrun simctl terminate "$GF_SIMULATOR_UDID" com.anglerlog.app || true
xcrun simctl launch "$GF_SIMULATOR_UDID" com.anglerlog.app -AppleLanguages '(en)' -AppleLocale en_US || true
sleep 2
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "QA/$kind/dark-journal.png" || true
xcrun simctl terminate "$GF_SIMULATOR_UDID" com.anglerlog.app || true
xcrun simctl launch "$GF_SIMULATOR_UDID" com.anglerlog.app -AppleLanguages '(en)' --widget-qa || true
sleep 2
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "QA/$kind/dark-widget-families.png" || true
xcrun simctl ui "$GF_SIMULATOR_UDID" appearance light
container=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.anglerlog.app data) || true
if [ -n "${container:-}" ] && [ -f "$container/Library/Application Support/reed-ledger.json" ]; then
 cp "$container/Library/Application Support/reed-ledger.json" "QA/$kind/persisted-ledger.json"
fi
if [ -n "${container:-}" ]; then
 mkdir -p "QA/$kind/exports"
 find "$container/tmp" -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.csv' \) -exec cp {} "QA/$kind/exports/" \; || true
fi
if [ "$kind" = "iphone-verified" ] && [ "${GF_ANGLER_SECOND_PASS:-0}" != "1" ]; then
 # This is one foreground QA operation. The nested pool session inherits the
 # lock owned by the outer helper and allocates its own disposable iPad.
 # Shut down the owned phone before starting the next device.
 xcrun simctl shutdown "$GF_SIMULATOR_UDID"
 status2=0
 GF_ANGLER_SECOND_PASS=1 python3 ../../../../gf/genesis/simulator_pool.py 4671120C-F54F-4008-A170-413F94D007D6 bash QA/run-device.sh ipad-verified > QA/ipad-verified-pool.log 2>&1 || status2=$?
 if [ "$status" -eq 0 ]; then status=$status2; fi
fi
exit "$status"
