import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sigser_front/modules/kernel/widgets/dialog_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? validateEmail(String? value) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su correo electrónico';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido';
    } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El correo no puede contener solo números';
    } else if (value.contains('<') ||
        value.contains('>') ||
        value.contains(';')) {
      return 'El correo no debe contener caracteres inválidos';
    }
    return null;
  }

  Future<void> _sendRecoveryEmail() async {
    final Dio dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;

      final datatoken = {
        'email': email,
      };

      try {
        final response = await dio.post(
          '/auth/forgot-password/token',
          data: datatoken,
          options: Options(
            validateStatus: (status) => status! < 500,
          ),
        );

        print(response);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se ha enviado un correo de recuperación a $email'),
            ),
          );
          Navigator.pushNamed(context, '/recoverPassword', arguments: _emailController.text);
        } else {
          DialogService().showErrorDialog(
            context,
            title: 'ERROR',
            description:
                'Error, verifique que el correo sea correcto y vuelva a intentarlo',
          );
        }
      } catch (e) {
        if (e is DioException) {
          DialogService().showErrorDialog(
            context,
            title: 'ERROR',
            description: 'Error inesperado, intente de nuevo',
          );
        }
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: const Color.fromARGB(255, 70, 90, 156),
        titleTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned(
            top: -90,
            left: -145,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 110,
                  backgroundColor: Color.fromARGB(255, 17, 24, 39),
                ),
                CircleAvatar(
                  radius: 90,
                  backgroundColor: Color.fromARGB(255, 23, 37, 84),
                ),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Color.fromARGB(255, 30, 64, 175),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: -30,
            right: -90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 110,
                  backgroundColor: Color.fromARGB(255, 17, 24, 39),
                ),
                CircleAvatar(
                  radius: 90,
                  backgroundColor: Color.fromARGB(255, 23, 37, 84),
                ),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Color.fromARGB(255, 30, 64, 175),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un correo de recuperación',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'ejemplo@gmail.com',
                        label: Text('Correo Electrónico'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendRecoveryEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Solictar recuperación',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
