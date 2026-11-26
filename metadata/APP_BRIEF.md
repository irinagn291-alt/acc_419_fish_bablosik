<!-- gf-brief source=285bb3c3d30fb4f5e00276e1df3be40616e4f1b0aaa0faf317b41e293f5896b0 written=2026-11-26T03:49:06+03:00 -->
# FIsh Bablosik

## What it is

FIsh Bablosik is a private fishing journal for anglers who want to record catches and outings, revisit fishing spots, and see patterns in their own records. Entries can include a lure, fish count, measurements, notes, a photo, coordinates, and a weather snapshot. The journal, offline atlas, and activity summaries are available without an internet connection.

## Launch and onboarding

1. After the iOS launch screen, the app opens directly to the “Journal” tab under the navigation title “FIsh Bablosik”. There is no walkthrough, sign-in, or permission prompt on a normal first launch.
2. A fresh journal shows “Entries”, “Fish logged”, and “Species” at zero. “Field notes” also shows zero, followed by “A journal worth keeping” and “Log your first catch. A place, a lure and a few details are all you need. Everything stays available offline.”
3. Tap “Log a catch” or the toolbar plus icon, whose accessibility label is “Log a catch”, to open “New entry”. The first entry uses the current date and time, one fish, and zero for weight and length. Enter a species and lure, then tap “Save” to return to the journal with the entry. Tap “Cancel” to close the form without saving.
4. The tab bar offers “Journal”, “Map”, “Activity”, and “Tools”. On later cold launches, “Journal” opens with the saved entries.

## Screens

The labels and copy below are from the English interface. iOS supplies the controls in the search field, date picker, photo picker, camera, document picker, share sheet, and permission dialogs.

### “Journal”

- The navigation title is “FIsh Bablosik”. The page heading is “Journal”, with totals for “Entries”, “Fish logged”, and “Species”. “Field notes” shows the count of entries matching the current search.
- “Log a catch” and the toolbar plus icon both open “New entry”.
- “Search species, lure or place” filters the list as you type. It also searches notes. Clear the query to restore the full list.
- Entries are sorted newest first. Compact rows show a photo or fish icon, the species, lure, date, and count beside “Fish”. On wider layouts, the list has columns labeled “Date”, “Species”, “Lure”, “Place”, and “Fish”. Tap any entry to open “Catch details”.

### “Map” — “Catch map”

- The offline world atlas shows saved fishing points as fish pins. Drag to pan and pinch to zoom. Tap a pin to open that entry’s “Catch details”.
- The map is labeled “Offline atlas · Natural Earth”. Below it are “Your places, always available”, “World atlas with saved coordinates. Coastlines and borders only; no detailed navigation charts.”, and the count of “entries with a location”.
- A place name alone leaves the entry in the journal. Both latitude and longitude are needed for a pin.

### “Activity”

- “Patterns from your own water” appears above the “Fish logged” and “Entries” totals.
- “Species”, “Lure”, and “Weather” open filter menus populated by saved entries. “All species”, “All lures”, and “All weather” clear their respective filters. The filters can be combined.
- The month arrows, labeled “Previous month” and “Next month” for accessibility, move the “Species calendar” one month at a time. Calendar cells show a fish count or “·” and have no tap action.
- “Lure performance” ranks logged lures by fish count and shows a bar for each. The totals and lure ranking use all entries matching the filters. The month arrows change the calendar alone.
- With no matches, the ranking area says “Add entries to discover your patterns.” The screen ends with “Counts describe your journal, not a prediction of future catches.”

### “Tools”

