import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DevicesClient extends StatefulWidget {
  const DevicesClient({Key? key}) : super(key: key);
  

  @override
  State<DevicesClient> createState() => _DevicesClientState();
}

class _DevicesClientState extends State<DevicesClient> {
final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));

  List<Map<String, dynamic>> devices = [];
@override
  void initState() {
    super.initState();
    _loadDevicesFromPreferences();
  }

Future<void> _SendRequest(request,id) async {
  print('Entro');
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); 


  try {
    if (request) {
    final response = await _dio.put('/repair/status/customer-approval/${id}',
      options: Options(
      headers: {
        'Authorization': 'Bearer ${token}', 
        },
      ),
    );
    if(response.statusCode==200){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: "Cotizacion Aceptada",
      desc: "Se comenzara con la reparación",
    ).show();
    }else{
       AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: "Error en la peticion",
      desc: "Favor de revisar",).show();
    }
    
  } else {
    print('Rezhazo de la peticion');
      final response = await _dio.put('/repair/status/customer-rejection/${id}',
      options: Options(
      headers: {
        'Authorization': 'Bearer ${token}', 
        },
      ),
    );
    if(response.statusCode==200){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: "Cotizacion Rechazada",
      desc: "Podras pasar   por tu dispostivo",
    ).show();
    }else{
       AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: "Error en la peticion",
      desc: "Favor de revisar",).show();
    }

  }
  } catch (e) {
     AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: "Error en la peticion",
      desc: e.toString(),).show();
      print(e.toString());
  }
  
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
            '¿Deseas  aceptar o rechazar la cotización?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  device['estado'] = 'READY_FOR_COLLECTION';
                });
                print('id:');
                print(device['id']);
                _SendRequest(false,device['id']);
                Navigator.of(context).pop();
              },
              child: const Text('Rechazar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  device['repairStatus'] = 'En reparación';
                });
                _SendRequest(true,device['id']);
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
      case 'SMARTPHONE':
        return Icons.phone_iphone;
      case 'LAPTOP':
        return Icons.laptop;
      case 'DESKTOP':
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
      case 'WAITING_FOR_CUSTOMER_APPROVAL':
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
    return estado == 'WAITING_FOR_CUSTOMER_APPROVAL'
        ? Colors.green
        : estado == 'READY_FOR_COLLECTION'
            ? Colors.blue
            : estado == 'REPAIRING'
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
                  if (device['estado'] == 'WAITING_FOR_CUSTOMER_APPROVAL') {
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