import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/search_engines.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/widgets/brand_mark.dart';
import '../downloads/downloads_screen.dart';
import '../passwords/passwords_screen.dart';
import '../proxy/proxy_controller.dart';
import '../proxy/proxy_models.dart';
import '../proxy/proxy_screen.dart';
import 'browser_settings.dart';
import 'clear_data_screen.dart';
import 'settings_controller.dart';
import 'site_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final info = ref.read(engineInfoProvider);
    final proxy = ref.watch(proxyControllerProvider);
    final controller = ref.read(settingsProvider.notifier);
    void set(BrowserSettings Function(BrowserSettings) change) => controller.update(change);
    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final followSystem = s.themeMode == ThemeMode.system;
    final darkOn = s.themeMode == ThemeMode.dark || (followSystem && platformDark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _HeaderCard(version: info.appVersion ?? '1.0.0', onTap: () => showAboutSheet(context, ref)),
          _Section(
            title: 'Appearance',
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                subtitle: followSystem ? 'Following your device' : (darkOn ? 'On' : 'Off'),
                value: darkOn,
                onChanged: followSystem
                    ? null
                    : (v) => set((c) => c.copyWith(themeMode: v ? ThemeMode.dark : ThemeMode.light)),
              ),
              _SwitchTile(
                icon: Icons.brightness_auto_rounded,
                title: 'Match device theme',
                subtitle: 'Switch between light and dark automatically',
                value: followSystem,
                onChanged: (v) => set(
                  (c) =>
                      c.copyWith(themeMode: v ? ThemeMode.system : (platformDark ? ThemeMode.dark : ThemeMode.light)),
                ),
              ),
              _ColorPicker(
                selected: s.accent,
                onSelected: (key) => set((c) => c.copyWith(accent: key)),
              ),
              _Tile(
                icon: Icons.vertical_split_rounded,
                title: 'Address bar',
                trailing: SegmentedButton<ToolbarPosition>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  segments: const [
                    ButtonSegment(value: ToolbarPosition.top, label: Text('Top')),
                    ButtonSegment(value: ToolbarPosition.bottom, label: Text('Bottom')),
                  ],
                  selected: {s.toolbarPosition},
                  onSelectionChanged: (v) => set((c) => c.copyWith(toolbarPosition: v.first)),
                ),
              ),
              _SliderTile(
                icon: Icons.format_size_rounded,
                title: 'Page text size',
                value: s.textZoom,
                onChanged: (v) => set((c) => c.copyWith(textZoom: v)),
              ),
            ],
          ),
          _Section(
            title: 'Search & browsing',
            children: [
              _Tile(
                icon: Icons.search_rounded,
                title: 'Search engine',
                subtitle: s.engine.name,
                onTap: () => _chooseSearchEngine(context, ref, s),
              ),
              _SwitchTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Search suggestions',
                subtitle: 'Show suggestions from ${s.engine.name} as you type',
                value: s.searchSuggestions,
                onChanged: (v) => set((c) => c.copyWith(searchSuggestions: v)),
              ),
              _Tile(
                icon: Icons.home_rounded,
                title: 'Homepage',
                subtitle: s.homepage.isEmpty ? 'New tab page' : s.homepage,
                onTap: () => _editHomepage(context, ref, s),
              ),
              _SwitchTile(
                icon: Icons.code_rounded,
                title: 'JavaScript',
                subtitle: 'Most websites need JavaScript',
                value: s.javaScriptEnabled,
                onChanged: (v) => set((c) => c.copyWith(javaScriptEnabled: v)),
              ),
              _SwitchTile(
                icon: Icons.desktop_windows_rounded,
                title: 'Desktop sites by default',
                subtitle: 'Applies to new tabs',
                value: s.desktopModeDefault,
                onChanged: (v) => set((c) => c.copyWith(desktopModeDefault: v)),
              ),
              _SwitchTile(
                icon: Icons.web_asset_off_rounded,
                title: 'Block pop-ups',
                subtitle: 'Windows opened without a tap are blocked',
                value: s.blockPopups,
                onChanged: (v) => set((c) => c.copyWith(blockPopups: v)),
              ),
              _SwitchTile(
                icon: Icons.cookie_rounded,
                title: 'Allow cookies',
                value: s.acceptCookies,
                onChanged: (v) => set((c) => c.copyWith(acceptCookies: v)),
              ),
              _SwitchTile(
                icon: Icons.cookie_outlined,
                title: 'Third-party cookies',
                subtitle: 'Let embedded content from other sites set cookies',
                value: s.thirdPartyCookies && s.acceptCookies,
                onChanged: s.acceptCookies ? (v) => set((c) => c.copyWith(thirdPartyCookies: v)) : null,
              ),
              _Tile(
                icon: Icons.badge_rounded,
                title: 'User agent',
                subtitle: switch (s.userAgentMode) {
                  UserAgentMode.chrome => 'Chrome compatible (recommended)',
                  UserAgentMode.webview => 'Android WebView default',
                  UserAgentMode.custom => s.customUserAgent.isEmpty ? 'Custom' : s.customUserAgent,
                },
                onTap: () => _chooseUserAgent(context, ref, s),
              ),
              _SwitchTile(
                icon: Icons.restore_page_rounded,
                title: 'Reopen tabs on start',
                value: s.restoreTabs,
                onChanged: (v) => set((c) => c.copyWith(restoreTabs: v)),
              ),
            ],
          ),
          _Section(
            title: 'Privacy',
            children: [
              _Tile(
                icon: Icons.delete_sweep_rounded,
                title: 'Clear browsing data',
                subtitle: 'History, cookies, cache, passwords',
                onTap: () => push(const ClearDataScreen()),
              ),
              _Tile(
                icon: Icons.tune_rounded,
                title: 'Site permissions',
                subtitle: 'Camera, microphone, location',
                onTap: () => push(const SiteSettingsScreen()),
              ),
              _SwitchTile(
                icon: Icons.screenshot_monitor_rounded,
                title: 'Protect private tabs',
                subtitle: 'Block screenshots and hide them in recent apps',
                value: s.blockPrivateScreenshots,
                onChanged: (v) => set((c) => c.copyWith(blockPrivateScreenshots: v)),
              ),
              _Tile(
                icon: Icons.visibility_off_rounded,
                title: 'Private browsing',
                subtitle: info.multiProfile
                    ? 'Isolated storage, deleted when private tabs close'
                    : 'History is not saved (storage isolation needs a newer WebView)',
              ),
            ],
          ),
          _Section(
            title: 'Security',
            children: [
              _Tile(
                icon: Icons.password_rounded,
                title: 'Password manager',
                subtitle: 'Encrypted on this device',
                onTap: () => push(const PasswordsScreen()),
              ),
              _SwitchTile(
                icon: Icons.key_rounded,
                title: 'Offer to save passwords',
                subtitle: 'Ask after you sign in to a site or proxy',
                value: s.offerToSavePasswords,
                onChanged: (v) => set((c) => c.copyWith(offerToSavePasswords: v)),
              ),
              _SwitchTile(
                icon: Icons.fingerprint_rounded,
                title: 'Require screen lock',
                subtitle: 'Before showing or filling saved passwords',
                value: s.requireAuthForPasswords,
                onChanged: (v) => set((c) => c.copyWith(requireAuthForPasswords: v)),
              ),
              _SwitchTile(
                icon: Icons.https_rounded,
                title: 'Warn before insecure sites',
                subtitle: 'Ask before opening http:// pages',
                value: s.httpsFirst,
                onChanged: (v) => set((c) => c.copyWith(httpsFirst: v)),
              ),
              _SwitchTile(
                icon: Icons.shield_rounded,
                title: 'Safe Browsing',
                subtitle: 'Warn about dangerous sites (Google Safe Browsing)',
                value: s.safeBrowsing,
                onChanged: (v) => set((c) => c.copyWith(safeBrowsing: v)),
              ),
              _Tile(
                icon: Icons.vpn_lock_rounded,
                title: 'Proxy',
                subtitle: switch (proxy.state) {
                  ProxyConnectionState.connected => 'Connected · ${proxy.profileName}',
                  ProxyConnectionState.connecting => 'Connecting…',
                  ProxyConnectionState.failed => 'Connection failed',
                  ProxyConnectionState.disconnected => proxy.blockingDirect ? 'Proxy-only mode · blocked' : 'Off',
                },
                onTap: () => push(const ProxyScreen()),
              ),
            ],
          ),
          _Section(
            title: 'Downloads',
            children: [
              _Tile(
                icon: Icons.folder_rounded,
                title: 'Download location',
                subtitle: s.downloadLocation == DownloadLocation.downloads
                    ? 'Downloads folder'
                    : 'Ask where to save each file',
                onTap: () async {
                  final loc = await _chooseSheet<DownloadLocation>(
                    context,
                    title: 'Download location',
                    current: s.downloadLocation,
                    options: const {
                      DownloadLocation.downloads: ('Downloads folder', Icons.download_rounded),
                      DownloadLocation.ask: ('Ask where to save each file', Icons.drive_folder_upload_rounded),
                    },
                  );
                  if (loc != null) set((c) => c.copyWith(downloadLocation: loc));
                },
              ),
              _SwitchTile(
                icon: Icons.help_rounded,
                title: 'Ask before downloading',
                value: s.askBeforeDownload,
                onChanged: (v) => set((c) => c.copyWith(askBeforeDownload: v)),
              ),
              _SwitchTile(
                icon: Icons.file_open_rounded,
                title: 'Open files when finished',
                value: s.openWhenComplete,
                onChanged: (v) => set((c) => c.copyWith(openWhenComplete: v)),
              ),
              _Tile(icon: Icons.history_rounded, title: 'Download history', onTap: () => push(const DownloadsScreen())),
            ],
          ),
          _Section(
            title: 'About',
            children: [
              _Tile(
                icon: Icons.info_rounded,
                title: 'About Trex Browser',
                subtitle: 'Version ${info.appVersion ?? '1.0.0'} · T-rex Engine',
                onTap: () => showAboutSheet(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _chooseSearchEngine(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final id = await _chooseSheet<String>(
      context,
      title: 'Search engine',
      current: s.searchEngine,
      options: {
        for (final e in SearchEngine.builtIn) e.id: (e.name, Icons.search_rounded),
        'custom': ('Custom…', Icons.edit_rounded),
      },
    );
    if (id == null || !context.mounted) return;
    if (id != 'custom') {
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(searchEngine: id));
      return;
    }
    final template = await _textSheet(
      context,
      title: 'Custom search engine',
      label: 'Search URL',
      helper: 'Use %s where the search words go, e.g. https://example.com/?q=%s',
      initial: s.customSearchTemplate.isEmpty ? 'https://' : s.customSearchTemplate,
      validator: (v) => SearchEngine.isValidTemplate(v) ? null : 'Use an https:// address containing %s',
    );
    if (template != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((c) => c.copyWith(searchEngine: 'custom', customSearchTemplate: template.trim()));
    }
  }

  Future<void> _editHomepage(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final value = await _textSheet(
      context,
      title: 'Homepage',
      label: 'Web address',
      helper: 'Leave empty to open the new tab page',
      initial: s.homepage,
      validator: (v) => v.trim().isEmpty || UrlResolver.toUrl(v) != null ? null : 'Enter a valid web address',
    );
    if (value != null) {
      final url = value.trim().isEmpty ? '' : UrlResolver.toUrl(value)!;
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(homepage: url));
    }
  }

  Future<void> _chooseUserAgent(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final mode = await _chooseSheet<UserAgentMode>(
      context,
      title: 'User agent',
      current: s.userAgentMode,
      options: const {
        UserAgentMode.chrome: ('Chrome compatible (recommended)', Icons.verified_rounded),
        UserAgentMode.webview: ('Android WebView default', Icons.android_rounded),
        UserAgentMode.custom: ('Custom…', Icons.edit_rounded),
      },
    );
    if (mode == null || !context.mounted) return;
    if (mode != UserAgentMode.custom) {
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(userAgentMode: mode));
      return;
    }
    final ua = await _textSheet(
      context,
      title: 'Custom user agent',
      label: 'User-Agent header',
      initial: s.customUserAgent,
      validator: (v) => v.trim().length < 8 ? 'Enter a user agent string' : null,
    );
    if (ua != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((c) => c.copyWith(userAgentMode: UserAgentMode.custom, customUserAgent: ua.trim()));
    }
  }
}

