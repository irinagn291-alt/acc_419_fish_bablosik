# FIsh Bablosik privacy

FIsh Bablosik contains no advertising, analytics, tracking SDKs or accounts operated by the publisher. Journal entries, photos and coordinates are stored in Application Support on the device; local backups are controlled by the operating system. Photo attachments are resized and encoded again, without copying EXIF location metadata. Deleting an entry removes its content; a content-free identifier and modification date remain to propagate deletion during optional sync.

Location and photo permissions are optional. Camera access is requested by the system when taking a picture. The system photo picker grants only the selected image. Saving a catch card requests add-only Photos access. Entries can be created entirely by hand without any permissions.

Online weather is off by default. If enabled, the chosen coordinates and catch date are transmitted directly to ECCC GDPS / NASA POWER over HTTPS. The app does not operate a proxy. Weather data is modelled, not a measurement at the fishing point. A saved entry’s weather does not change during later background refresh. The independent last-weather cache remains on the device for widgets after a catch is deleted. Turning automatic weather off stops further weather requests. Deleting the app (rather than offloading it) removes local app storage. The provider has its own service terms and privacy policy: https://geo.weather.gc.ca/doc/TermsOfService . Device/network information may be processed by the provider to deliver the service. No location is requested in the background; background refresh reuses the last explicitly chosen point, only while online weather is enabled.

Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again. It is off by default and can be disabled in Tools. Turning it off leaves the local journal available. Entry deletion is synchronized when the user next syncs. Exported backups contain photos and coordinates; users choose their recipients using the system share sheet.

Local reminders are requested only when enabled. No remote notification server exists. The app does not promise immediate notifications or weather updates. Background execution is scheduled by iOS and is not guaranteed.

Before distribution the publisher must host this policy and provide a real support contact in App Store Connect. No invented support email or policy URL is embedded. The final App Privacy questionnaire must reflect the optional third-party weather service and the publisher’s deployment, rather than treating transmitted coordinates as purely offline data.

ECCC GDPS records the network IP and the requested forecast location in service logs. Weather coordinates are rounded to two decimal places before transmission. The app also supports local use. [ECCC GDPS service terms](https://geo.weather.gc.ca/doc/TermsOfService)