- **“Export & backup”** offers “Export journal as CSV” for a shareable table of saved entries, “Save complete backup” for a shareable backup that includes photos, and “Restore backup” to choose and merge a compatible backup. The explanatory copy is “Backups include photos, coordinates and weather. Share them only with people you choose.”
- **“Year in review”** offers “Year”, which defaults to the current year, and “Share annual report”, which opens the system share sheet with a PDF for the selected year. It contains the entry, fish, and species totals, “Lure performance”, and “Field notes” with entries, place names, and notes.
- **“Weather”** offers “Fetch weather automatically”, the same switch as in the entry editor. When a recent reading exists, it shows the condition, temperature, wind speed, pressure, date and time, and source. “Refresh latest weather” appears when a fishing point is available and fetches current weather for that point. The newest dated entry with coordinates supplies the point when available. A previously fetched weather point can also supply it. The source links are “DWD · Bright Sky”, “ECCC · GDPS”, “NASA POWER”, and “CC BY 4.0”.
- **File transfer.** “Export file” opens the system save picker with the suggested name “FIsh Bablosik - Records”. “Import file” opens the document picker for a compatible export from that control. It merges the records and shows “File imported” on success. Errors appear as inline system messages. This pair is separate from “Save complete backup” and “Restore backup”.
- **“Reminders”** offers “Daily journal reminder” and “Friday preparation”, both off initially. “Time” sets a shared hour from “00:00” through “23:00” and defaults to “19:00”. The section says “Choose a gentle prompt to record your catch or prepare for the weekend. Notifications are requested only when you enable a reminder.” The daily notification reads “Remember your catch” and “Add a few details to your fishing journal.” The Friday notification reads “Before the weekend” and “Review your tackle and refresh the latest weather before heading out.” It can append “Last weather” with the saved reading.
- **“Privacy & sources”** shows “No ads, purchases, analytics or tracking. The journal and photos are stored locally. Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again. Weather requests share coordinates with Bright Sky (DWD), ECCC GDPS / NASA POWER. Exports leave the app only through your chosen destination.” It also shows “Location, camera and photos are optional. You can type a place and coordinates, and keep entries without a photo or weather.” Tap “Map data · Natural Earth · Public domain” for the atlas attribution. The version line reads “FIsh Bablosik · 1.2.2 (22)”.

### “New entry” and “Edit entry”

The form opens from “Log a catch” or from “Edit” on a saved entry. The title changes from “New entry” to “Edit entry” once “Species” contains text.

- **“Catch details”** has “Date & time”, free-text “Species” and “Lure”, a “Fish” stepper from 0 to 999, and numeric fields labeled “Weight (kg)” and “Length (cm)”. The copy reads “Use zero fish to record a quiet outing. Weight and length describe the largest fish.” The date and time picker allows times up to the present.
- **“Place”** has “Place name (optional)”, “Use current location”, “Latitude”, “Longitude”, and “Choose on offline map”. Current location fills the coordinate fields. Coordinates can also be typed or selected on the atlas. The form accepts decimal points or decimal commas in coordinates.
- **“Weather snapshot”** has “Fetch weather automatically”. With that setting on, saving an entry with coordinates can fetch weather for its date and time. A snapshot shows a condition such as “Model weather”, “Clear”, “Cloudy”, “Fog”, “Snow”, “Thunderstorm”, “Showers”, or “Rain”, plus temperature, wind, pressure, timestamp, and source. “Remove weather” clears the snapshot from the form.
- The weather explanation here and in “Tools” reads “When enabled, coordinates and date are sent to Bright Sky (DWD), ECCC GDPS / NASA POWER to attach model weather to new entries. Saved snapshots never change. Without a connection you can still save. Bright Sky (DWD), ECCC GDPS logs the network IP and the requested forecast point. Weather requests round coordinates to two decimal places.”
- **“Catch photo”** offers “Choose photo” to select an image and “Take photo” to open the camera on devices with an available camera. The entry holds one photo. A selected photo appears in the form with “Remove photo”.
- **“Notes”** is a free-text field with a live character counter ending in “/12000”.
- “Cancel” closes the form and discards changes. “Save” commits the entry and returns to the preceding screen. Notices in the form have an “OK” button.

### “Choose location”

“Choose on offline map” opens this atlas sheet. “Tap the atlas to choose a point” appears over the map. Pan and zoom to the spot, then tap it to fill “Latitude” and “Longitude” and return to the form. “Cancel” returns without choosing a new point.

### “Catch details”

