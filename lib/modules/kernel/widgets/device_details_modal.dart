import 'package:flutter/material.dart';

class DeviceDetailsModal extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onDiagnosticStart;
  final VoidCallback onRepairStart;

  const DeviceDetailsModal({
    Key? key,
    required this.device,
    required this.onDiagnosticStart,
    required this.onRepairStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Detalles del Dispositivo',
        style: TextStyle(color: Color(0xff172554)),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: device.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_capitalize(entry.key)}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        if (device['estado'] == 'RECEIVED')
          ElevatedButton(
            onPressed: onDiagnosticStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Diagnóstico'),
          ),
        if (device['estado'] == 'DIAGNOSIS')
          ElevatedButton(
            onPressed: onRepairStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Reparación'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
