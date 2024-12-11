import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sigser_front/modules/kernel/widgets/dialog_service.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  late String parametro;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parametro = ModalRoute.of(context)?.settings.arguments as String? ??
        'Valor predeterminado';
  }

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool obscureText = true;

  String? validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    if (!regex.hasMatch(password)) {
      return '8 caracteres, una mayúscula y un número.';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }
      var dataUser = {
        'email': parametro,
        'newPassword': _passwordController.text,
        'token': _tokenController.text,
      };

      try {
        final response = await _dio.post(
          '/auth/forgot-password/update-password',
          data: dataUser,
          options: Options(
            validateStatus: (status) => status! < 500,
          ),
        );

        print(response);

        if (response.statusCode == 200) {
          DialogService().showSuccessDialog(
            context,
            title: 'Correcto',
            description: 'La contraseña se ha cambiado correctamente',
          );
          Future.delayed(const Duration(seconds: 5), () {
            Navigator.pushNamed(context, '/login');
          });
        } else {
          DialogService().showErrorDialog(
            context,
            title: 'Error',
            description:
                'Error, verifique que los datos sean correctos y vuelva a intentarlo',
          );
        }
        print(dataUser);
      } catch (e) {
        if (e is DioError) {
          DialogService().showErrorDialog(
            context,
            title: 'Error',
            description: 'Error inesperado, intente de nuevo',
          );
        }
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Contraseña restablecida con éxito')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
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
                  width: 150,
                  height: 150,
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
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) => validatePassword(value ?? ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
