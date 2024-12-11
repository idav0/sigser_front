import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

import 'package:sigser_front/modules/kernel/widgets/custom_text_field_password.dart';
import 'package:sigser_front/modules/kernel/widgets/dialog_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});
//hola darien
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
      Navigator.pushNamed(context, '/menuTechnician');
    } else {
      Navigator.pushNamed(context, '/menuClient');
    }
  });
}




Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition();
}


String? validatePassword(String password) {
  final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
  if (!regex.hasMatch(password)) {
    return '8 caracteres, una mayúscula y un número.';
  }
  return null;
}



Future<String> showChangePasswordDialog(BuildContext context, String email) async {
  final temporaryPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final Dio dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));
  int? responseCode = 0;



await showDialog(
  context: context,
  barrierDismissible: false, // No permite cerrar tocando fuera del diálogo
  builder: (context) {
    bool obscureText = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Nuevo Usuario (Cambio de Contraseña)'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: temporaryPasswordController,
                  decoration: const InputDecoration(labelText: 'Contraseña temporal'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la contraseña temporal.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
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
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {

                if (formKey.currentState!.validate()) {

                  var dataNewPassword = {
                    'email': email,
                    'newPassword': newPasswordController.text,
                    'oldPassword': temporaryPasswordController.text,
                  };

                  print(dataNewPassword);

                  try{
                    final response = await dio.post(
                                '/auth/signup/update-password',
                                data: dataNewPassword,
                                options: Options(
                                  validateStatus: (status) => status! < 500,
                                ),
                              );

                  print(response);

                  if (response.statusCode == 200) {
                    responseCode = response.statusCode;
                    Navigator.pop(context); // Cierra el diálogo
                  } else {
                    responseCode = response.statusCode;
                    Navigator.pop(context); // Cierra el diálogo

                  }

                  } catch (e) {
                    if (e is DioException) {
                      DialogService().showErrorDialog(
                        context,
                        title: 'ERROR',
                        description:
                            'Error inesperado, intente de nuevo',
                      );
                    }
                  }
                  // Aquí puedes llamar a tu API para cambiar la contraseña
                }
              },
              child: const Text('Cambiar'),
            ),
          ],
        );
      },
    );
  },
);

return responseCode.toString();

  

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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        validator: validateEmail,
                        decoration: const InputDecoration(
                          hintText: 'ejemplo@gmail.com',
                          label: Text('Correo Electrónico'),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFieldPassword(
                        controller: _passwordController,
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 32),
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
                                    validateStatus: (status) => status! < 500,
                                  ),
                                );
      
                                print(response);
      
                                if (response.statusCode == 200) {
                                  var userInfo =
                                      response.data['data']['userInfo'];
                                  var authority =
                                      userInfo['authorities'][0]['authority'];
                                  var id = userInfo['id'];
      
                                  // Position position =
                                  //     await _determinePosition(); 
      
                                  // print(
                                  //     'Ubicación actual: Lat: ${position.latitude}, Long: ${position.longitude}');
                                  // print('ID del usuario: $id');
      
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
                                    Navigator.pushNamed(
                                        context, '/menuTechnician');
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
                                    Navigator.pushNamed(context, '/menuClient');
                                  } else {
                                    DialogService().showInfoDialog(
                                      context,
                                      title: 'A',
                                      description:
                                          'Este tipo de usuario no está disponible para esta plataforma',
                                    );
                                  }
                                } else if (response.statusCode == 403) {
                                  var responseCode = await showChangePasswordDialog(context, _emailController.text);
      
                                  if (responseCode == '200') {
                                    DialogService().showSuccessDialog(
                                      context,
                                      title: 'Contraseña cambiada',
                                      description:
                                          'La contraseña ha sido cambiada correctamente, por favor inicia sesión nuevamente',
                                    );
                                  } else if (responseCode == '0') {
                                    
                                  } else {
                                    DialogService().showErrorDialog(
                                      context,
                                      title: 'ERROR',
                                      description: 'Error, verifica tus datos e intenta de nuevo', 
                                    );
                                  }
                                } else if (response.statusCode == 401) {
                                  DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description: 'Correo o contraseña incorrectos',
                                  );
                                
                                 } else {
                                  DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description: 'Error inesperado',
                                  );
                                }
                              } catch (e) {
                                if (e is DioException) {
                                  DialogService().showErrorDialog(
                                    context,
                                    title: 'ERROR',
                                    description:
                                        'Error inesperado, intente de nuevo',
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 0, 0),
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
                      const SizedBox(height: 32),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/forgotPassword'),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
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
      ),
    );
  }
}