/// "About Trex Browser" sheet.
Future<void> showAboutSheet(BuildContext context, WidgetRef ref) {
  final info = ref.read(engineInfoProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final palette = context.palette;
      Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label, style: TextStyle(color: palette.textSecondary)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      Widget promise(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 19, color: palette.onAccent),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
          ],
        ),
      );
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Center(child: BrandMark(size: 60)),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Trex Browser',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Center(
              child: Text(
                'Fast, private browsing powered by T-rex Engine',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  row('Version', info.appVersion ?? '1.0.0'),
                  row('Engine', 'T-rex Engine · Android System WebView ${info.webViewVersion ?? '—'}'),
                  row('Private isolation', info.multiProfile ? 'Supported' : 'Not supported by this WebView'),
                  row('Proxy routing', info.proxyOverride ? 'Supported' : 'Not supported by this WebView'),
                  row('Android', 'API level ${info.sdkInt}'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Our privacy promise',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            promise(Icons.block_rounded, 'No ads, analytics, tracking or telemetry.'),
            promise(Icons.phone_android_rounded, 'Bookmarks, history and settings stay on this device.'),
            promise(Icons.lock_rounded, 'Passwords are encrypted with a key kept in the Android Keystore.'),
            promise(Icons.cloud_off_rounded, 'Nothing is synced to a cloud or included in Android backups.'),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Trex Browser',
                applicationVersion: info.appVersion,
                applicationIcon: const Padding(padding: EdgeInsets.all(12), child: BrandMark(size: 40)),
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Open-source licenses'),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      );
    },
  );
}

