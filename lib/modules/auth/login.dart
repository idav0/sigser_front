import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
  await prefs.setInt('rol', data.);

}

void showCorrectDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.bottomSlide,
    title:"Correcto",
    desc:"Las credenciales son correctas",
    ).show();
}
void showIncorrectDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.bottomSlide,
    title:"Incorrecto",
    desc:"Las credenciales no son validas",
    ).show();
}

class _LoginState extends State<Login> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'url'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesion'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 8, 167),
        titleTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      body: Center(
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
                TextFieldPassword(controller: _passwordController,),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                        final response = await _dio.post('/resto de url');
                        if (response.data.status==403) {
                          Navigator.pushNamed(context, '/changePassword');
                        } else if(response.data.status==200){
                          if (response.data.data.userInfo.authorities.authority == "TECNICO") {
                            showCorrectDialog(context);
                            saveData(response.data);
                            Navigator.pushNamed(context, '/menuTechnician');
                          } else if(response.data.data.userInfo.authorities.authority == "USUARIO"){
                            Navigator.pushNamed(context, '/menuClient');
                             saveData(response.data);
                            showCorrectDialog(context);
                          }else{
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.bottomSlide,
                              title:"INFO",
                              desc:"Este tipo de  usuario no esta disponible para esta platforma",
                            ).show();
                          }
                          showIncorrectDialog(context);

                        }

                      } catch (e) {
                        AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.bottomSlide,
                              title:"ERROR",
                              desc:"Error al realizar la petición",
                            ).show();
                      }
                      
                      } 
                      
                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 5, 8, 167),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: const Text('Iniciar sesión'),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
