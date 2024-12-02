import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sigser_front/modules/kernel/widgets/device_card.dart';
import 'package:sigser_front/modules/kernel/widgets/device_details_modal.dart';

class Devices extends StatefulWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final List<Map<String, dynamic>> devices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDevicesFromPreferences();
  }

  Future<void> _loadDevicesFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString('listDevices');

      if (devicesJson != null) {
        final List<dynamic> jsonList = jsonDecode(devicesJson);

        final List<Map<String, dynamic>> adaptedDevices = jsonList
            .where((device) => device['repairStatus']['name'] != 'COLLECTED')
            .map((device) {
          final deviceData = device['device'] ?? {};
          final repairStatus = device['repairStatus'] ?? {};

          return {
            'id': device['id']?.toString() ?? '',
            'tipo': deviceData['deviceType']?['name']?.toString() ?? 'Desconocido',
            'modelo': deviceData['model']?.toString() ?? 'Desconocido',
            'marca': deviceData['brand']?.toString() ?? 'Desconocido',
            'serie': deviceData['serialNumber']?.toString() ?? 'Desconocido',
            'problema': device['problem_description']?.toString() ?? 'N/A',
            'cliente': device['cliente']?.toString() ?? 'Desconocido',
            'fecha': device['entry_date']?.toString() ?? 'N/A',
            'diagnostico': device['diagnostic_observations']?.toString() ?? 'N/A',
            'estado': repairStatus['name']?.toString() ?? 'Sin estado',
          };
        }).toList();

        setState(() {
          devices.clear();
          devices.addAll(adaptedDevices);
        });
      }
    } catch (e) {
      _showSnackBar('Error al cargar dispositivos: $e');
    }
  }

  Future<void> _performNetworkAction(
      String repairId, String endpoint, String successMessage) async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final authority = prefs.getString('rol') ?? '';
      final userId = prefs.getInt('id') ?? 0;

      final String url = '${dotenv.env['BASE_URL']}/repair/status/$endpoint/$repairId';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final String devicesUrl = authority == "TECHNICIAN"
            ? '${dotenv.env['BASE_URL']}/repair/technician/$userId'
            : '${dotenv.env['BASE_URL']}/repair/client/$userId';

        final devicesResponse = await http.get(
          Uri.parse(devicesUrl),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (devicesResponse.statusCode == 200) {
          final devicesData = jsonDecode(devicesResponse.body);
          _saveDevices(devicesData); 
          _loadDevicesFromPreferences(); 
          _showSnackBar(successMessage);
        } else {
          _showSnackBar('Error al actualizar dispositivos.');
        }
      } else {
        _showSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error al conectar con el servidor: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _startDiagnostic(String repairId) async {
    await _performNetworkAction(
        repairId, 'start-diagnostic', 'Diagnóstico iniciado correctamente.');
  }

  Future<void> _startRepair(String repairId) async {
    await _performNetworkAction(
        repairId, 'start-repair', 'Reparación iniciada correctamente.');
  }

  void _saveDevices(devices) async {
    final prefs = await SharedPreferences.getInstance();
    final listDevices = jsonEncode(devices['data']);
    await prefs.setString('listDevices', listDevices);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDiagnosticModal(BuildContext context, Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => DeviceDetailsModal(
        device: device,
        onDiagnosticStart: () => _startDiagnostic(device['id']),
        onRepairStart: () => _startRepair(device['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Registrados'),
      ),
      body: Stack(
        children: [
          devices.isEmpty
              ? const Center(child: Text('No hay dispositivos disponibles.'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return GestureDetector(
                      onTap: () => _showDiagnosticModal(context, device),
                      child: DeviceCard(device: device),
                    );
                  },
                ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
