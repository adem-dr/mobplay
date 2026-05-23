import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:audioplayers/audioplayers.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric availability error: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _auth.authenticate(
        localizedReason: 'Veuillez utiliser votre empreinte pour déverrouiller.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Play success sound if needed
      }
      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }
}
