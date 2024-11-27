import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sigser_front/modules/kernel/widgets/custom_text_field_password.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

void saveData(data) async {


  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', data.loginInfo.token);
  await prefs.setInt('id', data.userInfo.id);
  await prefs.setInt('rol', data.authorities.aythority);
}

void showCorrectDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.bottomSlide,
    title: "Correcto",
    desc: "Las credenciales son correctas",
  ).show();
}

void showIncorrectDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.bottomSlide,
    title: "Incorrecto",
    desc: "Las credenciales no son válidas",
  ).show();
}

class _LoginState extends State<Login> {
  final Dio _dio = Dio(BaseOptions(baseUrl:'${dotenv.env['BASE_URL']}'));

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    // Expresión regular para validar un correo electrónico
    final RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su correo electrónico';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido';
    }
    return null; // Si es válido, no devuelve ningún error
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese una nueva contraseña';
    }
    // Expresión regular para validar la contraseña
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":|])[A-Za-z\d!@#\$%^&*(),.?":|]{8,}$',
    );

    if (!passwordRegExp.hasMatch(value)) {
      return 'Contraseña incorrecta';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con las esferas
          const Positioned(
            top: -90, // Ajusta para centrar los círculos
            left: -145, // Ajusta para centrar los círculos
            child: Stack(
              alignment: Alignment.center, // Centra todos los círculos
              children: [
                CircleAvatar(
                  radius: 110,
                  backgroundColor:  Color.fromARGB(255, 17, 24, 39),
                ),
                CircleAvatar(
                  radius: 90, // Más pequeño
              	  backgroundColor: Color.fromARGB(255, 23, 37, 84),
                ),
                CircleAvatar(
                  radius: 70, // Más pequeño aún
                  backgroundColor:Color.fromARGB(255, 30, 64, 175),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: -30, // Ajusta para centrar los círculos
            right: -90, // Ajusta para centrar los círculos
            child: Stack(
              alignment: Alignment.center, // Centra todos los círculos
              children: [
                CircleAvatar(
                  radius: 110,
                  backgroundColor:  Color.fromARGB(255, 17, 24, 39),
                ),
                CircleAvatar(
                  radius: 90, // Más pequeño
              	  backgroundColor: Color.fromARGB(255, 23, 37, 84),
                ),
                CircleAvatar(
                  radius: 70, // Más pequeño aún
                  backgroundColor:Color.fromARGB(255, 30, 64, 175),
                ),
              ],
            ),
          ),
          
          // Formulario de inicio de sesión
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
                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      decoration: const InputDecoration(
                        hintText: 'Correo electronico',
                        label: Text('ejemplo@gmail.com'),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFieldPassword(
                      controller: _passwordController,
                      validator: validatePassword,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      height: 48,
                      width: double.infinity, // Ocupa todo el ancho disponible
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              var dataUser = {
                                  'username': _emailController.text, // Reemplaza con el nombre de usuario
                                  'password': _passwordController.text // Reemplaza con la contraseña
                                };
                              final response = await _dio.post(
                                '/auth/login',
                                data: dataUser
                                );
                              print(response);
                              if (response.data.status == 403) {
                                Navigator.pushNamed(context, '/changePassword');
                              } else if (response.data.status == 200) {
                                if (response.data.data.userInfo.authorities.authority == "TECNICO") {
                                  showCorrectDialog(context);
                                  saveData(response.data);
                                  Navigator.pushNamed(context, '/menuTechnician');
                                } else if (response.data.data.userInfo.authorities.authority == "USUARIO") {
                                  Navigator.pushNamed(context, '/menuClient');
                                  saveData(response.data);
                                  showCorrectDialog(context);
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.bottomSlide,
                                    title: "INFO",
                                    desc: "Este tipo de usuario no está disponible para esta plataforma",
                                  ).show();
                                }
                                showIncorrectDialog(context);
                              }
                            } catch (e) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: "ERROR",
                                desc: "Error al realizar la petición",
                              ).show();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 17, 24, 39), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 56), 
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 18), 
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/forgotPassword'),
                      child: const Text(
                        'Olvide mi contraseña',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
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
