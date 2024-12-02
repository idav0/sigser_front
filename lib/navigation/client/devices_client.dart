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
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final int? userId = prefs.getInt('id');

      if (token == null || userId == null) {
        _showSnackBar('Token o ID de usuario no encontrados.');
        return;
      }

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
        _showSnackBar('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error al conectar con el servidor: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDevicesFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? devicesJson = prefs.getString('listDevices');

      if (devicesJson != null) {
        final List<dynamic> jsonList = jsonDecode(devicesJson);

        final List<Map<String, dynamic>> adaptedDevices = jsonList
            .where((device) => device['repairStatus']['name'] != 'COLLECTED')
            .map((device) {
          final deviceData = device['device'] ?? {};
          final repairStatus = device['repairStatus'] ?? {};

          return {
            'id': device['id']?.toString() ?? '',
            'tipo': deviceData['deviceType']?['name']?.toString() ?? 'Desconocido',
            'modelo': deviceData['model']?.toString() ?? 'Desconocido',
            'marca': deviceData['brand']?.toString() ?? 'Desconocido',
            'serie': deviceData['serialNumber']?.toString() ?? 'Desconocido',
            'problema': device['problem_description']?.toString() ?? 'N/A',
            'cliente': device['cliente']?.toString() ?? 'Desconocido',
            'fecha': device['entry_date']?.toString() ?? 'N/A',
            'diagnostico': device['diagnostic_observations']?.toString() ?? 'N/A',
            'estado': repairStatus['name']?.toString() ?? 'Sin estado',
          };
        }).toList();

        setState(() {
          devices.clear();
          devices.addAll(adaptedDevices);
        });
      }
    } catch (e) {
      _showSnackBar('Error al cargar dispositivos: $e');
    }
  }

  Future<void> _updateDevices(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      final response = await _dio.get(
        '/repair/client/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final devicesData = response.data;
        _saveDevices(devicesData);
        await _loadDevicesFromPreferences();
      } else {
        _showSnackBar('Error al actualizar dispositivos.');
      }
    } catch (e) {
      _showSnackBar('Error al conectar con el servidor.');
    }
  }

  void _saveDevices(dynamic devices) async {
    final prefs = await SharedPreferences.getInstance();
    final String listDevices = jsonEncode(devices['data']);
    await prefs.setString('listDevices', listDevices);
  }

  void _showCotizacionModal(BuildContext context, Map<String, dynamic> device) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Aceptar Cotización',
      desc: '¿Deseas aceptar o rechazar esta cotización?',
        btnCancel: ElevatedButton(
      onPressed: () {
        sendRequest(false, device['id']);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 111, 3, 3),
      ),
      child: const Text('Rechazar'),
    ),
      btnCancelOnPress: () {
        sendRequest(false, device['id']);
      },
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
