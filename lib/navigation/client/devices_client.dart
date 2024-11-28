import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevicesClient extends StatefulWidget {
  const DevicesClient({Key? key}) : super(key: key);
  

  @override
  State<DevicesClient> createState() => _DevicesClientState();
}

class _DevicesClientState extends State<DevicesClient> {
  List<Map<String, dynamic>> devices = [];
@override
  void initState() {
    super.initState();
    _loadDevicesFromPreferences();
  }
Future<void> _loadDevicesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('listDevices');
    print(devicesJson);
  

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
        const SnackBar(content: Text('No se encontraron dispositivos guardados.')),
      );
    }
  }


  void _showCotizacionModal(BuildContext context, Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Aceptar Cotización',
            style: TextStyle(color: Color(0xff172554)),
          ),
          content: const Text(
            '¿Seguro que deseas aceptar la cotización?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  device['estado'] = 'Listo para entrega';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  device['estado'] = 'En reparación';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  IconData _getDeviceIcon(String tipo) {
    switch (tipo) {
      case 'Celular':
        return Icons.phone_iphone;
      case 'Computadora':
        return Icons.laptop;
      case 'Monitor':
        return Icons.desktop_mac;
      case 'Tablet':
        return Icons.tablet;
      default:
        return Icons.devices;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Ingresado':
        return Icons.add_task;
      case 'Diagnóstico':
        return Icons.medical_services;
      case 'Cotización':
        return Icons.receipt_long;
      case 'En espera de aceptación del cliente':
        return Icons.hourglass_empty;
      case 'En espera de piezas':
        return Icons.timelapse;
      case 'En reparación':
        return Icons.build;
      case 'Listo para entrega':
        return Icons.check_circle;
      case 'Entregado':
        return Icons.done_all;
      default:
        return Icons.error;
    }
  }

  Color _getColorForEstado(String estado) {
    return estado == 'Cotización'
        ? Colors.green
        : estado == 'Listo para entrega'
            ? Colors.blue
            : estado == 'En reparación'
            ? const Color.fromARGB(255, 145, 33, 243)
            : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos del Cliente'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return GestureDetector(
                onTap: () {
                  if (device['estado'] == 'Cotización') {
                    _showCotizacionModal(context, device);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                Text(
                                  'Modelo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  device['modelo']!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Marca',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  device['marca']!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Fecha',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  device['fecha']!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getColorForEstado(device['estado']!),
                              radius: isMobile ? 20 : 25,
                              child: Icon(
                                _getEstadoIcon(device['estado']!),
                                color: Colors.white,
                                size: isMobile ? 18 : 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              device['estado']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
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
          );
        },
      ),
    );
  }
}