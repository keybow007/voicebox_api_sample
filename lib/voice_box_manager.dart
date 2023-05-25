/*
* TODO WEB版VOICEVOX APIの実装
*
* WEB版VOICEVOX API（低速）
* https://voicevox.su-shiki.com/su-shikiapis/ttsquest/
*
* TODO 「レスポンスを受け取った段階では音声の合成が完了していないことがあります」とあるので以下の手順を取る
*   => 音声ファイルをすぐに再生しても失敗する場合があるので
* １．WEB版VOICEVOXにリクエスト
* ２．レスポンスを受け取って、audioIdとmp3ファイルのURL取得
* ３．１で取得したaudioIdから音声ファイルのステータスをリクエスト => レスポンス受け取り
* ４−１．２でisAudioReady: trueの場合 => ３で取得したmp3ファイルを再生
* ４−２．２でisAudioReady: falseの場合 => １秒後に再度２を実行（リトライ５回まで）
*   => 不思議なことに数秒経ったらisAudioReady = falseでも音がなるようなので
*
* TODO サイトに記載の「話者ID」の番号が誰に該当するのかはわからなかった
* => 50くらいまでやっても音声ファイルができた（キャラクター数と一致しない）が、
*   たぶん各キャラクターの音声スタイル毎に話者IDが振られているような感じがするのでここはご自身で調べてください
*   （ずんだもんの「ノーマル」と「あまあま」では話者IDが異なるのではなかろうか）
*   => とりあえずサンプルでは９つ（0〜8）を使いました
* */

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class VoiceBoxManager {
  final String baseUrlForSoundFile = "https://api.tts.quest/v1/voicevox/";
  final String baseUrlForSoundStatus = "https://audio1.tts.quest/v1/download/";

  final audioPlayer = AudioPlayer();

  void speak(int speakerId, String text) async {
    //1. WEB版VOICEVOXにリクエスト
    final soundFileResponse = await getSoundFile(speakerId, text);

    if (soundFileResponse == null) {
      //１に失敗した場合
      Fluttertoast.showToast(msg: "音声ファイルの取得に失敗しました");
      //print("音声ファイルの取得に失敗しました");
      return;
    }
    //2. レスポンスを受け取って、audioIdとmp3ファイルのURL取得
    final baseJson = jsonDecode(soundFileResponse);
    final audioId = baseJson["audioId"];
    final soundUrl = baseJson["mp3DownloadUrl"];

    //３．１で取得したaudioIdから音声ファイルのステータスをリクエスト
    _play(audioId, soundUrl);

  }

  Future<String?> getSoundFile(int speakerId, String text) async {
    /*
    * https://api.tts.quest/v1/voicevox/?text=読み上げる文&speaker=1
    * https://voicevox.su-shiki.com/su-shikiapis/ttsquest/
    * */
    final requestUrl =
        Uri.parse(baseUrlForSoundFile + "?text=$text&speaker=$speakerId");
    final response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  void _play(String audioId, String soundUrl) async {
    /*
    * 「レスポンスを受け取った段階では音声の合成が完了していないことがあります」とあるので二段階踏む必要あり
    *   => 音声ファイルをすぐに再生しても失敗する場合がある
    *   audioIdから音声ファイルのステータスをリクエスト
    *     isAudioReady: trueの場合 => ３で取得したmp3ファイルを再生
    *     isAudioReady: falseの場合 => １秒後に再度２を実行（リトライ回数は一応３回までにしている）
    *       => リトライしつくしてもtrueにならない場合でも無理やり鳴らしに行こう（大抵の場合は鳴った：）
    * */
    final requestUrl = Uri.parse(baseUrlForSoundStatus + "$audioId.json");
    final maxTryCount = 3;

    for (int tryCount = 0; tryCount < maxTryCount; tryCount++) {
      final response = await http.get(requestUrl);
      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        final isAudioReady = decodedJson["isAudioReady"];
        if (isAudioReady) {
          _playSound(soundUrl);
          return;
          //return true;
        }
        //失敗した場合は１秒待って再トライ
        Fluttertoast.showToast(msg: "音の準備まだできていません（試行回数）: $tryCount / $maxTryCount回目");
        //print("音の準備まだできてない（試行回数）: $tryCount");
        await Future.delayed(Duration(seconds: 2));
        continue;
      } else {
        //失敗した場合は１秒待って再トライ
        Fluttertoast.showToast(msg: "音の準備まだできていません（試行回数）: $tryCount / $maxTryCount回目");
        //print("音の準備まだできてない（試行回数）: $tryCount");
        await Future.delayed(Duration(seconds: 2));
        continue;
      }
    }
    //リトライ５回してtrueにならない場合でも無理やり鳴らしに行こう（大抵の場合は鳴った）
    //このToastをそのままユーザーに見せないように（文言は考えてください）
    Fluttertoast.showToast(msg: "$maxTryCount回試行してもダメだったので無理やり鳴らしにいきます");
    _playSound(soundUrl);
  }

  //４．音声ファイルの準備ができたら再生
  void _playSound(String soundUrl) async {
    //https://pub.dev/packages/just_audio#quick-synopsis
    await audioPlayer.setUrl(soundUrl);
    audioPlayer.play();
  }
}
