# Ghost City

See any street as it was. Ghost City lays real archive photographs over your live camera, reads the history of each place aloud, and lets you pin your own voice memories to the spots where they happened.

Built with Flutter. No account, no backend: everything is stored on the phone.

## Run it

```bash
cd ghost_city
flutter pub get
flutter run            # on a connected phone
flutter build apk      # Android release APK
flutter build ipa      # iOS (needs Xcode and a signing team)
```

Use a real phone. The Time Lens needs a camera and memories need a microphone.

## Near me (automatic, any place)

Open the **Near me** tab (or long-press anywhere on the Map) and Ghost City finds the past of that exact spot by itself:

- **Street**: street-level photos from 5 to 25 years ago by Mapillary contributors.
- **Photos**: dated photos taken nearby, from Wikimedia Commons.
- **Satellite**: Esri World Imagery Wayback, one image per year from 2014, compared with today using a drag divider.
- Filter by 5–10, 10–15 or 15–20 years ago, open any photo full screen, and compare it with your live camera.
- Search any city, street or landmark (OpenStreetMap Nominatim).
- Without internet, the app shows a "No internet connection" notice and an offline screen instead of loading.

The Mapillary client token is built into the app. To use a different one, add a `MAPILLARY_TOKEN` repository secret; the build passes it with `--dart-define`.

## Screens

| Screen | What it does |
| --- | --- |
| Welcome | Three full-bleed archive photos (Paris 1914, Detroit 1915, New York 1931) |
| Map | Live dark map with year pins, era filters, search and swipeable place cards |
| Time Lens | Live camera with the old photo over it. Drag the divider, pinch to line the photo up, double-tap to reset, torch |
| Place | Hero photo, history, facts, narrated stories, your memories, full-screen photo viewer, save |
| Story | Narration from the phone's built-in voice, transcript that lights up as it is read, seek, three speeds |
| Explore | Featured place, all places, saved places |
| Time Walks (Plus) | Guided routes on a map, narrated stop by stop |
| Memories | Record with live levels, listen back, title, place, decade, play and delete later |
| Plus paywall | Plans and benefits. **Test mode**: unlocking is free and stored on the phone |
| Settings | Plan, narration speed, data, erase everything, photo credits, licences |

### Plus features
- Every narrated story
- Guided Time Walks (the Montmartre walk is free)
- Ghost mode in the Time Lens (fade slider)
- Unlimited memories (3 are free)

## Before publishing
- **Payments:** the paywall unlocks Plus without charging. Connect `in_app_purchase` (or RevenueCat) in `lib/screens/paywall_screen.dart` and set your real prices.
- **Map tiles:** the app uses CARTO dark basemap tiles with OpenStreetMap data. Check CARTO's terms for your expected traffic or swap in your own tile provider in `map_screen.dart` and `walks_screen.dart`.
- **Content:** places, stories and walks live in `lib/data/content.dart`. Add more there.

## Credits
- Photographs: public-domain archive images (autochrome c. 1914; Detroit Publishing Co. c. 1900–1915; New York 1931). Credits are shown in the app.
- Fonts: Fraunces and Manrope (SIL Open Font License).
- Map data © OpenStreetMap contributors, tiles © CARTO.
