import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothHelper {
  static void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  static void listenScanResults(void Function(List<ScanResult>) onData) {
    FlutterBluePlus.scanResults.listen(onData);
  }
}
