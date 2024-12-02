import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sigser_front/modules/kernel/widgets/device_card.dart'; 

class DevicesClient extends StatefulWidget {
  const DevicesClient({Key? key}) : super(key: key);

  @override
  State<DevicesClient> createState() => _DevicesClientState();
}

class _DevicesClientState extends State<DevicesClient> {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL']!));
  final List<Map<String, dynamic>> devices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDevicesFromPreferences();
  }

  Future<void> sendRequest(bool isApproval, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('id');

    try {
      final endpoint = isApproval ? 'customer-approval' : 'customer-rejection';
      final response = await _dio.put(
        '/repair/status/$endpoint/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.success,
          title: isApproval ? 'Cotización Aceptada' : 'Cotización Rechazada',
          desc: isApproval
              ? 'Se procederá con el siguiente paso.'
              : 'Puedes recoger tu dispositivo.',
          btnOkOnPress: () {},
        ).show();
        await _updateDevices(userId);
      } else {
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          title: 'Error en la solicitud',
          desc: 'Status ${response.statusCode}: ${response.data['message']}',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Ocurrió un problema: ${e.toString()}',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> _loadDevicesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString('listDevices');

    if (devicesJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(devicesJson);
        final List<Map<String, dynamic>> adaptedDevices = jsonList.map((device) {
          return {
            'id': device['id'].toString(),
            'tipo': device['device']['deviceType']['name'].toString(),
            'modelo': device['device']['model'].toString(),
            'marca': device['device']['brand'].toString(),
            'fecha': device['entry_date'].toString(),
            'estado': device['repairStatus']['name'].toString(),
          };
        }).toList();

        setState(() {
          devices.addAll(adaptedDevices);
        });
      } catch (e) {
        _showSnackBar('Error al cargar dispositivos: $e');
      }
    } else {
      _showSnackBar('No se encontraron dispositivos guardados.');
    }
  }

  Future<void> _updateDevices(int? userId) async {
    try {
      final response = await _dio.get(
        '/repair/client/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer ${dotenv.env['TOKEN']}'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          devices.clear();
          devices.addAll(List<Map<String, dynamic>>.from(response.data));
        });
      } else {
        _showSnackBar('Error al actualizar dispositivos: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error al actualizar dispositivos: $e');
    }
  }

void _showCotizacionModal(BuildContext context, Map<String, dynamic> device) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.question,
    animType: AnimType.scale,
    title: 'Aceptar Cotización',
    desc: '¿Deseas aceptar o rechazar esta cotización?',
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
      onPressed: () {
        sendRequest(true, device['id']);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF172554),
      ),
      child: const Text('Aceptar'),
    ),
    btnOkOnPress: () {
      sendRequest(true, device['id']);
    },
    btnCancelOnPress: () {
      sendRequest(false, device['id']);
    },
  ).show();
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos del Cliente'),
      ),
      body: Stack(
        children: [
          devices.isEmpty
              ? const Center(child: Text('No hay dispositivos disponibles.'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return GestureDetector(
                      onTap: () {
                        if (device['estado'] == 'WAITING_FOR_CUSTOMER_APPROVAL') {
                          _showCotizacionModal(context, device);
                        }
                      },
                      child: DeviceCard(device: device), 
                    );
                  },
                ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
