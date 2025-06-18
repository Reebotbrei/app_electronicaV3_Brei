import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import '../utils/alert_helper.dart';

class ConnectedPage extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectedPage({super.key, required this.device});

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  final List<String> _messageHistory = [];
  BluetoothCharacteristic? targetCharacteristic;
  StreamSubscription<List<int>>? _notificationSub;

  @override
  void initState() {
    super.initState();
    discoverServicesAndListen();
  }

  Future<void> discoverServicesAndListen() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() ==
                  "beb5483e-36e1-4688-b7f5-ea07361b26a8" &&
              (characteristic.properties.notify || characteristic.properties.indicate)) {
            await characteristic.setNotifyValue(true);
            _notificationSub = characteristic.value.listen((value) {
              final received = String.fromCharCodes(value).trim();
              if (received.isNotEmpty) {
                if (!mounted) return;
                setState(() => _messageHistory.insert(0, received));
                triggerAlert(received);
              }
            });
            setState(() => targetCharacteristic = characteristic);
            return;
          }
        }
      }
    } catch (_) {
      // Silenciado para evitar logs en producción
    }
  }

  void disconnect() async {
    await widget.device.disconnect();
    if (mounted) Navigator.pop(context);
  }

  void clearHistory() {
    setState(() => _messageHistory.clear());
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivo Conectado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpiar historial',
            onPressed: clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.bluetooth_connected, size: 100, color: Colors.cyanAccent),
          const SizedBox(height: 16),
          Text('🔗 Conectado a:', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            widget.device.platformName.isNotEmpty ? widget.device.platformName : 'Dispositivo',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text("Desconectar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('📥 Parámetros recibidos:', style: textTheme.titleSmall),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messageHistory.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Text(
                  _messageHistory[index],
                  style: textTheme.bodyLarge?.copyWith(color: Colors.greenAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
