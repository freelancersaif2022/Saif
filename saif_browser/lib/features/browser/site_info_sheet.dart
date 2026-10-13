import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_resolver.dart';
import '../permissions/site_permission_repository.dart';
import '../proxy/proxy_controller.dart';
import '../proxy/proxy_models.dart';
import '../tabs/browser_tab.dart';
import '../tabs/page_error.dart';

/// Connection security, proxy route and remembered permissions for the page.
Future<void> showSiteInfoSheet(BuildContext context, WidgetRef ref, BrowserTab tab) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SiteInfo(tab: tab),
  );
}

class _SiteInfo extends ConsumerStatefulWidget {
  const _SiteInfo({required this.tab});

  final BrowserTab tab;

  @override
  ConsumerState<_SiteInfo> createState() => _SiteInfoState();
}

class _SiteInfoState extends ConsumerState<_SiteInfo> {
  List<SitePermissionEntry> _permissions = const [];

  String? get _origin => UrlResolver.originOf(widget.tab.url);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final origin = _origin;
    if (origin == null || widget.tab.incognito) return;
    final all = await ref.read(sitePermissionRepositoryProvider).all();
    if (mounted) setState(() => _permissions = all.where((p) => p.origin == origin).toList());
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final palette = context.palette;
    final error = Theme.of(context).colorScheme.error;
    final sslError = tab.error?.kind == PageErrorKind.ssl;
    final secure = tab.isSecure && !sslError;
    final proxy = ref.watch(proxyControllerProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UrlResolver.hostOf(tab.url) ?? tab.url,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            SelectableText(tab.url, maxLines: 2, style: TextStyle(color: palette.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            _row(
              secure ? Icons.lock_outline_rounded : Icons.no_encryption_gmailerrorred_outlined,
              secure ? 'Connection is secure' : 'Connection is not secure',
              secure
                  ? 'Information you send to this site (like passwords) is encrypted with HTTPS.'
                  : sslError
                  ? 'The site’s certificate is not valid. The page was blocked.'
                  : 'This site does not use HTTPS. Avoid entering passwords or payment details.',
              color: secure ? null : error,
            ),
            if (tab.httpStatus != null)
              _row(Icons.report_gmailerrorred_outlined, 'Server responded with HTTP ${tab.httpStatus}', null),
            if (proxy.state == ProxyConnectionState.connected)
              _row(
                Icons.vpn_lock_outlined,
                'Through proxy “${proxy.profileName}”',
                'Browser traffic is routed through your proxy.',
              ),
            if (tab.incognito)
              _row(Icons.visibility_off_outlined, 'Private tab', 'This visit is not saved to history.'),
            if (_permissions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Permissions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              for (final p in _permissions)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.permission.label),
                  value: p.decision == PermissionDecision.allow,
                  onChanged: (allow) async {
                    await ref
                        .read(sitePermissionRepositoryProvider)
                        .set(p.origin, p.permission, allow ? PermissionDecision.allow : PermissionDecision.block);
                    await _load();
                  },
                ),
              TextButton(
                onPressed: () async {
                  for (final p in _permissions) {
                    await ref.read(sitePermissionRepositoryProvider).remove(p.origin, p.permission);
                  }
                  await _load();
                },
                child: const Text('Reset permissions'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: tab.url));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy link'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String? subtitle, {Color? color}) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
    subtitle: subtitle == null ? null : Text(subtitle),
  );
}
