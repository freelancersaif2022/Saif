import 'dart:convert';
import 'dart:typed_data';

import '../../engine/system_bridge.dart';

/// Encrypts secrets with the Android Keystore AES-GCM key.
abstract class VaultCipher {
  Future<Uint8List> encrypt(String plain, String associatedData);
  Future<String> decrypt(Uint8List blob, String associatedData);
}

class KeystoreVaultCipher implements VaultCipher {
  KeystoreVaultCipher(this._system);

  final SystemBridge _system;

  @override
  Future<Uint8List> encrypt(String plain, String associatedData) =>
      _system.encrypt(Uint8List.fromList(utf8.encode(plain)), associatedData);

  @override
  Future<String> decrypt(Uint8List blob, String associatedData) async =>
      utf8.decode(await _system.decrypt(blob, associatedData));
}
