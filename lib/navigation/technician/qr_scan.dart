import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sigser_front/modules/kernel/widgets/complete_repair_form_screen.dart';
import 'package:sigser_front/modules/kernel/widgets/repair_form_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  final Dio dio = Dio();
  bool isModalVisible = false;

  Future<void> _fetchRepairDetails(int id) async {
    if (isModalVisible) return;

    final String url = '${dotenv.env['BASE_URL']}/repair/$id';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final repairData = response.data['data'];

        if (repairData != null) {
          final repairStatus = repairData['repairStatus']['name'];
          _showActionModal(repairData, repairStatus);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Datos de reparación no encontrados.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  void _showActionModal(Map<String, dynamic> repairData, String repairStatus) {
    setState(() {
      isModalVisible = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        String modalTitle = '';
        String modalDescription = '';
        VoidCallback? action;

        switch (repairStatus) {
          case 'DIAGNOSIS':
            modalTitle = 'Crear Reporte';
            modalDescription = 'Puedes crear un reporte para esta reparación.';
            action = () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RepairFormScreen(repairId: repairData['id']),
                ),
              ).then((_) {
                setState(() {
                  isModalVisible = false;
                });
              });
            };
            break;

          case 'RECEIVED':
            modalTitle = 'Iniciar Diagnóstico';
            modalDescription =
                '¿Deseas iniciar el diagnóstico para esta reparación?';
            action = () {
              Navigator.pop(context);
              _startDiagnostic(repairData['id']);
            };
            break;

          case 'QUOTATION':
            modalTitle = 'Aprobar Cotización';
            modalDescription =
                'La reparación está en cotización. ¿Deseas aprobarla?';
            action = () {
              Navigator.pop(context); // Cerrar el modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cotización aprobada.')),
              );
            };
            break;

          case 'WAITING_FOR_CUSTOMER_APPROVAL':
            modalTitle = 'Esperando Aprobación del Cliente';
            modalDescription =
                'Estamos esperando la aprobación del cliente para continuar.';
            action = () {
              Navigator.pop(context); // Cerrar el modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificando al cliente...')),
              );
            };
            break;

          case 'WAITING_FOR_PARTS':
            modalTitle = 'Esperando Piezas';
            modalDescription = '¿Deseas marcar como listas?';
            action = () {
              Navigator.pop(context);
              _startRepair(repairData['id']);
            };
            break;

          case 'REPAIRING':
            modalTitle = 'Finalizar Reparación';
            modalDescription =
                'La reparación está en progreso. ¿Deseas finalizarla?';
            action = () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompleteRepairFormScreen(repairId: repairData['id']),
                ),
              ).then((_) {
                setState(() {
                  isModalVisible = false;
                });
              });
            };
            break;

          case 'READY_FOR_COLLECTION':
            modalTitle = 'Reparación Lista';
            modalDescription =
                'La reparación está lista para ser recogida. ¿Deseas marcar como lista para entrega?';
            action = () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Reparación marcada como entregada.')),
              );
            };
            break;

          default:
            modalTitle = 'Estado Desconocido';
            modalDescription =
                'No se puede realizar ninguna acción para este estado.';
            action = null;
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            modalTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                modalDescription,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (action != null)
                ElevatedButton(
                  onPressed: action,
                  child: const Text('Confirmar'),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isModalVisible = false;
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        isModalVisible = false;
      });
    });
  }

  Future<void> _startDiagnostic(int deviceId) async {
    final String url =
        '${dotenv.env['BASE_URL']}/repair/status/start-diagnostic/$deviceId';

    try {
      final response = await dio.put(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnóstico iniciado correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al iniciar diagnóstico: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }

  Future<void> _startRepair(dynamic repairId) async {
    final String url =
        '${dotenv.env['BASE_URL']}/repair/status/start-repair/${repairId.toString()}';

    try {
      final response = await dio.put(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reparación iniciada correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error al iniciar reparación: ${response.statusMessage}'),
          ),
        );
      }
    } on DioError catch (e) {
      if (e.response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error del servidor: ${e.response?.data['detail'] ?? 'Error desconocido'}',
            ),
          ),
        );
      } else {
        debugPrint('Error en la solicitud: ${e.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar con el servidor: ${e.message}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error inesperado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear QR")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcodeCapture) {
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final barcode = barcodeCapture.barcodes.first;
                  if (barcode.rawValue != null) {
                    setState(() {
                      scannedCode = barcode.rawValue;
                    });

                    final RegExp idRegex = RegExp(r'id=(\d+)');
                    final Match? match = idRegex.firstMatch(scannedCode!);

                    if (match != null) {
                      final int id = int.parse(match.group(1)!);
                      _fetchRepairDetails(id);
                    }
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await cameraController.toggleTorch();
              },
              child: const Text("Flash"),
            ),
          ),
        ],
      ),
    );
  }
}
