import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigser_front/modules/kernel/widgets/repair_form_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Devices extends StatefulWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevicesFromPreferences();
  }

  Future<void> _loadDevicesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('listDevices');

    if (devicesJson != null) {
      try {
        List<dynamic> jsonList = jsonDecode(devicesJson);

        List<Map<String, dynamic>> adaptedDevices = jsonList.map((device) {
          return {
            'id': device['id'].toString(),
            'tipo': device['device']['deviceType']['name'].toString(),
            'modelo': device['device']['model'].toString(),
            'marca': device['device']['brand'].toString(),
            'serie': device['device']['serialNumber'].toString(),
            'problema': device['problem_description'].toString(),
            'cliente': device['cliente'] ?? 'Desconocido',
            'fecha': device['entry_date'].toString(),
            'diagnostico':
                (device['diagnostic_observations'] ?? 'N/A').toString(),
            'estado': device['repairStatus']['name'].toString(),
          };
        }).toList();

        setState(() {
          devices.addAll(adaptedDevices);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar dispositivos: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se encontraron dispositivos guardados.')),
      );
    }
  }

  Future<void> _startDiagnostic(String repairId) async {
    final String url =
        '${dotenv.env['BASE_URL']}/repair/status/start-diagnostic/$repairId';

    try {
      final response = await http.put(Uri.parse(url));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnóstico iniciado correctamente')),
        );
        setState(() {
          devices.removeWhere((device) => device['id'] == repairId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar diagnóstico: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }
  

 IconData _getDeviceIcon(String tipo) {
    switch (tipo) {
      case 'SMARTPHONE':
        return Icons.phone_android;
      case 'LAPTOP':
        return Icons.laptop;
      case 'MONITOR':
        return Icons.desktop_mac;
      case 'TABLET':
        return Icons.tablet;
      default:
        return Icons.devices;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'RECEIVED':
        return Icons.add_task;
      case 'DIAGNOSIS':
        return Icons.medical_services;
      case 'QUOTATION':
        return Icons.receipt_long;
      case 'WAITING_FOR_COSTUMER_APPROVAL':
        return Icons.hourglass_empty;
      case 'WAITING_FOR_PARTS':
        return Icons.timelapse;
      case 'REPAIRING':
        return Icons.build;
      case 'READY_FOR_COLLECTION':
        return Icons.check_circle;
      case 'COLLECTED':
        return Icons.done_all;
      default:
        return Icons.error;
    }
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'RECEIVED':
        return Colors.green;
      case 'DIAGNOSIS':
        return Colors.orange;
      case 'QUOTATION':
        return Colors.yellow;
      case 'WAITING_FOR_COSTUMER_APPROVAL':
        return Colors.blue;
      case 'WAITING_FOR_PARTS':
        return Colors.red;
      case 'REPAIRING':
        return Colors.purple;
      case 'READY_FOR_COLLECTION':
        return Colors.cyan;
      case 'COLLECTED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  

  void _showDiagnosticModal(BuildContext context, Map<String, dynamic> device) {
    String? buttonText;
    VoidCallback? buttonAction;

    switch (device['estado']) {
      case 'RECEIVED':
        buttonText = 'Iniciar Diagnóstico';
        buttonAction = () {
          Navigator.of(context).pop();
          _startDiagnostic(device['id']);
        };
        break;
      case 'DIAGNOSIS':
        buttonText = 'Crear Reporte';
        buttonAction = () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RepairFormScreen(
              repairId: int.parse(device['id']),
            ),
          ),
        );
      };
      break;
      case 'QUOTATION':
        buttonText = 'Aprobar Cotización';
        buttonAction = () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aprobando cotización...')),
          );
        };
        break;
      default:
        buttonText = null;
        buttonAction = null;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Detalles de Reparación',
            style: TextStyle(color: Color(0xff172554)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: device.keys.map((key) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$key:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(device[key].toString()),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            if (buttonText != null)
              ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue button
                  foregroundColor: Colors.white, // White text
                ),
                child: Text(buttonText),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Registrados'),
      ),
      body: devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return GestureDetector(
                  onTap: () => _showDiagnosticModal(context, device),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            _getDeviceIcon(device['tipo']!),
                            size: 50,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Modelo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(device['modelo']!),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Marca',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(device['marca']!),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Fecha',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(device['fecha']!),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _getColorForEstado(device['estado']!),
                                radius: 25,
                                child: Icon(
                                  _getEstadoIcon(device['estado']!),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                device['estado']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
