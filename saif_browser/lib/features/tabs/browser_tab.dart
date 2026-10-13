import 'package:flutter/foundation.dart';

import '../../core/utils/url_resolver.dart';
import 'page_error.dart';

/// UI state of one tab. The native WebView is owned by the engine.
@immutable
class BrowserTab {
  const BrowserTab({
    required this.id,
    required this.incognito,
    this.url = UrlResolver.newTabUrl,
    this.title = '',
    this.favicon,
    this.progress = 0,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.error,
    this.showNtp = true,
    this.desktopMode = false,
    this.textZoom,
    this.thumbnail,
    this.parentId,
    this.nativeCreated = false,
    this.lastActive = 0,
    this.httpStatus,
    this.surfaceGeneration = 0,
    this.hasNtpEntry = false,
  });

  final String id;
  final bool incognito;
  final String url;
  final String title;
  final Uint8List? favicon;

  /// 0..1 from WebView progress callbacks.
  final double progress;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final PageError? error;

  /// The Flutter new tab page is displayed instead of the WebView.
  final bool showNtp;
  final bool desktopMode;

  /// Per-tab text zoom override in percent.
  final int? textZoom;
  final Uint8List? thumbnail;

  /// Tab that opened this one (popups); back closes the popup.
  final String? parentId;

  /// The native side knows this tab (WebView may still be suspended).
  final bool nativeCreated;
  final int lastActive;

  /// Last main-frame HTTP error status (4xx/5xx), shown in site info.
  final int? httpStatus;

  /// Changes when the native WebView was recreated and must be re-embedded.
  final int surfaceGeneration;

  /// The tab started on the new tab page, so back from the first page returns there.
  final bool hasNtpEntry;

  bool get isNewTab => showNtp;
  bool get isSecure => !showNtp && UrlResolver.isSecure(url);
  String get displayTitle {
    if (showNtp) return incognito ? 'Private tab' : 'New tab';
    if (title.isNotEmpty) return title;
    return UrlResolver.displayText(url);
  }

  BrowserTab copyWith({
    String? url,
    String? title,
    Uint8List? favicon,
    bool clearFavicon = false,
    double? progress,
    bool? isLoading,
    bool? canGoBack,
    bool? canGoForward,
    PageError? error,
    bool clearError = false,
    bool? showNtp,
    bool? desktopMode,
    int? textZoom,
    bool clearTextZoom = false,
    Uint8List? thumbnail,
    bool? nativeCreated,
    int? lastActive,
    int? httpStatus,
    bool clearHttpStatus = false,
    int? surfaceGeneration,
  }) {
    return BrowserTab(
      id: id,
      incognito: incognito,
      url: url ?? this.url,
      title: title ?? this.title,
      favicon: clearFavicon ? null : (favicon ?? this.favicon),
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      error: clearError ? null : (error ?? this.error),
      showNtp: showNtp ?? this.showNtp,
      desktopMode: desktopMode ?? this.desktopMode,
      textZoom: clearTextZoom ? null : (textZoom ?? this.textZoom),
      thumbnail: thumbnail ?? this.thumbnail,
      parentId: parentId,
      nativeCreated: nativeCreated ?? this.nativeCreated,
      lastActive: lastActive ?? this.lastActive,
      httpStatus: clearHttpStatus ? null : (httpStatus ?? this.httpStatus),
      surfaceGeneration: surfaceGeneration ?? this.surfaceGeneration,
      hasNtpEntry: hasNtpEntry,
    );
  }
}

/// A closed regular tab that can be reopened.
@immutable
class ClosedTab {
  const ClosedTab({required this.url, required this.title, required this.index});

  final String url;
  final String title;
  final int index;

  Map<String, Object?> toJson() => {'url': url, 'title': title, 'index': index};

  static ClosedTab? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final url = json['url'];
    if (url is! String) return null;
    return ClosedTab(url: url, title: json['title'] as String? ?? '', index: json['index'] as int? ?? 0);
  }
}

@immutable
class TabsState {
  const TabsState({
    this.regular = const [],
    this.private = const [],
    this.activeRegularId,
    this.activePrivateId,
    this.privateMode = false,
    this.recentlyClosed = const [],
  });

  final List<BrowserTab> regular;
  final List<BrowserTab> private;
  final String? activeRegularId;
  final String? activePrivateId;

  /// The private tab set is the one being shown.
  final bool privateMode;
  final List<ClosedTab> recentlyClosed;

  List<BrowserTab> get visibleTabs => privateMode ? private : regular;
  String? get activeId => privateMode ? activePrivateId : activeRegularId;

  BrowserTab? get active {
    final id = activeId;
    if (id == null) return null;
    for (final t in visibleTabs) {
      if (t.id == id) return t;
    }
    return null;
  }

  BrowserTab? byId(String id) {
    for (final t in regular) {
      if (t.id == id) return t;
    }
    for (final t in private) {
      if (t.id == id) return t;
    }
    return null;
  }

  Iterable<BrowserTab> get all => regular.followedBy(private);

  TabsState copyWith({
    List<BrowserTab>? regular,
    List<BrowserTab>? private,
    String? activeRegularId,
    bool clearActiveRegular = false,
    String? activePrivateId,
    bool clearActivePrivate = false,
    bool? privateMode,
    List<ClosedTab>? recentlyClosed,
  }) {
    return TabsState(
      regular: regular ?? this.regular,
      private: private ?? this.private,
      activeRegularId: clearActiveRegular ? null : (activeRegularId ?? this.activeRegularId),
      activePrivateId: clearActivePrivate ? null : (activePrivateId ?? this.activePrivateId),
      privateMode: privateMode ?? this.privateMode,
      recentlyClosed: recentlyClosed ?? this.recentlyClosed,
    );
  }
}
