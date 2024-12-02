import 'package:flutter/material.dart';
import 'package:sigser_front/modules/kernel/widgets/device_utils.dart';
import 'package:sigser_front/modules/kernel/widgets/complete_repair_form_screen.dart';
import 'package:sigser_front/modules/kernel/widgets/repair_form_screen.dart';

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
    void _showConfirmationDialog(String message, VoidCallback onConfirm) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            message, 
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 141, 28, 28), // Rojo oscuro
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                'Sí',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 12, 18, 104), // Verde oscuro
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text(
        'Detalles del Dispositivo',
        style: TextStyle(color: Color(0xff172554)),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: device.entries.map((entry) {
            final value = entry.key == 'estado'
                ? DeviceUtils.translateEstado(entry.value.toString())
                : entry.value.toString();

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
                    value,
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
            onPressed: () => _showConfirmationDialog(
              '¿Iniciar diagnóstico?',
              onDiagnosticStart,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Diagnóstico'),
          ),
        if (device['estado'] == 'DIAGNOSIS')
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RepairFormScreen(
                    repairId: int.parse(device['id'] ?? '0'),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear Reporte'),
          ),
        if (device['estado'] == 'WAITING_FOR_CUSTOMER_APPROVAL')
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Esperando aceptación del cliente...'),
          ),
        if (device['estado'] == 'WAITING_FOR_PARTS')
          ElevatedButton(
            onPressed: () => _showConfirmationDialog(
              '¿Iniciar reparación?',
              onRepairStart,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Reparación'),
          ),
        if (device['estado'] == 'REPAIRING')
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompleteRepairFormScreen(
                    repairId: int.parse(device['id'] ?? '0'),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar Reparación'),
          ),
        if (device['estado'] == 'READY_FOR_COLLECTION')
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 18, 104),
              foregroundColor: Colors.white,
            ),
            child: const Text('Esperando recolección del cliente'),
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
