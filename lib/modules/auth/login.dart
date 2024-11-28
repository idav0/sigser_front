import 'dart:convert';

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

void saveData(data, devices) async {
  final prefs = await SharedPreferences.getInstance();

  var userInfo = data['data']['userInfo'];
  var authority = userInfo['authorities'][0]['authority'];
  var userId = userInfo['id'];
  var token = data['data']['loginInfo']['token'];
  var name = userInfo['name'];
  var lastname = userInfo['lastname'];
  var email = userInfo['email'];
  var phone = userInfo['phone'];
  var ListDevices = jsonEncode(devices['data']); 

  // Guardar datos del usuario en SharedPreferences
  await prefs.setString('listDevices', ListDevices); 
  await prefs.setString('token', token); 
  await prefs.setInt('id', userId); 
  await prefs.setInt('lastname', lastname); 
  await prefs.setString('rol', authority);
  await prefs.setString('name', name);
  await prefs.setString('email', email);
  await prefs.setString('phone', phone);
  
}

void showCorrectDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.bottomSlide,
    title: "Correcto",
    desc: "Las credenciales son correctas",
  ).show();

  Future.delayed(Duration(seconds: 2), () {
    Navigator.pushNamed(context, '/menuClient');
  });
}

class _LoginState extends State<Login> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    final RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su correo electrónico';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese la contraseña';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      decoration: const InputDecoration(
                        hintText: 'Correo electrónico',
                        label: Text('ejemplo@gmail.com'),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFieldPassword(
                      controller: _passwordController,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              var dataUser = {
                                'email': _emailController.text,
                                'password': _passwordController.text,
                              };
                              final response = await _dio.post(
                                '/auth/login',
                                data: dataUser,
                              );
                              if (response.statusCode == 200) {
                                final devices = await _dio.get(
                                  '/repair/client/${response.data['data']['userInfo']['id']}',
                                  options: Options(
                                    headers: {
                                      'Authorization':
                                          'Bearer ${response.data['data']['loginInfo']['token']}',
                                    },
                                  ),
                                );
                                saveData(response.data, devices.data);
                                showCorrectDialog(context);
                              }
                            } catch (e) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                title: "ERROR",
                                desc: e.toString(),
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
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/forgotPassword'),
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
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
