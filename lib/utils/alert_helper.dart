import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

String quitarTildes(String texto) {
  const acentos = 'áéíóúÁÉÍÓÚ';
  const sinAcentos = 'aeiouAEIOU';

  for (int i = 0; i < acentos.length; i++) {
    texto = texto.replaceAll(acentos[i], sinAcentos[i]);
  }
  return texto;
}

Future<void> triggerAlert(String message) async {
  // Vibración
  if (await Vibration.hasVibrator() == true) {
    Vibration.vibrate(duration: 1500);
  }

  // Audio
  final lower = quitarTildes(message.toLowerCase());
  if (lower.contains("zona segura")) {
    await _audioPlayer.play(AssetSource('audio/zona_segura.mp3'));
  } else if (lower.contains("acceso restringido")) {
    await _audioPlayer.play(AssetSource('audio/acceso_restringido.mp3'));
  } else if (lower.contains("riesgo electrico")) {
    await _audioPlayer.play(AssetSource('audio/riesgo_electrico.mp3'));
  } else if (lower.contains("materiales inflamables")) {
    await _audioPlayer.play(AssetSource('audio/materiales_inflamables.mp3'));
  } else if (lower.contains("escaleras")) {
    await _audioPlayer.play(AssetSource('audio/escaleras.mp3'));
  }
}
