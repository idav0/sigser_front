import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<Map<String, dynamic>> devices = []; // Lista dinámica para almacenar dispositivos

  String searchText = '';
  String selectedDeviceType = 'Todos';
  String dateOrder = 'Más recientes'; // Predeterminado
  final List<String> dateOrderOptions = ['Más recientes', 'Más antiguos'];
  final List<String> deviceTypes = ['Todos', 'SMARTPHONE', 'LAPTOP', 'MONITOR'];

  @override
  void initState() {
    super.initState();
    _loadDevices(); // Cargar dispositivos desde SharedPreferences
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('listDevices'); // Obtener el JSON almacenado

    if (devicesJson != null) {
      try {
        List<dynamic> jsonList = jsonDecode(devicesJson);

        // Adaptar datos al formato esperado
        List<Map<String, dynamic>> adaptedDevices = jsonList.map((device) {
          return {
            'id': device['id'],
            'tipo': device['device']['deviceType']['name'],
            'modelo': device['device']['model'],
            'marca': device['device']['brand'],
            'serie': device['device']['serialNumber'],
            'problema': device['problem_description'],
            'cliente': device['cliente'] ?? 'Desconocido', // Cliente opcional
            'fecha': device['entry_date'],
            'diagnostico': device['diagnostic_observations'] ?? 'N/A',
            'estado': device['repairStatus']['name'],
          };
        }).toList();

        setState(() {
          devices.addAll(adaptedDevices); // Agregar dispositivos adaptados
        });
      } catch (e) {
        print('Error al cargar dispositivos: $e'); // Manejo de errores
      }
    }
  }

  List<Map<String, dynamic>> get filteredDevices {
    List<Map<String, dynamic>> filtered = devices
        .where((device) =>
            device['estado'] == 'COLLECTED' &&
            (device['modelo']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                device['marca']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase())))
        .toList();

    if (selectedDeviceType != 'Todos') {
      filtered = filtered
          .where((device) => device['tipo'] == selectedDeviceType)
          .toList();
    }

    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['fecha']);
      final dateB = DateTime.parse(b['fecha']);
      return dateOrder == 'Más recientes' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  IconData _getDeviceIcon(String tipo) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Dispositivos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input de búsqueda en una fila independiente
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Dropdowns en una fila separada
            Row(
              children: [
                // Dropdown para tipo de dispositivo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDeviceType,
                    onChanged: (value) {
                      setState(() {
                        selectedDeviceType = value!;
                      });
                    },
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 14),
                    items: deviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Dropdown para orden de fecha
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: dateOrder,
                    onChanged: (value) {
                      setState(() {
                        dateOrder = value!;
                      });
                    },
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 14),
                    items: dateOrderOptions
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Lista de dispositivos filtrados
            Expanded(
              child: filteredDevices.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay dispositivos con estado COLLECTED.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, index) {
                        final device = filteredDevices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  _getDeviceIcon(device['tipo']),
                                  size: 50,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Modelo',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(device['modelo']),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Marca',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(device['marca']),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Fecha',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(device['fecha']),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  device['estado'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
