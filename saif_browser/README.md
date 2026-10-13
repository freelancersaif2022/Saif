# Saif Browser

An Android web browser built with Flutter on top of **Android System WebView**, with a native Kotlin engine layer. White, minimal UI with a `#D1FE17` accent (black text and icons on accent surfaces). No ads, analytics, telemetry, remote config or cloud sync.

## Build

Requirements: Flutter 3.44+ (developed with 3.47.7 / Dart 3.13), Android SDK with platform 36, JDK 17+.

```bash
flutter pub get
dart format .
flutter analyze
flutter test                      # unit + widget tests (host)
flutter build apk --debug
flutter build apk --release       # uses android/key.properties if present, else the debug key
flutter test integration_test -d <device>      # end-to-end on a device/emulator
cd android && ./gradlew :app:testDebugUnitTest  # JVM tests for the Kotlin layer
cd android && ./gradlew :app:connectedDebugAndroidTest  # Keystore + profile isolation on a device
```

Release signing: create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, `keyPassword` (ignored by git).

## Architecture

```
lib/
  main.dart, app/            bootstrap (storage → engine → proxy → tabs), providers, theme wiring, deep links, FLAG_SECURE
  core/theme                 design tokens and Material 3 theme
  core/utils                 URL/search resolution, file names, user agents, formatters
  core/storage               SQLite schema/migrations (sqflite), atomic file writes
  engine/                    Dart API over the native engine (method channels) + WebView platform view
  features/browser           browser screen, address bar, toolbars, new tab page, error pages, menus, prompts
  features/tabs              tab model, TabsController (Riverpod), session persistence, tab grid
  features/bookmarks|history|shortcuts|permissions   repositories + screens
  features/downloads         DownloadManager + in-app proxied downloader, controller, screen
  features/passwords         Keystore-encrypted vault, device authentication, fill-on-request
  features/proxy             HTTP/HTTPS/SOCKS5 connector, local proxy server (background isolate), controller, UI
  features/settings          settings model/persistence and screens
android/app/src/main/kotlin/com/saif/browser/
  engine/                    BrowserEngine (channel), BrowserTab (WebView + clients), WebViewFactory,
                             FileChooserLauncher, ProfileSupport (private profiles), PendingRequests
  downloads/                 DownloadManager wrapper
  security/                  KeystoreCipher (AES-256-GCM, Android Keystore)
  system/                    SystemChannel (crypto, downloads, intents, share, SAF), ActivityHost
test/                        102 Dart tests; android/app/src/test + androidTest for Kotlin
integration_test/            on-device browsing tests
```

Key design points:

* **One native WebView per tab**, owned by the Kotlin tab registry, embedded through a platform view. Switching tabs never reloads a page. At most 4 background WebViews stay alive; older ones are suspended (`saveState` kept in memory, WebView destroyed) and restored on demand. Background renderers get `RENDERER_PRIORITY_WAIVED`.
* **Loading UI is driven only by WebView callbacks** (`onPageStarted`, `onProgressChanged`, `onPageFinished`, `doUpdateVisitedHistory`, errors).
* **Errors** come from real `onReceivedError` / `onReceivedSslError` / HTTP status data. "No Internet Connection" is shown only for `ERR_INTERNET_DISCONNECTED` or when Android reports no network; DNS, timeout, refused, SSL, redirect, proxy and renderer-crash pages are distinct. HTTP 404/500 pages are shown as the site sent them.
* **Storage**: SQLite (transactions, integrity check, corrupt-file recovery), settings as one JSON key, tab session via atomic temp-file rename. Android backup and device transfer are disabled for all app data.

## Feature status

Verified by automated tests on the host (Linux):

