import 'package:flutter/material.dart';
import 'package:app_electronica/screens/bluetooth_scan_page.dart';
import 'package:app_electronica/screens/wifi_connected_page.dart';
import 'package:app_electronica/widgets/connection_mode_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar modo de conexión'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ConnectionModeCard(
            icon: Icons.bluetooth,
            title: 'Modo Bluetooth',
            description: 'Conéctate al ESP32-CAM vía BLE',
            color: Colors.cyanAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BluetoothScanPage()),
              );
            },
          ),
          ConnectionModeCard(
            icon: Icons.wifi,
            title: 'Modo WiFi',
            description: 'Consulta señalización desde red local',
            color: Colors.greenAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WifiConnectedPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
