import 'package:local_auth/local_auth.dart';

Future<bool> checkBiometric() async {
  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = false;
  try {
    canCheckBiometrics = await auth.canCheckBiometrics;
  } catch (e) {
    print("error biometrics $e");
  }
  print("biometric is available: $canCheckBiometrics");
  List<BiometricType> availableBiometrics;
  try {
    availableBiometrics = await auth.getAvailableBiometrics();
  } catch (e) {
    print("error enumerate biometrics $e");
  }
  print("following biometrics are available");
  if (availableBiometrics.isNotEmpty) {
    availableBiometrics.forEach((ab) {
      print("\ttech: $ab");
    });
  } else {
    print("no biometrics are available");
  }

  bool authenticated = false;

  try {
    authenticated = await auth.authenticateWithBiometrics(
      localizedReason: 'Touch your finger on the sensor to login',
      useErrorDialogs: true,
      stickyAuth: true,

      // androidAuthStrings:AndroidAuthMessages(signInTitle: "Login to HomePage")
    );
    print('0000000000000000000000000000Biometric Authentication try');
  } catch (e) {
    print("error using biometric auth: $e");
  }
  print('11111111111111111111111111111Biometric Auth result');
  return authenticated;
}
