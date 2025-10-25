// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // Configura el volumen (puedes hacerlo configurable si quieres)
  AudioService() {
    _audioPlayer.setVolume(1.0);
    _audioPlayer.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
    });
  }

  // Reproduce el sonido de fin de Pomodoro
  Future<void> playPomodoroSound() async {
    try {
       // Si ya está sonando, detenerlo primero puede ser buena idea
       // aunque play() podría hacerlo implícitamente dependiendo de la versión.
      if (_isPlaying) {
         await _audioPlayer.stop();
      }
      // Usar AssetSource para archivos en assets/audio/
      await _audioPlayer.play(AssetSource('audio/pomodoro_ring.wav'));
      print(" Reproduciendo sonido pomodoro_ring.wav");
    } catch (e) {
      print('❌ Error al reproducir sonido: $e');
    }
  }

  // Detiene el sonido si está sonando
  Future<void> stopSound() async {
     if (_isPlaying) {
        try {
           await _audioPlayer.stop();
           print(" Sonido detenido.");
        } catch (e) {
           print('❌ Error al detener sonido: $e');
        }
     }
  }


  // Libera los recursos del reproductor
  void dispose() {
    _audioPlayer.dispose();
    print(" AudioService liberado.");
  }
}