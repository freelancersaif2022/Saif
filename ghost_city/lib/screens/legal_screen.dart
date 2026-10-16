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

const _highlights = {
  LegalDoc.privacy: [
    (Icons.person_off_outlined, 'No account'),
    (Icons.block_rounded, 'No ads'),
    (Icons.insights_rounded, 'No tracking'),
    (Icons.phone_android_rounded, 'Stays on your phone'),
  ],
  LegalDoc.terms: [
    (Icons.person_outline_rounded, 'Personal use'),
    (Icons.directions_walk_rounded, 'Walk safely'),
    (Icons.photo_library_outlined, 'Credited sources'),
    (Icons.workspace_premium_outlined, 'Plus optional'),
  ],
  LegalDoc.licences: [
    (Icons.streetview_rounded, 'Mapillary'),
    (Icons.menu_book_rounded, 'Wikipedia'),
    (Icons.satellite_alt_rounded, 'Esri Wayback'),
    (Icons.map_outlined, 'OpenStreetMap'),
  ],
};

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final (title, intro, icon, sections) = switch (doc) {
      LegalDoc.privacy => ('Privacy policy', 'How Ghost City handles your location, camera, microphone and memories.', Icons.privacy_tip_outlined, _privacy),
      LegalDoc.terms => ('Terms & conditions', 'The rules for using Ghost City and the content it shows.', Icons.gavel_rounded, _terms),
      LegalDoc.licences => ('Licences', 'Where every photo, text, map and font in Ghost City comes from.', Icons.copyright_rounded, _licences),
    };
    final highlights = _highlights[doc]!;

    return Scaffold(
      backgroundColor: GC.ground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: GC.ground,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 68,
            titleSpacing: 16,
            title: Row(children: [
              GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: GC.body(16, color: GC.text, weight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, pad.bottom + 30),
            sliver: SliverList.list(children: [
              // Hero.
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A2F1A), Color(0xFF1A1815)],
                  ),
                  borderRadius: BorderRadius.circular(GC.radiusL + 4),
                  border: Border.all(color: const Color(0x4DE9B44C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF3D9A1), GC.amber]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x40E9B44C), blurRadius: 18, offset: Offset(0, 6))],
                      ),
                      child: Icon(icon, color: GC.onAmber, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(title, style: GC.display(32, height: 1.1)),
                    const SizedBox(height: 8),
                    Text(intro, style: GC.body(15, color: GC.textSoft, height: 1.5)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _Chip(icon: Icons.event_rounded, text: _updated.replaceFirst('Last updated: ', 'Effective ')),
                      const _Chip(icon: Icons.verified_outlined, text: 'Ghost City 1.0.0'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // At a glance.
              Text('AT A GLANCE', style: GC.label()),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.9,
                children: [
                  for (final h in highlights)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: GC.surface,
                        borderRadius: BorderRadius.circular(GC.radiusM),
                        border: Border.all(color: GC.line),
                      ),
                      child: Row(children: [
                        Icon(h.$1, color: GC.amber, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(h.$2, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GC.body(13.5, color: GC.text, weight: FontWeight.w600, height: 1.25)),
                        ),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('DETAILS', style: GC.label()),
              const SizedBox(height: 10),
              for (var i = 0; i < sections.length; i++) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: GC.surface,
                    borderRadius: BorderRadius.circular(GC.radiusL),
                    border: Border.all(color: GC.line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: GC.amberDeep,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x66E9B44C)),
                        ),
                        child: Text('${i + 1}', style: GC.body(13, color: GC.amber, weight: FontWeight.w800, height: 1)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(sections[i].heading, style: GC.display(18, height: 1.2)),
                            const SizedBox(height: 8),
                            Text(sections[i].body, style: GC.body(14.5, color: GC.textSoft, height: 1.6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(GC.radiusL),
                  border: Border.all(color: const Color(0x4DE9B44C)),
                  color: const Color(0x0FE9B44C),
                ),
                child: Row(children: [
                  const Icon(Icons.mark_email_unread_outlined, color: GC.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Questions about this page? Contact the developer through the app’s store listing.',
                        style: GC.body(13.5, color: GC.textSoft, height: 1.45)),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0x660F0E0C), borderRadius: BorderRadius.circular(99), border: Border.all(color: GC.line)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: GC.amberLight),
        const SizedBox(width: 6),
        Text(text, style: GC.body(12, color: GC.amberLight, weight: FontWeight.w600, height: 1)),
      ]),
    );
  }
}
