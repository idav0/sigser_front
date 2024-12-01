import 'package:flutter/material.dart';
import 'package:sigser_front/modules/kernel/widgets/device_utils.dart';

class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              DeviceUtils.getDeviceIcon(device['tipo']),
              size: 50,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Modelo', device['modelo']),
                _buildInfoColumn('Marca', device['marca']),
                _buildInfoColumn('Fecha', device['fecha']),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: DeviceUtils.getColorForEstado(device['estado']),
                  radius: 25,
                  child: Icon(
                    DeviceUtils.getEstadoIcon(device['estado']),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  device['estado'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(value),
      ],
    );
  }
}
