import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../widgets/panel.dart';

enum LegalPage { privacy, terms, about }

/// In-app Privacy Policy, Terms of Service and About pages.
///
/// Replace the placeholder company details and URLs below with your own
/// before publishing; Google Play also requires the privacy policy URL in
/// the store listing.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.page});
  final LegalPage page;

  static const privacyUrl = 'https://example.com/dragonland/privacy';
  static const termsUrl = 'https://example.com/dragonland/terms';

  String get _title => switch (page) {
    LegalPage.privacy => 'PRIVACY POLICY',
    LegalPage.terms => 'TERMS OF SERVICE',
    LegalPage.about => 'ABOUT DRAGON LAND',
  };

  String get _body => switch (page) {
    LegalPage.privacy =>
      '''
Dragon Land is published by Moix Limited.

Data stored on your device
Your game progress (coins, gems, unlocked dragons, missions, settings and statistics) is stored locally on your device. It is not uploaded to our servers.

Advertising
Dragon Land shows ads served by Google AdMob. Google may collect and use device identifiers, IP address and usage data to serve and measure ads, and where required asks for your consent. You can review or change consent from Settings > Ad privacy options. See https://policies.google.com/technologies/ads.

Purchases
In-app purchases are processed by Google Play. We never receive your payment details. Purchase tokens may be verified with Google Play to deliver your items.

Children
Dragon Land is not directed at children under 13 unless configured for families in the Play Console.

Contact
privacy@example.com

Full policy: $privacyUrl
''',
    LegalPage.terms =>
      '''
By playing Dragon Land you agree to these terms.

Virtual items
Coins, gems and dragons are virtual items with no real-world monetary value. They are licensed to you for use in the game and cannot be exchanged for money.

Purchases
All purchases are processed by Google Play and subject to Google Play's terms and refund policy. Consumable items (coins and gems) are delivered once per purchase.

Remove Ads
Remove Ads disables banner and interstitial ads. Optional rewarded videos that you choose to watch remain available.

Fair play
Do not modify, hack or exploit the game.

Full terms: $termsUrl
''',
    LegalPage.about =>
      '''
Dragon Land — Discover Your Dragon Adventure

Run, jump, fly and battle through a magical world of floating islands with five unique dragons: Ember, Aqua, Shadow, Leaf and Solar.

Version 1.0.0
© Moix Limited

Built with Flutter and the Flame engine.
Fonts: Lilita One and Fredoka (SIL Open Font License).
All artwork and audio are original and were generated procedurally for Dragon Land.
''',
  };

  @override
  Widget build(BuildContext context) {
    return MenuScaffold(
      title: _title,
      showGems: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: CartoonPanel(
          child: SingleChildScrollView(
            child: SelectableText(
              _body.trim(),
              style: AppText.label(15, color: AppColors.ink, weight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }
}
