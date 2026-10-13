import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Shows a tab's native WebView. The WebView itself lives in the native tab
/// registry, so rebuilding or replacing this widget does not reload the page.
class WebViewSurface extends StatelessWidget {
  const WebViewSurface({super.key, required this.tabId});

  static const viewType = 'saif/webview';

  final String tabId;

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      key: ValueKey('webview-$tabId'),
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: <String, Object?>{'tabId': tabId},
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        controller.addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        controller.create();
        return controller;
      },
    );
  }
}
