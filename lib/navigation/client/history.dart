import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<Map<String, String>> devices = [
    {
      'id': '001',
      'tipo': 'Celular',
      'modelo': 'iPhone 14',
      'marca': 'Apple',
      'serie': 'SN12345',
      'problema': 'No enciende',
      'cliente': 'Juan Pérez',
      'fecha': '2024-11-20',
      'estado': 'Entregado',
      'diagnostico': 'El circuito de encendido está quemado.',
    },
    {
      'id': '002',
      'tipo': 'Computadora',
      'modelo': 'Laptop Pro X',
      'marca': 'TechBrand',
      'serie': 'SN98765',
      'problema': 'Pantalla dañada',
      'cliente': 'Ana López',
      'fecha': '2024-11-22',
      'estado': 'Entregado',
      'diagnostico': 'El panel LCD está roto y requiere reemplazo.',
    },
    {
      'id': '003',
      'tipo': 'Monitor',
      'modelo': 'Monitor 4K',
      'marca': 'DisplayCorp',
      'serie': 'SN112233',
      'problema': 'Sin señal',
      'cliente': 'Carlos Méndez',
      'fecha': '2024-11-25',
      'estado': 'Entregado',
      'diagnostico': 'El cable HDMI está dañado y necesita ser reemplazado.',
    },
  ];

  String searchText = '';
  String selectedDeviceType = 'Todos';
  String dateOrder = 'Más recientes'; // Predeterminado
  List<String> dateOrderOptions = ['Más recientes', 'Más antiguos'];

  List<String> deviceTypes = ['Todos', 'Celular', 'Computadora', 'Monitor'];

  List<Map<String, String>> get filteredDevices {
    List<Map<String, String>> filtered = devices
        .where((device) =>
            device['estado'] == 'Entregado' &&
            (device['modelo']!.toLowerCase().contains(searchText.toLowerCase()) ||
                device['marca']!.toLowerCase().contains(searchText.toLowerCase()) ||
                device['cliente']!.toLowerCase().contains(searchText.toLowerCase())))
        .toList();

    if (selectedDeviceType != 'Todos') {
      filtered = filtered
          .where((device) => device['tipo'] == selectedDeviceType)
          .toList();
    }

    filtered.sort((a, b) {
      final dateA = a['fecha']!;
      final dateB = b['fecha']!;
      return dateOrder == 'Más recientes'
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });

    return filtered;
  }

  IconData _getDeviceIcon(String tipo) {
    switch (tipo) {
      case 'Celular':
        return Icons.phone_iphone;
      case 'Computadora':
        return Icons.laptop;
      case 'Monitor':
        return Icons.desktop_mac;
      case 'Tablet':
        return Icons.tablet;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Registrados'),
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
                        'No hay dispositivos que coincidan con los filtros.',
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
                                  _getDeviceIcon(device['tipo']!),
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
                                        Text(device['modelo']!),
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
                                        Text(device['marca']!),
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
                                        Text(device['fecha']!),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  device['estado']!,
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
