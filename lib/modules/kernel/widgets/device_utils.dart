import 'package:flutter/material.dart';
class DeviceUtils {
  static IconData getDeviceIcon(String tipo) {
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

  static IconData getEstadoIcon(String estado) {
    switch (estado) {
      case 'RECEIVED':
        return Icons.add_task;
      case 'DIAGNOSIS':
        return Icons.monetization_on_rounded;
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

  static Color getColorForEstado(String estado) {
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

  static String translateEstado(String estado) {
    switch (estado) {
      case 'RECEIVED':
        return 'Recibido';
      case 'DIAGNOSIS':
        return 'En diagnóstico';
      case 'QUOTATION':
        return 'Cotización';
      case 'WAITING_FOR_CUSTOMER_APPROVAL':
        return 'Esperando aprobación del cliente';
      case 'WAITING_FOR_PARTS':
        return 'Esperando piezas';
      case 'REPAIRING':
        return 'En reparación';
      case 'READY_FOR_COLLECTION':
        return 'Listo para recoger';
      case 'COLLECTED':
        return 'Recogido';
      default:
        return 'Desconocido';
    }
  }
}

