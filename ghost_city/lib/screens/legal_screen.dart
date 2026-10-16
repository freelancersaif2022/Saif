import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/common.dart';

enum LegalDoc { privacy, terms, licences }

class _Section {
  const _Section(this.heading, this.body);
  final String heading;
  final String body;
}

const _updated = 'Last updated: 16 October 2026';

const _privacy = [
  _Section('In short',
      'Ghost City has no accounts, no advertising and no analytics. What you create stays on your phone. The app only sends a location to the services listed below so it can show you photos and places for that spot.'),
  _Section('Your location',
      'With your permission, the app reads your phone’s location to find street photos, archive photos, satellite images, landmarks and walks near you. The location is not stored on any server by Ghost City. To answer a request, the coordinates (or the place name you search for) are sent to: Mapillary (street photos), Wikimedia Commons and Wikipedia (photos and landmark information), Esri World Imagery Wayback (satellite images) and OpenStreetMap Nominatim (place names and search). Each of these services has its own privacy policy.'),
  _Section('Camera and microphone',
      'The camera is used only to show the live view in the Time Lens; no photos or video are recorded or uploaded. The microphone is used only while you record a memory. Recordings are saved in the app’s private storage on your phone and are never uploaded.'),
  _Section('Data stored on your phone',
      'Your memories (audio, title, place name and year), saved places, narration speed and the Plus setting are stored on your device. Uninstalling the app or clearing its data deletes them.'),
  _Section('Children',
      'Ghost City does not knowingly collect personal information from anyone, including children.'),
  _Section('Changes',
      'If this policy changes, the new version will appear in the app with a new date.'),
];

const _terms = [
  _Section('Using Ghost City',
      'Ghost City shows photos, satellite images and information about places from public archives. You may use the app for personal, non-commercial purposes.'),
  _Section('Content from other sources',
      'Photos, texts and images shown in the app come from Mapillary, Wikimedia Commons, Wikipedia, Esri and OpenStreetMap and belong to their authors under the licences listed in Licences. Dates and descriptions come from those sources and may be incomplete or wrong. Ghost City does not guarantee their accuracy.'),
  _Section('Safety',
      'Pay attention to your surroundings when walking, especially near traffic. Do not use the Time Lens or Time Walks while driving. Walk times and distances are estimates measured in a straight line between stops.'),
  _Section('Your memories',
      'You are responsible for what you record. Recordings stay on your phone and are not shared by the app.'),
  _Section('Ghost City Plus',
      'Plus unlocks extra walks, Ghost mode and unlimited memories. In this version Plus is in test mode and no payment is taken.'),
  _Section('No warranty',
      'The app is provided “as is”. Online features depend on third-party services that may change or be unavailable at any time.'),
];

const _licences = [
  _Section('Street photos', 'Mapillary contributors, licensed CC BY-SA 4.0. Each photo shows its author.'),
  _Section('Archive photos and landmark texts',
      'Wikimedia Commons and Wikipedia contributors. Texts are licensed CC BY-SA 4.0; each photo keeps the licence shown with it.'),
  _Section('Satellite images', 'Esri World Imagery Wayback. Imagery © Esri, Maxar, Earthstar Geographics and the GIS user community.'),
  _Section('Place names and search', 'Data © OpenStreetMap contributors, available under the Open Database License (ODbL), via Nominatim.'),
  _Section('Historic photographs in the app',
      'Moulin Rouge, Paris (autochrome, c. 1914); Campus Martius, Detroit (c. 1915); Erie County Savings Bank, Buffalo (c. 1908); Broadway, Saratoga Springs (c. 1900–1915); Manhattan riverfront (1931). All in the public domain.'),
  _Section('Fonts', 'Fraunces and Manrope, licensed under the SIL Open Font License 1.1.'),
  _Section('Software', 'Built with Flutter and open-source packages under their own licences (BSD, MIT and Apache 2.0).'),
];

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final (title, sections) = switch (doc) {
      LegalDoc.privacy => ('Privacy policy', _privacy),
      LegalDoc.terms => ('Terms & conditions', _terms),
      LegalDoc.licences => ('Licences', _licences),
    };
    return Scaffold(
      backgroundColor: GC.ground,
      body: ListView(
        padding: EdgeInsets.fromLTRB(22, pad.top + 10, 22, pad.bottom + 30),
        children: [
          Row(children: [
            GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 18),
          Text(title, style: GC.display(32)),
          const SizedBox(height: 6),
          Text(_updated, style: GC.body(13, color: GC.faint)),
          const SizedBox(height: 22),
          for (final s in sections) ...[
            Text(s.heading, style: GC.body(16, color: GC.text, weight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 6),
            Text(s.body, style: GC.body(15, height: 1.6)),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
