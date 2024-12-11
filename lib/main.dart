import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sigser_front/modules/auth/forgot_password.dart';
import 'package:sigser_front/modules/auth/login.dart';
import 'package:sigser_front/modules/auth/recover_password.dart';
import 'package:sigser_front/modules/kernel/widgets/change_password.dart';
import 'package:sigser_front/modules/kernel/widgets/splash_screen.dart';
import 'package:sigser_front/navigation/client/devices_client.dart';
import 'package:sigser_front/navigation/navigation_client.dart';
import 'package:sigser_front/navigation/navigation_technician.dart';
import 'package:sigser_front/navigation/technician/devices.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await _setup();
  runApp(const MainApp());
}
Future<void> _setup() async {
  // Inicializa la clave pública de Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/menuClient': (context) => const NavigationClient(),
        '/menuTechnician': (context) => const NavigationTechnician(),
        '/viewDevicesTech': (context) => const Devices(),
        '/viewDevicesClient': (context) => const DevicesClient(),
        '/changePassword': (context) => const ChangePassword(),
        '/recoverPassword': (context) => const RecoverPassword()


        
        
      },
    );
  }
}