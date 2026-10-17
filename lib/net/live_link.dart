import 'dart:convert';

import 'live_link_stub.dart' if (dart.library.io) 'live_link_io.dart' as impl;

/// A direct phone-to-phone connection for live battles (same Wi-Fi network or
/// one phone's hotspot). No server: one phone hosts, the other scans its QR.
abstract class LiveLink {
  Stream<Map<String, dynamic>> get messages;
  void send(Map<String, dynamic> msg);
  Future<void> close();
}

/// A hosted game waiting for the friend to connect.
abstract class LiveHost {
  List<String> get addresses;
  int get port;
  Future<LiveLink> waitForGuest();
  Future<void> close();
}

class LiveNet {
  LiveNet._();
  static bool get supported => impl.supported;
  static Future<LiveHost> host() => impl.host();
  static Future<LiveLink> join(List<String> addresses, int port) => impl.join(addresses, port);
}

/// What the host's QR code carries.
class LiveInvite {
  LiveInvite({required this.addresses, required this.port, required this.monsterCode, required this.nonce});
  final List<String> addresses;
  final int port;
  final String monsterCode;
  final String nonce;

  static const _prefix = 'VBL1.';

  String encode() => _prefix + base64Url.encode(utf8.encode(jsonEncode({'a': addresses, 'p': port, 'm': monsterCode, 'n': nonce}))).replaceAll('=', '');

  static bool looksLike(String raw) => raw.contains(_prefix);

  static LiveInvite? decode(String raw) {
    try {
      final i = raw.indexOf(_prefix);
      if (i < 0) return null;
      var b64 = raw.substring(i + _prefix.length).trim().split(RegExp(r'\s'))[0];
      while (b64.length % 4 != 0) {
        b64 += '=';
      }
      final j = jsonDecode(utf8.decode(base64Url.decode(b64))) as Map<String, dynamic>;
      return LiveInvite(addresses: (j['a'] as List).cast<String>(), port: (j['p'] as num).toInt(), monsterCode: j['m'] as String, nonce: j['n'] as String);
    } catch (_) {
      return null;
    }
  }
}
