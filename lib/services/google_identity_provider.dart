import 'package:google_sign_in/google_sign_in.dart';

import '../config/env.dart';

abstract interface class GoogleIdentityProvider {
  Future<String?> getIdToken();
}

class GoogleAuthConfigurationException implements Exception {
  const GoogleAuthConfigurationException();
}

class GoogleSignInIdentityProvider implements GoogleIdentityProvider {
  GoogleSignInIdentityProvider({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  static Future<void>? _initialization;

  @override
  Future<String?> getIdToken() async {
    final clientId = Env.googleServerClientId.trim();
    if (clientId.isEmpty) throw const GoogleAuthConfigurationException();

    _initialization ??= _googleSignIn.initialize(serverClientId: clientId);
    await _initialization;

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthConfigurationException();
    }

    final account = await _googleSignIn.authenticate();
    return account.authentication.idToken;
  }
}
