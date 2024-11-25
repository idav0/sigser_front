import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScan extends StatefulWidget {
  const QrScan({Key? key}) : super(key: key);

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cámara de escaneo como fondo
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          // Marco decorativo para el área de escaneo
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75, // 75% del ancho de la pantalla
              height: MediaQuery.of(context).size.width * 0.75, // 75% del ancho de la pantalla
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xff172554),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Título decorativo en la parte superior
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1, // 10% de la altura de la pantalla
            left: 0,
            right: 0,
            child: Text(
              'Escanea tu código QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.08, // Tamaño de texto proporcional
                fontWeight: FontWeight.bold,
                color: Color(0xff172554),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Procesar el código escaneado
      print('Código escaneado: ${scanData.code}');
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
