import 'live_link.dart';

const bool supported = false;

Future<LiveHost> host() => Future.error(UnsupportedError('Live battles need the Android app.'));

Future<LiveLink> join(List<String> addresses, int port) => Future.error(UnsupportedError('Live battles need the Android app.'));
