import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_helper.dart';
import '../widgets/device_tile.dart';

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({super.key});

  @override
  State<BluetoothScanPage> createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  List<ScanResult> scanResults = [];

  void startScan() {
    BluetoothHelper.startScan();
    BluetoothHelper.listenScanResults((results) {
      if (!mounted) return;
      setState(() {
        scanResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos disponibles'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: startScan,
            child: const Text('🔍 Iniciar Escaneo'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                return DeviceTile(result: scanResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
