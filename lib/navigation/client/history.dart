import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigser_front/modules/kernel/widgets/device_card.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<Map<String, dynamic>> devices = [];
  String searchText = '';
  String selectedDeviceType = 'Todos';
  String dateOrder = 'Más recientes';
  final List<String> dateOrderOptions = ['Más recientes', 'Más antiguos'];
  final List<String> deviceTypes = ['Todos', 'SMARTPHONE', 'LAPTOP', 'MONITOR'];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('listDevices');

    if (devicesJson != null) {
      try {
        List<dynamic> jsonList = jsonDecode(devicesJson);

        List<Map<String, dynamic>> adaptedDevices = jsonList.map((device) {
          final date = DateTime.parse(device['entry_date']);
          final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

          return {
            'id': device['id'],
            'tipo': device['device']['deviceType']['name'],
            'modelo': device['device']['model'],
            'marca': device['device']['brand'],
            'serie': device['device']['serialNumber'],
            'problema': device['problem_description'],
            'cliente': device['cliente'] ?? 'Desconocido',
            'fecha': formattedDate, 
            'diagnostico': device['diagnostic_observations'] ?? 'N/A',
            'estado': device['repairStatus']['name'],
          };
        }).toList();

        setState(() {
          devices.addAll(adaptedDevices);
        });
      } catch (e) {
        print('Error al cargar dispositivos: $e');
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
      final dateA = _parseDate(a['fecha']);
      final dateB = _parseDate(b['fecha']);
      return dateOrder == 'Más recientes'
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });

    return filtered;
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]), 
      int.parse(parts[1]), 
      int.parse(parts[0]), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: _showFilterMenu,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSearchBar(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredDevices.isEmpty
            ? const Center(
                child: Text(
                  'No hay dispositivos aún.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  final device = filteredDevices[index];
                  return DeviceCard(device: device);
                },
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.search, color: Color.fromARGB(255, 12, 18, 104)),
          ),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtrar por',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDeviceType,
                onChanged: (value) {
                  setState(() {
                    selectedDeviceType = value!;
                  });
                  Navigator.pop(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo de Dispositivo',
                  border: OutlineInputBorder(),
                ),
                items: deviceTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: dateOrder,
                onChanged: (value) {
                  setState(() {
                    dateOrder = value!;
                  });
                  Navigator.pop(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Orden de Fecha',
                  border: OutlineInputBorder(),
                ),
                items: dateOrderOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
