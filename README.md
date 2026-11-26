# FIsh Bablosik

Native iPhone + iPad fishing journal. Open `AnglerLog.xcodeproj`, scheme **ReedLedger**, minimum iOS **17.5**. No third-party dependencies. The application is free and has no purchases, advertising or tracking.

The app uses four Swift files plus the shared WidgetKit view file. A sixth authored Swift file contains QA tests. The WidgetKit extension is required by Apple’s extension architecture; the test target is not shipped. Live Activities are intentionally excluded by the individual specification.

Journal entries, photos, saved weather, offline map pins, activity calendars, lure statistics, CSV/JSON backup and restore, catch cards and annual PDF reports work locally. The app never seeds demo records. Test entries are created only by the UI test runner and have a QA label. Photo attachments are resized, and EXIF metadata is not copied. Location can be entered manually or picked on the atlas. Online weather and private CloudKit sync are separately opt-in. Reminders request system permission only when enabled.

## Build

Select full Xcode for the command process if needed:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project AnglerLog.xcodeproj -scheme ReedLedger \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath Artifacts/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project AnglerLog.xcodeproj -scheme ReedLedger -configuration Release \
  -destination 'generic/platform=iOS' -derivedDataPath Artifacts/DeviceDerivedData \
  -archivePath Artifacts/AnglerLog.xcarchive CODE_SIGNING_ALLOWED=NO archive
```

`Tools/configure.py` is an optional project generator. The checked-in project can be built directly; regeneration intentionally produces fresh object UUIDs. `Tools/artwork.py` reproduces the icon and map tiles using Pillow, a tooling dependency only. The app itself has no package dependencies.

## Simulator QA

Run the entire foreground script through the factory pool, using an existing iOS template UDID:

```sh
factory_root=$(cd ../../../.. && pwd)
python3 "$factory_root/gf/genesis/simulator_pool.py" TEMPLATE_UDID bash QA/run-device.sh iphone
```

Use a fresh output label on repeated runs because xcresult bundles cannot be overwritten. The script uses only the pool-provided device, disables parallel testing and exports evidence before that disposable simulator is released. Use the factory’s shared queue; do not create app-specific devices or use the normal simulator directly.

## Signing and CloudKit

Unsigned builds display local-only sync availability without calling CloudKit; a signed rebuild enables the real CloudKit path. The project contains real App Group, iCloud and Push entitlements with app-specific identifiers. For device installation, select the publisher’s Apple team and provision the app and extension. Enable the private container `iCloud.com.anglerlog.app`, group `group.com.anglerlog.app`, and the `ReedEntry` record type with binary `payload` and optional Asset `photo` fields in custom zone `ReedPages`. The record-name system field must be queryable for the private journal scan; deploy the development schema before production distribution. The sync loop paginates, merges by modification time and persists deletions. No public database, own server or remote notification sender is used.

CloudKit account/signing and physical camera/GPS tests require the publisher’s environment and are not implied by a successful unsigned archive. Weather is ECCC GDPS / NASA POWER model data under CC BY 4.0 and its free non-commercial service terms. Map tiles are bundled Natural Earth public-domain coastlines and country borders, with no detailed navigation charts. Read `QA/source-verification.md` and `StoreMetadata/Privacy.md` before distribution. Store publishing and paid actions are outside this project task.
