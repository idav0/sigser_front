import 'package:flutter/material.dart';
import 'package:sigser_front/navigation/technician/devices.dart';
import 'package:sigser_front/navigation/technician/history.dart';
import 'package:sigser_front/navigation/technician/profile.dart';
import 'package:sigser_front/navigation/technician/qr_scan.dart';

class NavigationTechnician extends StatefulWidget {
  const NavigationTechnician({super.key});

  @override
  State<NavigationTechnician> createState() => _NavigationTechnicianState();
}

class _NavigationTechnicianState extends State<NavigationTechnician> {

 int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
   QrScan(),
   Devices(),
   History(),
   Profile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }





  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Escanear QR',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.start),
            label: 'Dispositivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.start),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 5, 8, 167),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}