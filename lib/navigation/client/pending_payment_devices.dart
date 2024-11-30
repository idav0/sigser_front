import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
class PendingPaymentDevices extends StatefulWidget {
  const PendingPaymentDevices({super.key});

  @override
  State<PendingPaymentDevices> createState() => _PendingPaymentDevicesState();
}

class _PendingPaymentDevicesState extends State<PendingPaymentDevices> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));
 List<Map<String, dynamic>> devices = [];

  void _navigateToPayment(BuildContext context, device) {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'Accion a realizar',
            desc: '¿Deseas pagar en este momento tu reparacion?',
            btnCancelOnPress: ()  {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                 title: 'Operación Cancelada',
              ).show();
            },
            btnOkOnPress: () async{
              final prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('token'); 
      
          
                final response = await _dio.put('/repair/status/paid/${device['id']}',
                options: Options(
                headers: {
                  'Authorization': 'Bearer ${token}', 
                    },
                  ),
                );
                if (response.statusCode==200) {
                   AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Operación Realizada con Exito',
                    ).show();
                    setState(() {
                      device['pago'] = true;
                    });
                } else {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Operacion Cancelada',
                      desc: 'Status Code: ${response.statusCode} : ${response.statusMessage} '
                    ).show();
                }
            },
            ).show();
  }
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
            'pago': device['paid'],
            'tipo': device['device']['deviceType']['name'].toString(),
             'tipoId': device['device']['deviceType']['id'].toString(),
            'modelo': device['device']['model'].toString(),
            'marca': device['device']['brand'].toString(),
            'serie': device['device']['serialNumber'].toString(),
            'problema': device['problem_description'].toString(),
            'costoTotal': device['total_price'].toString(),
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
  @override
  Widget build(BuildContext context) {

    final pendingPaymentDevices =
        devices.where((device) => device['pago'] == false ).toList();
  
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pagos Pendientes',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1e40af),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: pendingPaymentDevices.length,
        itemBuilder: (context, index) {
          final device = pendingPaymentDevices[index];
          return GestureDetector(
            onTap: () => _navigateToPayment(context, device),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _getDeviceIcon(int.parse(device['tipoId'])),
                      size: 50,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${device['marca']} ${device['modelo']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Problema: ${device['problema']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Fecha de Ingreso: ${device['fecha']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Costo Total: \$${device['costoTotal']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 20,
                      child: Icon(
                        Icons.payment,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pago Pendiente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
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

  IconData _getDeviceIcon(int deviceTypeId) {
    switch (deviceTypeId) {
      case 1:
        return Icons.phone_iphone;
      case 2:
        return Icons.laptop;
      case 3:
        return Icons.desktop_mac;
      default:
        return Icons.devices;
    }
  }
}
