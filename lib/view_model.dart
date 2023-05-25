import 'package:flutter/foundation.dart';
import 'voice_box_manager.dart';

class ViewModel extends ChangeNotifier {
  final VoiceBoxManager voiceBoxManager;

  ViewModel({required this.voiceBoxManager});

  void speak(int speakerId, String text) {
    voiceBoxManager.speak(speakerId, text);
  }



}