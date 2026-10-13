import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/search_engines.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../shared/widgets/section_header.dart';
import '../downloads/downloads_screen.dart';
import '../passwords/passwords_screen.dart';
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
    final controller = ref.read(settingsProvider.notifier);
    void set(BrowserSettings Function(BrowserSettings) change) => controller.update(change);
    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(switch (s.themeMode) {
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
              ThemeMode.system => 'System default',
            }),
            onTap: () async {
              final mode = await _choose<ThemeMode>(context, 'Theme', {
                ThemeMode.light: 'Light',
                ThemeMode.dark: 'Dark',
                ThemeMode.system: 'System default',
              }, s.themeMode);
              if (mode != null) set((c) => c.copyWith(themeMode: mode));
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme color'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entry in AppColors.accentChoices.entries)
                    Semantics(
                      selected: s.accent == entry.key,
                      label: '${entry.key} color',
                      button: true,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => set((c) => c.copyWith(accent: entry.key)),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: s.accent == entry.key
                                  ? Theme.of(context).colorScheme.onSurface
                                  : context.palette.border,
                              width: s.accent == entry.key ? 2.5 : 1,
                            ),
                          ),
                          child: s.accent == entry.key
                              ? const Icon(Icons.check_rounded, color: Colors.black, size: 20)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vertical_align_bottom_rounded),
            title: const Text('Address bar position'),
            subtitle: Text(s.toolbarPosition == ToolbarPosition.top ? 'Top' : 'Bottom'),
            onTap: () async {
              final p = await _choose<ToolbarPosition>(context, 'Address bar position', {
                ToolbarPosition.top: 'Top',
                ToolbarPosition.bottom: 'Bottom',
              }, s.toolbarPosition);
              if (p != null) set((c) => c.copyWith(toolbarPosition: p));
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Text size'),
            subtitle: Text('${s.textZoom}% · applies to web pages'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Slider(
              value: s.textZoom.toDouble(),
              min: 50,
              max: 200,
              divisions: 15,
              label: '${s.textZoom}%',
              onChanged: (v) => set((c) => c.copyWith(textZoom: v.round())),
            ),
          ),

          const SectionHeader('Browsing'),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text('Search engine'),
            subtitle: Text(s.engine.name),
            onTap: () => _chooseSearchEngine(context, ref, s),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Homepage'),
            subtitle: Text(s.homepage.isEmpty ? 'New tab page' : s.homepage),
            onTap: () => _editHomepage(context, ref, s),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.code_rounded),
            title: const Text('JavaScript'),
            subtitle: const Text('Most websites need JavaScript to work'),
            value: s.javaScriptEnabled,
            onChanged: (v) => set((c) => c.copyWith(javaScriptEnabled: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.desktop_windows_outlined),
            title: const Text('Request desktop sites'),
            subtitle: const Text('For new tabs'),
            value: s.desktopModeDefault,
            onChanged: (v) => set((c) => c.copyWith(desktopModeDefault: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.open_in_new_off_rounded),
            title: const Text('Block pop-ups'),
            subtitle: const Text('Windows opened without a tap are blocked'),
            value: s.blockPopups,
            onChanged: (v) => set((c) => c.copyWith(blockPopups: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cookie_outlined),
            title: const Text('Allow cookies'),
            value: s.acceptCookies,
            onChanged: (v) => set((c) => c.copyWith(acceptCookies: v)),
          ),
          SwitchListTile(
            secondary: const SizedBox(width: 24),
            title: const Text('Allow third-party cookies'),
            subtitle: const Text('Lets embedded content from other sites set cookies'),
            value: s.thirdPartyCookies && s.acceptCookies,
            onChanged: s.acceptCookies ? (v) => set((c) => c.copyWith(thirdPartyCookies: v)) : null,
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('User agent'),
            subtitle: Text(
              switch (s.userAgentMode) {
                UserAgentMode.chrome => 'Chrome compatible (recommended)',
                UserAgentMode.webview => 'Android WebView default',
                UserAgentMode.custom => s.customUserAgent.isEmpty ? 'Custom' : s.customUserAgent,
              },
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _chooseUserAgent(context, ref, s),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.restore_rounded),
            title: const Text('Restore tabs on start'),
            value: s.restoreTabs,
            onChanged: (v) => set((c) => c.copyWith(restoreTabs: v)),
          ),

          const SectionHeader('Privacy'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear browsing data'),
            subtitle: const Text('History, cookies, site data, cache, passwords'),
            onTap: () => push(const ClearDataScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Site permissions'),
            subtitle: const Text('Camera, microphone, location'),
            onTap: () => push(const SiteSettingsScreen()),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.screenshot_monitor_outlined),
            title: const Text('Block screenshots of private tabs'),
            subtitle: const Text('Also hides private tabs in the recent apps screen'),
            value: s.blockPrivateScreenshots,
            onChanged: (v) => set((c) => c.copyWith(blockPrivateScreenshots: v)),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: const Text('Private browsing'),
            subtitle: Text(
              ref.read(engineInfoProvider).multiProfile
                  ? 'Private tabs use an isolated WebView profile that is deleted when they close'
                  : 'This WebView can’t isolate private storage; private tabs only skip history',
            ),
          ),

          const SectionHeader('Downloads'),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Download location'),
            subtitle: Text(
              s.downloadLocation == DownloadLocation.downloads
                  ? 'Downloads folder'
                  : 'Ask where to save each file after downloading',
            ),
            onTap: () async {
              final loc = await _choose<DownloadLocation>(context, 'Download location', {
                DownloadLocation.downloads: 'Downloads folder',
                DownloadLocation.ask: 'Ask where to save each file',
              }, s.downloadLocation);
              if (loc != null) set((c) => c.copyWith(downloadLocation: loc));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.help_outline_rounded),
            title: const Text('Ask before downloading'),
            value: s.askBeforeDownload,
            onChanged: (v) => set((c) => c.copyWith(askBeforeDownload: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.file_open_outlined),
            title: const Text('Open files when downloaded'),
            value: s.openWhenComplete,
            onChanged: (v) => set((c) => c.copyWith(openWhenComplete: v)),
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Download history'),
            onTap: () => push(const DownloadsScreen()),
          ),

          const SectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.password_rounded),
            title: const Text('Password manager'),
            onTap: () => push(const PasswordsScreen()),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: const Text('Require screen lock for passwords'),
            subtitle: const Text('Biometrics, PIN, pattern or password'),
            value: s.requireAuthForPasswords,
            onChanged: (v) => set((c) => c.copyWith(requireAuthForPasswords: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.https_outlined),
            title: const Text('Warn before insecure sites'),
            subtitle: const Text('Ask before opening http:// pages'),
            value: s.httpsFirst,
            onChanged: (v) => set((c) => c.copyWith(httpsFirst: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.shield_outlined),
            title: const Text('Safe Browsing'),
            subtitle: const Text('Android WebView checks pages against Google’s list of dangerous sites'),
            value: s.safeBrowsing,
            onChanged: (v) => set((c) => c.copyWith(safeBrowsing: v)),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_lock_outlined),
            title: const Text('Proxy'),
            onTap: () => push(const ProxyScreen()),
          ),

          const SectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About Saif Browser'),
            subtitle: Text('Version ${ref.read(engineInfoProvider).appVersion ?? '1.0.0'}'),
            onTap: () => _about(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.settings_backup_restore_rounded, color: Theme.of(context).colorScheme.error),
            title: Text('Reset settings', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: const Text('Bookmarks, history and passwords are kept'),
            onTap: () async {
              if (await confirm(context, title: 'Reset all settings?', confirmLabel: 'Reset', destructive: true)) {
                await controller.reset();
                if (context.mounted) showMessage(context, 'Settings reset');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<T?> _choose<T>(BuildContext context, String title, Map<T, String> options, T current) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<T>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [for (final e in options.entries) RadioListTile<T>(value: e.key, title: Text(e.value))],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseSearchEngine(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final options = {for (final e in SearchEngine.builtIn) e.id: e.name, 'custom': 'Custom…'};
    final id = await _choose<String>(context, 'Search engine', options, s.searchEngine);
    if (id == null || !context.mounted) return;
    if (id != 'custom') {
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(searchEngine: id));
      return;
    }
    final template = await _textPrompt(
      context,
      title: 'Custom search engine',
      label: 'URL with %s in place of the query',
      initial: s.customSearchTemplate.isEmpty ? 'https://' : s.customSearchTemplate,
      validator: (v) => SearchEngine.isValidTemplate(v) ? null : 'Use an https:// URL containing %s',
    );
    if (template != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((c) => c.copyWith(searchEngine: 'custom', customSearchTemplate: template.trim()));
    }
  }

  Future<void> _editHomepage(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final value = await _textPrompt(
      context,
      title: 'Homepage',
      label: 'Leave empty for the new tab page',
      initial: s.homepage,
      validator: (v) => v.trim().isEmpty || UrlResolver.toUrl(v) != null ? null : 'Enter a valid web address',
    );
    if (value != null) {
      final url = value.trim().isEmpty ? '' : UrlResolver.toUrl(value)!;
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(homepage: url));
    }
  }

  Future<void> _chooseUserAgent(BuildContext context, WidgetRef ref, BrowserSettings s) async {
    final mode = await _choose<UserAgentMode>(context, 'User agent', {
      UserAgentMode.chrome: 'Chrome compatible (recommended)',
      UserAgentMode.webview: 'Android WebView default',
      UserAgentMode.custom: 'Custom…',
    }, s.userAgentMode);
    if (mode == null || !context.mounted) return;
    if (mode != UserAgentMode.custom) {
      await ref.read(settingsProvider.notifier).update((c) => c.copyWith(userAgentMode: mode));
      return;
    }
    final ua = await _textPrompt(
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

  Future<String?> _textPrompt(
    BuildContext context, {
    required String title,
    required String label,
    required String initial,
    required String? Function(String) validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _TextPrompt(title: title, label: label, initial: initial, validator: validator),
    );
  }

  void _about(BuildContext context, WidgetRef ref) {
    final info = ref.read(engineInfoProvider);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const BrandMark(size: 52),
        title: const Text('Saif Browser'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${info.appVersion ?? '1.0.0'}'),
            const SizedBox(height: 6),
            Text('Engine: Android System WebView ${info.webViewVersion ?? 'unknown'}'),
            Text('Private tab isolation: ${info.multiProfile ? 'supported' : 'not supported by this WebView'}'),
            Text('Proxy routing: ${info.proxyOverride ? 'supported' : 'not supported by this WebView'}'),
            const SizedBox(height: 12),
            const Text(
              'No ads, analytics, telemetry or cloud sync. Bookmarks, history, passwords and settings stay on '
              'this device and are excluded from Android backups.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => showLicensePage(context: context, applicationName: 'Saif Browser'),
            child: const Text('Licenses'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({required this.title, required this.label, required this.initial, required this.validator});

  final String title;
  final String label;
  final String initial;
  final String? Function(String) validator;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(helperText: widget.label, errorText: _error, helperMaxLines: 2),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