Future<T?> _chooseSheet<T>(
  BuildContext context, {
  required String title,
  required T current,
  required Map<T, (String, IconData)> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      final palette = context.palette;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              for (final e in options.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: e.key == current ? palette.accent.withValues(alpha: 0.22) : palette.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: e.key == current ? palette.accent : Colors.transparent, width: 1.6),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Icon(e.value.$2),
                      title: Text(e.value.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: e.key == current ? const Icon(Icons.check_circle_rounded) : null,
                      onTap: () => Navigator.pop(context, e.key),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<String?> _textSheet(
  BuildContext context, {
  required String title,
  required String label,
  String? helper,
  required String initial,
  required String? Function(String) validator,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TextSheet(title: title, label: label, helper: helper, initial: initial, validator: validator),
  );
}

class _TextSheet extends StatefulWidget {
  const _TextSheet({
    required this.title,
    required this.label,
    this.helper,
    required this.initial,
    required this.validator,
  });

  final String title;
  final String label;
  final String? helper;
  final String initial;
  final String? Function(String) validator;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.validator(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: widget.label,
              helperText: widget.helper,
              helperMaxLines: 2,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(onPressed: _submit, child: const Text('Save')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.version, required this.onTap});

  final String version;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const BrandMark(size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trex Browser',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text('Version $version · T-rex Engine', style: TextStyle(color: palette.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: palette.textSecondary),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(20)),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 66, color: palette.border),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, size: 20, color: palette.onAccent),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: _IconBadge(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textSecondary),
            ),
      trailing: trailing ?? (onTap == null ? null : Icon(Icons.chevron_right_rounded, color: palette.textSecondary)),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SwitchListTile(
      contentPadding: const EdgeInsets.fromLTRB(14, 2, 10, 2),
      secondary: Opacity(opacity: onChanged == null ? 0.5 : 1, child: _IconBadge(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: palette.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({required this.icon, required this.title, required this.value, required this.onChanged});

  final IconData icon;
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              _IconBadge(icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
              ),
              Text(
                '$value%',
                style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            children: [
              Text('A', style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 50,
                  max: 200,
                  divisions: 15,
                  label: '$value%',
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              Text('A', style: TextStyle(fontSize: 20, color: palette.textSecondary)),
            ],
          ),
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(fontSize: 14 * value / 100, color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBadge(Icons.palette_rounded),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Theme color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
              ),
              Text(
                AppColors.labelFor(selected),
                style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in AppColors.accentChoices.entries)
                Semantics(
                  selected: selected == entry.key,
                  label: '${AppColors.labelFor(entry.key)} theme color',
                  button: true,
                  child: GestureDetector(
                    onTap: () => onSelected(entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected == entry.key ? Theme.of(context).colorScheme.onSurface : palette.border,
                          width: selected == entry.key ? 2.5 : 1,
                        ),
                        boxShadow: selected == entry.key
                            ? [BoxShadow(color: entry.value.withValues(alpha: 0.6), blurRadius: 10)]
                            : null,
                      ),
                      child: selected == entry.key
                          ? const Icon(Icons.check_rounded, color: Colors.black, size: 20)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
