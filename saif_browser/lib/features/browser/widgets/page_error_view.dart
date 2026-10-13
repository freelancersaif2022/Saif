import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../tabs/page_error.dart';

/// Full-page error shown instead of the WebView for main-frame failures.
class PageErrorView extends StatelessWidget {
  const PageErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onBack,
    this.onProceedInsecure,
    this.onOpenProxySettings,
    this.canGoBack = false,
  });

  final PageError error;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final VoidCallback? onProceedInsecure;
  final VoidCallback? onOpenProxySettings;
  final bool canGoBack;

  IconData get _icon => switch (error.kind) {
    PageErrorKind.offline => Icons.wifi_off_rounded,
    PageErrorKind.dns || PageErrorKind.connectionFailed || PageErrorKind.connectionRefused => Icons.cloud_off_rounded,
    PageErrorKind.timeout => Icons.hourglass_empty_rounded,
    PageErrorKind.ssl || PageErrorKind.insecure => Icons.gpp_bad_outlined,
    PageErrorKind.proxy => Icons.vpn_lock_outlined,
    PageErrorKind.crashed => Icons.sentiment_dissatisfied_outlined,
    PageErrorKind.blocked => Icons.block_rounded,
    PageErrorKind.invalidUrl || PageErrorKind.unsupportedScheme => Icons.link_off_rounded,
    _ => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final securityProblem = error.kind == PageErrorKind.ssl || error.kind == PageErrorKind.insecure;
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: securityProblem ? theme.colorScheme.error.withValues(alpha: 0.1) : palette.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      _icon,
                      size: 48,
                      color: securityProblem ? theme.colorScheme.error : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    error.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error.message,
                    style: theme.textTheme.bodyLarge?.copyWith(color: palette.textSecondary, height: 1.45),
                  ),
                  if (error.description != null && error.description!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      error.description!,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: palette.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ..._actions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    switch (error.kind) {
      case PageErrorKind.ssl:
        return [
          FilledButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(canGoBack ? 'Back to safety' : 'Close page'),
          ),
        ];
      case PageErrorKind.insecure:
        return [
          FilledButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Go back'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onProceedInsecure, child: const Text('Continue to site (not secure)')),
        ];
      case PageErrorKind.proxy:
        return [
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          if (onOpenProxySettings != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onOpenProxySettings,
              icon: const Icon(Icons.settings_ethernet_rounded),
              label: const Text('Proxy settings'),
            ),
          ],
        ];
      default:
        return [
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(error.kind == PageErrorKind.crashed ? 'Reload' : 'Retry'),
          ),
        ];
    }
  }
}
