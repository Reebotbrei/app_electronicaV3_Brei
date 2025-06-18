import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../utils/alert_helper.dart';

class WifiConnectedPage extends StatefulWidget {
  const WifiConnectedPage({super.key});

  @override
  State<WifiConnectedPage> createState() => _WifiConnectedPageState();
}

class _WifiConnectedPageState extends State<WifiConnectedPage> {
  final List<String> _messageHistory = [];
  bool _isConnected = false;
  Timer? _pollingTimer;

  final String esp32Url = 'http://192.168.18.188/data';

  @override
  void initState() {
    super.initState();
    startPolling();
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchMessageFromESP32());
  }

  String quitarTildes(String texto) {
  const acentos = 'áéíóúÁÉÍÓÚ';
  const sinAcentos = 'aeiouAEIOU';

  for (int i = 0; i < acentos.length; i++) {
    texto = texto.replaceAll(acentos[i], sinAcentos[i]);
  }
  return texto;
}

  Future<void> fetchMessageFromESP32() async {
    try {
      final response = await http.get(Uri.parse(esp32Url));
      if (response.statusCode == 200) {
        setState(() => _isConnected = true);
        final json = jsonDecode(response.body);     //Decodifica el JSON
        final String rawMessage = json['mensaje'] ?? ''; //Extrae el mensaje
        final lower = quitarTildes(rawMessage.toLowerCase());

        final palabrasClave = [
          'zona segura',
          'acceso restringido',
          'riesgo eléctrico',
          'materiales inflamables',
          'escaleras',
        ];

        for (String palabra in palabrasClave) {
          if (lower.contains(palabra)) {
            if (mounted) {
              setState(() => _messageHistory.insert(0, palabra));
              triggerAlert(palabra);
            }
            break;
          }
        }
      } else {
        setState(() => _isConnected = false);
      }
    } catch (_) {
      setState(() => _isConnected = false);
    }
  }

  void clearHistory() {
    setState(() => _messageHistory.clear());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
          const Icon(Icons.wifi, size: 100, color: Colors.cyanAccent),
          const SizedBox(height: 16),
          Text('🔗 Conectado a:', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            _isConnected ? 'ESP32_Cam_AI' : 'Conectando...',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
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
