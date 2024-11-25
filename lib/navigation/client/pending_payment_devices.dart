import 'package:flutter/material.dart';

class PendingPaymentDevices extends StatefulWidget {
  const PendingPaymentDevices({super.key});

  @override
  State<PendingPaymentDevices> createState() => _PendingPaymentDevicesState();
}

class _PendingPaymentDevicesState extends State<PendingPaymentDevices> {
  final List<Map<String, dynamic>> devices = [
    {
      'id': 1,
      'problem_description': 'No enciende',
      'entry_date': '2024-11-20',
      'devices_id': 101,
      'devices_device_type_id': 1,
      'client_id': 1001,
      'technician_id': 2001,
      'diagnostic_observations': 'El circuito de encendido está quemado.',
      'diagnostic_parts': 'Placa madre',
      'diagnostic_estimated_cost': 50.0,
      'total_price': 100.0,
      'repair_observations': 'Reemplazar circuito de encendido.',
      'repair_start': '2024-11-22',
      'repair_end': '2024-11-24',
      'paid': 0,
      'repair_statuses_id': 1,
    },
    {
      'id': 2,
      'problem_description': 'Pantalla dañada',
      'entry_date': '2024-11-22',
      'devices_id': 102,
      'devices_device_type_id': 2,
      'client_id': 1002,
      'technician_id': 2002,
      'diagnostic_observations': 'Panel LCD roto.',
      'diagnostic_parts': 'Pantalla LCD',
      'diagnostic_estimated_cost': 120.0,
      'total_price': 250.0,
      'repair_observations': 'Reemplazar pantalla.',
      'repair_start': '2024-11-23',
      'repair_end': '2024-11-25',
      'paid': 0,
      'repair_statuses_id': 2,
    },
    {
      'id': 3,
      'problem_description': 'Sin señal',
      'entry_date': '2024-11-25',
      'devices_id': 103,
      'devices_device_type_id': 3,
      'client_id': 1003,
      'technician_id': 2003,
      'diagnostic_observations': 'Cable HDMI dañado.',
      'diagnostic_parts': 'Cable HDMI',
      'diagnostic_estimated_cost': 20.0,
      'total_price': 50.0,
      'repair_observations': 'Reemplazar cable HDMI.',
      'repair_start': '2024-11-26',
      'repair_end': '2024-11-27',
      'paid': 0,
      'repair_statuses_id': 3,
    },
  ];

  void _navigateToPayment(BuildContext context) {
    Navigator.pushNamed(context, '/menuClient');
  }

  @override
  Widget build(BuildContext context) {
    final pendingPaymentDevices =
        devices.where((device) => device['paid'] == 0).toList();

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
            onTap: () => _navigateToPayment(context),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _getDeviceIcon(device['devices_device_type_id']),
                      size: 50,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Problema: ${device['problem_description']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha de Ingreso: ${device['repair_start']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Costo Total: \$${device['total_price']}',
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
