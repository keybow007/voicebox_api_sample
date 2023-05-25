import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voicebox_api_sample/home_screen.dart';
import 'package:voicebox_api_sample/view_model.dart';
import 'package:voicebox_api_sample/voice_box_manager.dart';

/*
* TODO VoiceBox（ずんだもんのAPI）を使ったサンプル
*  ・APIキーが不要な低速バージョンを使用
*   https://voicevox.su-shiki.com/su-shikiapis/ttsquest/
*   https://voicevox.hiroshiba.jp/
* */


void main() {
  runApp(
      MultiProvider(
        providers: [
          Provider<VoiceBoxManager>(
            create: (_) => VoiceBoxManager(),
          ),
          ChangeNotifierProvider<ViewModel>(
            create: (context) => ViewModel(
              voiceBoxManager: context.read<VoiceBoxManager>(),
            ),
          ),
        ],
        child: MyApp(),
      ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