| Area | What is tested |
| --- | --- |
| URL / search | address vs. search detection, https default, local IPs, custom engines, encoding |
| Tabs | create, navigate, back/forward/reload/stop, switch, duplicate, reorder, close, reopen closed, popups, suspension budget, renderer crash recovery, back-button behaviour |
| Session | regular tabs restored after restart, private tabs never restored, restore toggle |
| History / bookmarks | persistence across DB reopen, merge window, search, delete, clear by range, folders, reorder, move |
| Passwords | only ciphertext stored, ciphertext bound to origin+username, edit re-encrypts |
| Private browsing | no history, session end calls profile deletion, regular cookies untouched, private download entries forgotten |
| Downloads | DownloadManager polling, progress, failure reasons, cancel/retry/delete, duplicate names, data:/blob: files, resume via Range, proxied downloads, "ask where to save" |
| Proxy | real sockets: HTTP CONNECT + Basic auth, SOCKS5 + RFC 1929 auth, remote DNS, auth failures, unreachable proxy, TLS-handshake timeout, local relay for HTTP and CONNECT, proxy-only blocking with no direct fallback, controller states (Connected/Connecting/Failed/Disconnected) |
| Settings | persistence, corrupted values, reset, derived WebView settings / user agents |
| UI | offline page (title, text, accent Retry with black label), SSL page without bypass, browser shell flow |
| Kotlin (JVM) | settings parsing, origin binding (6 tests, run with JUnit) |

Written but **not run here** (no Android device/emulator or Android SDK was available in the build environment):
`integration_test/browser_flow_test.dart` (real sites), `KeystoreCipherTest`, `ProfileIsolationTest`.

## Platform limitations (Android System WebView)

* **Not Chrome**: rendering and web-platform support depend on the installed Android System WebView version. No Chrome extensions, sync, or Chrome-only APIs. Web push notifications are not supported by WebView.
* **Private tabs** use a separate WebView profile (`MULTI_PROFILE`, WebView ≈ 123+), which isolates cookies, storage, cache and service workers; the profile is wiped and deleted when the last private tab closes, and leftovers are removed at next launch. On older WebViews private tabs **share cookies/storage with regular tabs**; the app detects this and says so on the private tab page. Private browsing does not make you anonymous to websites, networks or ISPs.
* **Passwords**: the app does not capture passwords from page forms (that would need an untrusted JavaScript bridge). Users save logins explicitly ("⋮ → Passwords for this site" or the password manager), and filling happens only on an explicit tap, after device authentication, and only if the page's top-level origin equals the saved origin. Android's system Autofill framework (e.g. Google Password Manager) keeps working in regular tabs and is disabled for private tabs. The Keystore key is not user-authentication-bound (the `local_auth` plugin has no CryptoObject support); access is gated by app-level biometric/screen-lock checks.
* **Proxy**: WebView cannot do SOCKS5 or proxy authentication on its own, so the app runs a loopback-only relay (127.0.0.1, ephemeral port, background isolate) and uses `ProxyController` (`PROXY_OVERRIDE`) to send all WebView traffic to it. Requires a WebView with `PROXY_OVERRIDE`. WebRTC media may use UDP outside the proxy. Other apps on the device could technically connect to the loopback relay while it runs (the port is random and unadvertised). Downloads use the in-app downloader through the relay while a proxy is active (they stop if the app is killed and can be resumed with Retry); without a proxy, Android's DownloadManager is used.
* **Downloads**: `blob:` URLs are read from the page (≤ 50 MB); DRM-protected media and streaming video cannot be downloaded. PDFs are downloaded and opened with an external viewer because WebView has no PDF renderer.
* **Tab restore** after an app restart restores each tab's current URL, not its back/forward history (WebView state bundles are only kept in memory).
* **Safe Browsing** (on by default, toggle in Settings) is Google's WebView service and contacts Google. WebView usage-metrics upload is opted out in the manifest.

## Remaining issues / not verified

* No APK was produced in the development environment: the Android SDK and Google Maven (`dl.google.com`) were blocked by its network policy. The Kotlin sources were type-checked with `kotlinc` against `android.jar` (API 36), the Flutter embedding and API-accurate stubs for androidx.webkit/core/test, but a full Gradle build has not run yet.
* No on-device testing has been done: WebView behaviour (file pickers, camera, WebRTC prompts, fullscreen video, DownloadManager, proxy override, profile isolation, biometric prompts) must be verified on real hardware with the integration and instrumented tests above.
