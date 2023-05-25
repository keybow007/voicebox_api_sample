import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voicebox_api_sample/view_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final buttons = _createButtons(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.0),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                  hintText: "話したい言葉を入力して話者IDボタンを押してください"
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: buttons,
              ),
            ),

          ],
        ),
      ),
    );
  }

  List<Widget> _createButtons(BuildContext context) {
    return List.generate(
      9,
      (index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _speak(context, index),
          child: Text("話者ID：$index"),
        ),
      ),
    );
  }

  //TODO
  _speak(BuildContext context, int speakerId) {
    final vm = context.read<ViewModel>();
    vm.speak(speakerId, _textEditingController.text);
  }
}
