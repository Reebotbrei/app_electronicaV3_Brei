import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../screens/connected_page.dart';

class DeviceTile extends StatelessWidget {
  final ScanResult result;

  const DeviceTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return DeviceTileWidget(result: result);
  }
}

class DeviceTileWidget extends StatefulWidget {
  final ScanResult result;

  const DeviceTileWidget({super.key, required this.result});

  @override
  State<DeviceTileWidget> createState() => _DeviceTileWidgetState();
}

class _DeviceTileWidgetState extends State<DeviceTileWidget> {
  BluetoothDevice get device => widget.result.device;

  void connectAndNavigate() async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Conectado a ${device.platformName.isNotEmpty ? device.platformName : 'Dispositivo'}',
          ),
        ),
      );

      ('🧭 Redirigiendo a ConnectedPage');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectedPage(
            device:device
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    }
  }

  void showConnectionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Conectar a ${device.platformName.isNotEmpty ? device.platformName : 'Dispositivo'}',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Deseas conectarte a este dispositivo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              connectAndNavigate();
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.cyanAccent),
        title: Text(
          device.platformName.isNotEmpty
              ? device.platformName
              : 'Dispositivo Desconocido',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          device.remoteId.toString(),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          widget.result.rssi.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        onTap: showConnectionDialog,
      ),
    );
  }
}
