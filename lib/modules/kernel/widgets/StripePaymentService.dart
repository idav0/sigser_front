import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Asegúrate de cargar tu .env si es necesario
import 'package:sigser_front/modules/kernel/widgets/dialog_service.dart'; // Reemplaza con el import adecuado
import 'package:dio/dio.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigser_front/modules/kernel/widgets/get_devices.dart';

class StripePaymentService {
  StripePaymentService._();

  static final StripePaymentService instance = StripePaymentService._();

  // Inicia Stripe con la clave pública de tu cuenta de Stripe
  Future<void> init() async {
    Stripe.publishableKey = '${dotenv.env['STRIPE_PUBLISHABLE_KEY']}';
    await Stripe.instance.applySettings();
  }

  Future<void> makePayment(
      double amount, String currency, BuildContext context, device,
      {required VoidCallback onPaymentSuccess}) async {
    final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    try {
      // Llamamos a la función para crear el pago y obtener el client_secret
      String? clientSecret = await _createPayment(amount, currency);

      if (clientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "REPARTECH",
        ),
      );
      await _processPayment();
      print('Llego hasta aqui');
      final response = await _dio.put(
        '/repair/status/paid/${device['id']}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        DialogService().showSuccessDialog(context,
            title: "Correcto", description: "Pago realizado");
        onPaymentSuccess();
        await GetDevices.instance.getData();
      } else {
        DialogService().showErrorDialog(context,
            title: "Error",
            description: "Tu solicitud de pago se ha rechazado");
      }
    } catch (e) {
      print("Error en makePayment: $e");
    }
  }

  // Crear el PaymentIntent en Stripe (usando una solicitud a la API de Stripe)
  Future<String?> _createPayment(double amount, String currency) async {
    try {
      final dio = Dio();

      // Hacemos la solicitud a la API de Stripe para crear un PaymentIntent
      final response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type':
                'application/x-www-form-urlencoded' // Clave secreta de Stripe
          },
        ),
        data: {
          'amount':
              (amount * 100).toInt(), // Stripe maneja la cantidad en centavos
          'currency': currency,
        },
      );

      if (response.statusCode == 200) {
        String clientSecret = response.data['client_secret'];
        return clientSecret;
      } else {
        print('Error al crear PaymentIntent: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al crear el pago: $e');
      return null;
    }
  }

  // Presentar la PaymentSheet y procesar el pago
  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Pago exitoso');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        print("El usuario canceló el pago.");
        throw Exception("Pago cancelado por el usuario.");
      } else {
        print("Error en _processPayment: ${e.error.message}");
        throw Exception("Error al procesar el pago.");
      }
    } catch (e) {
      print("Error desconocido en _processPayment: $e");
      throw Exception("Error inesperado.");
    }
  }
}
