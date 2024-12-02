import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sigser_front/modules/kernel/widgets/custom_text_field_password.dart';
import 'package:sigser_front/modules/kernel/widgets/dialog_service.dart';

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

  var name = userInfo['name'] ?? '';
  var lastname = userInfo['lastname'] ?? '';
  var email = userInfo['email'] ?? '';
  var phone = userInfo['phone'] ?? '';
  var ListDevices = jsonEncode(devices['data']);

  await prefs.setString('listDevices', ListDevices);
  await prefs.setString('token', token);
  await prefs.setInt('id', userId);
  await prefs.setString('lastname', lastname);
  await prefs.setString('rol', authority);
  await prefs.setString('name', name);
  await prefs.setString('email', email);
  await prefs.setString('phone', phone);
}

void showCorrectDialog(BuildContext context, String authority) {
 
  Future.delayed(Duration(seconds: 2), () {
    if (authority == 'TECHNICIAN') {
      Navigator.pushNamed(
          context, '/menuTechnician'); 
    } else {
      Navigator.pushNamed(
          context, '/menuClient'); 
    }
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
                            var dataUser = {
                              'email': _emailController.text,
                              'password': _passwordController.text,
                            };

                            try {
                              final response = await _dio.post(
                                '/auth/login',
                                data: dataUser,
                                options: Options(
                                  validateStatus: (status) =>
                                      status! <
                                      500, 
                                ),
                              );
                              if (response.statusCode == 200) {
                                var userInfo =
                                    response.data['data']['userInfo'];
                                var authority =
                                    userInfo['authorities'][0]['authority'];
                                var id = userInfo['id'];

                                if (authority == "TECHNICIAN") {
                                  final devices = await _dio.get(
                                    '/repair/technician/$id',
                                    options: Options(
                                      headers: {
                                        'Authorization':
                                            'Bearer ${response.data['data']['loginInfo']['token']}',
                                      },
                                    ),
                                  );
                                  saveData(response.data, devices.data);
                                  showCorrectDialog(context, authority);
                                } else if (authority == "CLIENT") {
                                  final devices = await _dio.get(
                                    '/repair/client/$id',
                                    options: Options(
                                      headers: {
                                        'Authorization':
                                            'Bearer ${response.data['data']['loginInfo']['token']}',
                                      },
                                    ),
                                  );
                                  saveData(response.data, devices.data);
                                  showCorrectDialog(context, authority);
                                } else {
                                   DialogService().showInfoDialog(
                                    context,
                                    title: 'A',
                                    description: 'Este tipo de usuario no está disponible para esta plataforma',
                                );
                                }
                              } else if (response.statusCode == 403) {
                                Navigator.pushNamed(context, '/changePassword');
                              } else if (response.statusCode == 401) {
                                DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description: 'Credenciales incorrectas',
                                );
                              } else {
                                 DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description: 'Error inesperado: ${response.statusCode}',
                                );
  
                              }
                            } catch (e) {
                              if (e is DioException) {                              
                                  DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description: 'Error inesperado: ${e.response?.statusCode}',
                                );
                              }
                              
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 17, 24, 39),
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
