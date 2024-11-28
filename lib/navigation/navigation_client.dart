import 'package:flutter/material.dart';
import 'package:sigser_front/navigation/client/devices_client.dart';
import 'package:sigser_front/navigation/client/history.dart';
import 'package:sigser_front/navigation/client/pending_payment_devices.dart';
import 'package:sigser_front/navigation/client/profile.dart';


class NavigationClient extends StatefulWidget {
  const NavigationClient({super.key});

  @override
  State<NavigationClient> createState() => _NavigationClientState();
}

class _NavigationClientState extends State<NavigationClient> {
 int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
   DevicesClient(),
   PendingPaymentDevices(),
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
            icon: Icon(Icons.devices),
            label: 'Mis dispositivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.paid),
            label: 'Pagos Pendientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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