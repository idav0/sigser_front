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
    // Expresión regular para validar un correo electrónico estándar
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Validaciones
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su correo electrónico';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido';
    } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El correo no puede contener solo números';
    } else if (value.contains('<') || value.contains('>') || value.contains(';')) {
      return 'El correo no debe contener caracteres inválidos';
    }
    return null; // Es válido
  }

  void _sendRecoveryEmail() {
    // Validar el formulario antes de proceder
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
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
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey, // Vincula el formulario para validaciones
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png', // Cambia esto por la ruta de tu logo
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 50),
                const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tu correo de recuperación',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, // 70% del ancho
                  child: TextFormField(
                    controller: _emailController,
                    validator: validateEmail, // Validador para el campo
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, // 70% del ancho
                  child: ElevatedButton(
                    onPressed: _sendRecoveryEmail, // Llama a la función al presionar
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 5, 8, 167),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Enviar correo de recuperación',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
