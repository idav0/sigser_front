import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sigser_front/modules/kernel/widgets/custom_text_field_password.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  String lastname = '';
  String email = '';
  String phone = '';

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Sin Nombre';
      lastname = prefs.getString('lastname') ?? 'Sin Apellido';
      email = prefs.getString('email') ?? 'Sin Correo';
      phone = prefs.getString('phone') ?? 'Sin Teléfono';
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese una nueva contraseña';
    }
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*?])[A-Za-z\d!@#\$%^&*?]{8,}$',
    );
    if (!passwordRegExp.hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres, incluir una letra, un número, una mayúscula y un carácter especial';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme su contraseña';
    }
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1e40af),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 59,
                  backgroundColor: Color(0xFF172554),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 59,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                '$name $lastname',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF172554),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.info,
                    animType: AnimType.scale,
                    title: 'Cambiar Contraseña',
                    body: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldPassword(
                            controller: _newPasswordController,
                            validator: validatePassword,
                          ),
                          const SizedBox(height: 13),
                          TextFieldPassword(
                            controller: _confirmPasswordController,
                            validator: validateConfirmPassword,
                          ),
                          const SizedBox(height: 13),
                        ],
                      ),
                    ),
                    btnOkText: 'Cambiar',
                    btnOkOnPress: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Contraseña cambiada con éxito')),
                        );
                      }
                    },
                    btnCancelOnPress: () {},
                  ).show();
                },
                child: const Text('Cambiar Contraseña'),
              ),
              const SizedBox(height: 17),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 111, 3, 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.scale,
                    title: 'Cerrar Sesión',
                    desc: '¿Estás seguro de que deseas cerrar sesión?',
                    btnCancel: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 111, 3, 3),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    btnOk: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF172554),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ).show();
                },
                child: const Text('Cerrar Sesión'),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
