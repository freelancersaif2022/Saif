import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../settings/settings_controller.dart';

enum AuthOutcome { success, failed, unavailable }

/// Biometric / screen-lock check before showing or using saved passwords.
abstract class DeviceAuthenticator {
  Future<AuthOutcome> authenticate(String reason);
}

class LocalAuthAuthenticator implements DeviceAuthenticator {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    try {
      if (!await _auth.isDeviceSupported()) return AuthOutcome.unavailable;
      final ok = await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
      return ok ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled => AuthOutcome.unavailable,
        _ => AuthOutcome.failed,
      };
    } on PlatformException {
      return AuthOutcome.failed;
    }
  }
}

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>((ref) => LocalAuthAuthenticator());

final vaultLockProvider = Provider<VaultLock>((ref) => VaultLock(ref));

/// Remembers a successful unlock for a short time so one action does not
/// prompt repeatedly.
class VaultLock {
  VaultLock(this._ref);

  final Ref _ref;
  DateTime? _unlockedAt;
  static const validity = Duration(seconds: 60);

  void lock() => _unlockedAt = null;

  Future<AuthOutcome> unlock(String reason) async {
    if (!_ref.read(settingsProvider).requireAuthForPasswords) return AuthOutcome.success;
    final at = _unlockedAt;
    if (at != null && DateTime.now().difference(at) < validity) return AuthOutcome.success;
    final outcome = await _ref.read(deviceAuthenticatorProvider).authenticate(reason);
    if (outcome == AuthOutcome.success) _unlockedAt = DateTime.now();
    return outcome;
  }
}