- The entry shows the species, date and time, and photo when present. Without a photo, the header displays “FIELD NOTES”. The “Fish” and “Lure” tiles show the saved count and lure. Measurements appear if either is greater than zero.
- The place line uses the entered name or “Fishing place”. Beneath it are selectable coordinates or “No location”. Entries with coordinates also show an embedded offline map. Saved notes can be selected.
- The weather panel shows the saved snapshot or “No weather snapshot” and “Edit and save with online weather enabled to retry for this entry’s date.”
- “Done” closes the detail screen. “Edit” opens “Edit entry”.
- “Share catch card” creates an image and opens the system share sheet. The card shows “FIsh Bablosik”, the species, date, count with “Fish”, lure, place, and any photo, weather, and notes. Weather on the card carries source and license credit. Notes on the card are limited to eight displayed lines.
- “Save card to Photos” saves the card to the photo library. It reads “Saving…” while the operation is in progress.
- “Delete entry” opens “Delete this entry?” with “Delete entry” to remove the catch and “Cancel” to keep it. If a previously opened record becomes unavailable, the screen shows “Entry unavailable”.

### Home Screen and Lock Screen widgets

The widget is named “FIsh Bablosik” and described as “Your journal, weather and fishing patterns, available offline.”

- The small Home Screen widget shows “Entries” and “Fish this month”. Tap it to open “New entry”.
- The medium Home Screen widget shows “Fishing weather”, “Last weather”, and a timestamped reading marked “Model weather” or “Cached weather”. Before the first reading it says “Open the app and fetch weather at a fishing point.”
- The large Home Screen widget shows “Season map”, “Fish”, “Lure performance”, and “Species calendar”. It shows this year’s mapped locations, up to three lures, the past 14 days, and up to three species names. With an empty journal, the lure section says “No entries yet”. Tap it to open “Activity”.
- The rectangular and inline Lock Screen widgets show pressure and wind or “No weather snapshot”. The rectangular version also shows the timestamp and “Last weather” when available. The circular version shows wind speed in “km/h” or a crossed-out cloud icon.

## Features

- “Journal” and “Field notes” for creating, searching, editing, and deleting private fishing records, including zero-fish outings.
- “Catch details”, “Place”, “Catch photo”, and “Notes” for recording measurements, locations, one photo, and free-form notes.
- “Catch map” and “Choose on offline map” for viewing saved points and choosing coordinates without GPS or internet access.
- “Activity”, “Species calendar”, and “Lure performance” for filtering and reviewing catch counts.
- “Weather snapshot”, “Fetch weather automatically”, and “Refresh latest weather” for attaching weather to a catch or updating the latest reading.
- “Share catch card” and “Save card to Photos” for exporting an image of an entry.
- “Export journal as CSV”, “Save complete backup”, “Restore backup”, “Export file”, and “Import file” for taking journal data out of the app or bringing it back in.
- “Year in review” and “Share annual report” for producing an annual PDF.
- “Daily journal reminder” and “Friday preparation”, plus Home Screen and Lock Screen widgets for journal counts, weather, and activity.

## Behaviours that can look like bugs

