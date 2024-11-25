import 'package:flutter/material.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final List<Map<String, String>> devices = [
    {
      'id': '001',
      'modelo': 'Laptop Pro X',
      'marca': 'TechBrand',
      'serie': 'SN12345',
      'problema': 'No enciende',
      'cliente': 'Juan Pérez',
      'fecha': '2024-11-20',
      'estado': 'Diagnóstico',
      'diagnostico': 'El circuito de encendido está quemado.',
    },
    {
      'id': '002',
      'modelo': 'Monitor 4K',
      'marca': 'DisplayCorp',
      'serie': 'SN98765',
      'problema': 'Pantalla dañada',
      'cliente': 'Ana López',
      'fecha': '2024-11-22',
      'estado': 'En espera de piezas',
      'diagnostico': 'El panel LCD está roto y requiere reemplazo.',
    },
  ];

  void _showDiagnosticModal(BuildContext context, String diagnostico) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Diagnóstico'),
          content: Text(diagnostico),
          actions: [
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
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return GestureDetector(
            onTap: () => _showDiagnosticModal(context, device['diagnostico']!),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono del dispositivo
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.devices, // Ícono general de dispositivo
                        size: 40,
                        color: Colors.blueGrey,
                      ),
                    ),
                    // Información del dispositivo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${device['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Modelo: ${device['modelo']}'),
                          Text('Marca: ${device['marca']}'),
                          Text('Número de Serie: ${device['serie']}'),
                          Text('Descripción del Problema: ${device['problema']}'),
                          Text('Cliente: ${device['cliente']}'),
                          Text('Fecha de Ingreso: ${device['fecha']}'),
                        ],
                      ),
                    ),
                    // Círculo del estado
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getColorForEstado(device['estado']!),
                          radius: 30, // Tamaño reducido del círculo
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          device['estado']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
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

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'Ingresado':
        return Colors.green;
      case 'Diagnóstico':
        return Colors.yellow;
      case 'Cotización':
        return Colors.orange;
      case 'En espera de aceptación del cliente':
        return Colors.redAccent;
      case 'En espera de piezas':
        return Colors.blueGrey;
      case 'En reparación':
        return Colors.blue;
      case 'Listo para entrega':
        return Colors.purple;
      case 'Entregado':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
