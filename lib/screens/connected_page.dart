import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class ConnectedPage extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectedPage({super.key, required this.device});

  @override
  State<ConnectedPage> createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
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
              (characteristic.properties.notify ||
                  characteristic.properties.indicate)) {
            await characteristic.setNotifyValue(true);
            _notificationSub = characteristic.value.listen((value) {
              final received = String.fromCharCodes(value).trim();
              if (received.isNotEmpty) {
                if (!mounted) return;
                setState(() => _messageHistory.insert(0, received));
                if (received.toLowerCase().contains("zona segura")) {
                  triggerAlert();
                }
              }
            });
            setState(() => targetCharacteristic = characteristic);
            return;
          }
        }
      }
    } catch (e) {
      print("❌ Error al descubrir servicios: $e");
    }
  }

  Future<void> triggerAlert() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 500);
      print("✅ Vibración activada");
    } else {
      print("⚠️ Este dispositivo no admite vibración");
    }
    await _audioPlayer.play(AssetSource('audio/zona_segura.mp3'));
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
    _audioPlayer.dispose();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Dispositivo Conectado',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          const Text('🔗 Conectado a:', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            widget.device.platformName.isNotEmpty ? widget.device.platformName : 'Dispositivo',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text("Desconectar"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white54),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('📥 Parámetros recibidos:', style: TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: _messageHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Text(
                    _messageHistory[index],
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
