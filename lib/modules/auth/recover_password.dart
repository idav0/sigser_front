import 'package:flutter/material.dart';
import 'package:sigser_front/modules/kernel/widgets/custom_text_field_password.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validatePassword(String? value) {
    final RegExp passwordRegExp = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    } else if (!passwordRegExp.hasMatch(value)) {
      return 'Debe tener al menos 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial';
    } else if (value.contains("'") || value.contains("\"") || value.contains(";")) {
      return 'Caracteres no permitidos';
    }
    return null;
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña restablecida con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Ingresa tu token de recuperación',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Token de recuperación',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor, ingresa el token' : null,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: TextFieldPassword(
                    controller: _passwordController,
                    hintText: 'Nueva contraseña',
                    labelText: 'Nueva contraseña',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: TextFieldPassword(
                    controller: _confirmPasswordController,
                    hintText: 'Confirmar contraseña',
                    labelText: 'Confirmar contraseña',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 5, 8, 167),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Restablecer contraseña',
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
