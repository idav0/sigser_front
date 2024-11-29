import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  // Controlador para la cámara
  MobileScannerController cameraController = MobileScannerController();

  // Variable para almacenar el código escaneado
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear QR"),
      ),
      body: Column(
        children: [
          // Vista de la cámara para escanear
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcodeCapture) {
                // Verificar que se haya detectado un código QR o de barras
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final barcode =
                      barcodeCapture.barcodes.first; // Obtén el primer código
                  if (barcode.rawValue != null) {
                    setState(() {
                      scannedCode =
                          barcode.rawValue; // Guardar el código escaneado
                    });

                    // Mostrar el código escaneado en un cuadro de diálogo
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Código Escaneado"),
                          content: Text(scannedCode!),
                          actions: <Widget>[
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
                }
              },
            ),
          ),

          // Si se ha escaneado un código, mostrarlo debajo de la cámara
          if (scannedCode != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Código Escaneado: $scannedCode",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          // Botón para alternar el flash
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await cameraController
                    .toggleTorch(); // No usar el valor de retorno
                setState(
                    () {}); // Actualizar el estado después de alternar el flash
              },
              child: const Text("Alternar Flash"),
            ),
          ),
        ],
      ),
    );
  }
}
