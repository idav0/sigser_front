import 'package:flutter/material.dart';

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
    } else if (value.contains('<') || value.contains('>') || value.contains(';')) {
      return 'El correo no debe contener caracteres inválidos';
    }
    return null;
  }

  void _sendRecoveryEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      Navigator.pushNamed(context, '/recoverPassword');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se ha enviado un correo de recuperación a $email'),
        ),
      );
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
                        hintText: 'Correo electrónico',
                        label: Text('ejemplo@gmail.com'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
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