- **“Save” stays disabled until the form is valid.** Enter a nonblank “Species” and “Lure”. Both are limited to 120 characters after trimming surrounding whitespace, “Place name (optional)” to 240, and “Notes” to 12,000. The form shows “Species and lure names allow 120 characters; place names allow 240.” or “Notes are limited to 12,000 characters.” Weight must be between 0 and 10,000 kg and length between 0 and 3,000 cm. Zero fish, zero measurements, and blank optional fields are allowed.
- **Partial or invalid coordinates block saving.** The form says “Enter latitude −90…90 and longitude −180…180, or leave both empty.” Fill both fields, choose a point with “Choose on offline map”, or clear both fields.
- **Location can take a moment.** “Use current location” changes to “Finding location…” and is disabled while it waits. If the request fails, the app shows “Location unavailable. Enter coordinates or choose a point on the map.” If access is off, it shows “Location is off. You can enter a point manually.”
- **The save button becomes a spinner.** While “Save” is in progress, “Cancel” and swipe-to-dismiss are unavailable. A weather failure can still leave a saved entry and show “Entry saved without weather. Open it later to retry the snapshot.” To retry, use “Edit”, turn on “Fetch weather automatically”, ensure the entry has coordinates, and save again.
- **A removed snapshot can come back on save.** Turn off “Fetch weather automatically” before saving if the entry should stay without weather. Changing the date, time, or coordinates clears the old snapshot and can trigger another fetch.
- **The first-use screens are empty.** “A journal worth keeping” clears after the first saved entry. “Catch map” starts with zero located entries until a catch has coordinates. “Species calendar” uses dots for days with zero fish, including days with only zero-fish outings. If “Add entries to discover your patterns.” appears with an existing journal, reset the filters to “All species”, “All lures”, and “All weather”. If the journal search shows no matches, clear the search.
- **Exports have different availability and import counterparts.** “Export journal as CSV” and “Share annual report” require at least one saved entry. An annual report for a year with no entries can still contain zero totals. Pair “Save complete backup” with “Restore backup” and “Export file” with “Import file”. Imports merge records, leave unrelated entries in place, and use the newer version of matching records. “Restore backup” shows “This backup could not be restored. Choose a FIsh Bablosik JSON backup.” for an incompatible backup. A share failure can show “Could not prepare the export.”
- **Latest weather needs a point and an enabled switch.** “Refresh latest weather” appears once a fishing point is available and is disabled while “Fetch weather automatically” is off. A failed refresh shows “Weather unavailable. Your entry can be saved without it.”
- **Reminders can switch themselves off.** If permission is denied or scheduling fails, the reminder switches reset. The messages are “Notifications are off. Enable them in system Settings.” and “Could not schedule reminders.” Allow notifications in iOS Settings if needed, then enable the reminder again.
- **Photos have separate selection and saving paths.** For “Could not open this photo. Choose another image.”, try a different image. After “Save card to Photos”, the app shows “Catch card saved to Photos.”, “Could not save the card to Photos.”, or “Photo access is off. Use Share to save the card elsewhere.” Use “Share catch card” to choose another destination.
- **Journal read and write errors require action.** “Journal could not be read. Export or restore your backup before changing data.” can appear on launch if saved data is unreadable. A write failure shows “Could not save on this device. Please free storage and try again.” Standard app alerts use “FIsh Bablosik” and “OK”.

## Starter content and resume

None for sample catches, seeded journal entries, or saved drafts. The offline atlas is available immediately. Saved entries and settings persist across launches, and a saved entry can be reopened with “Edit”. An unfinished new entry or unsaved edit is discarded when its form is dismissed or the app is terminated.

## Permissions

- **Location while using the app.** Requested when “Use current location” is tapped for the first time. “Save the fishing point and fetch weather for that point when you choose.”
- **Camera.** Requested when “Take photo” first opens the camera. “Photograph your catch to keep the image with a journal entry.”
- **Add to Photos.** Requested when “Save card to Photos” is first used. “Keep a designed catch card in Photos when you tap Save card.”
- **Notifications.** Requested when “Daily journal reminder” or “Friday preparation” is first enabled. iOS supplies the prompt text. The app has no custom notification usage-description string.
- **Photo selection.** “Choose photo” uses the system picker and grants access to the chosen image without requesting general photo library access. A usage description is declared for general library access, “Pick a catch photo to attach to your private fishing journal.”

## Absent

- Login or app accounts.
- In-app purchases.
- Ads.
- Analytics.
- Account deletion flow.
- App Tracking Transparency prompt.

Users create their own private journal entries, notes, and attached photos. The app has no public posting or in-app community. Sharing is initiated by the user through iOS.

## Data and support

The journal and photos stay on the device by default. There is no in-app cloud sync control or working cloud sync. Exports, reports, and catch cards leave the app through the destination the user chooses. The device’s widgets use local journal summaries without the entry photos or notes.

Online weather is off by default. With “Fetch weather automatically” enabled, weather requests send the fishing point rounded to two decimal places and the requested time to the applicable weather provider. The journal can still be saved when a provider is unavailable.

There is no on-screen “Contact” or “Support” control. The links in “Tools” lead to weather sources, attribution, and licensing.

## Scanning and health

None.

## Platform

- iPhone and iPad, with iOS or iPadOS 17.5 minimum. The wider journal layout uses a table.
- iPhone supports portrait and both landscape orientations. iPad also supports upside-down portrait.
- The native interface is available in English, German, French, and Spanish, with English as the development language. Dates and the calendar follow the device’s locale and calendar settings. Measurements remain metric.
- There is no region selector or country gate. The offline atlas is worldwide. Historical weather more than two hours old uses NASA POWER. For more recent requests, the app tries a nearby DWD weather station through Bright Sky and falls back to ECCC GDPS. Availability depends on the fishing point and requested time.

## Category

Productivity
