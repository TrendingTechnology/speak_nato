import "dart:async";

import 'package:speak_nato/nato.dart';
import 'package:speak_nato/preferences.dart';
import 'package:speak_nato/screens/settings_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

double textSize;

enum TtsState { playing, stopped }

class MainScreen extends StatefulWidget {
  NatoAppState createState() => new NatoAppState();
}

class NatoAppState extends State<MainScreen> {
  String _title = "Speak NATO";
  String _phonetizedText = "";

  FlutterTts tts = new FlutterTts();
  TtsState ttsState = TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() async {
    tts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    tts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    tts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  void onTextChanged(String str) {
    setState(() {
      _phonetizedText = phonetizeText(str);
    });
  }

  Future speak(String text) async {
    if (getLanguage() == null) {
      return;
    }

    await tts.setLanguage(await getLanguage());

    var result = await tts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future stop() async {
    var result = await tts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    // obtain settings
    getInitialValues();

    return new MaterialApp(
      title: _title,
      home: new Scaffold(
          appBar: new AppBar(title: new Text(_title), actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.view_list),
              onPressed: () {
                Navigator.of(context).pushNamed('/AlphabetScreen');
              },
            ),
            new IconButton(
                icon: new Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed('/SettingsScreen');
                })
          ]),
          body: new Container(
            padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
            child: new Column(children: <Widget>[
              new TextField(
                  autocorrect: false,
                  autofocus: true,
                  decoration: new InputDecoration(
                    hintText: 'type here...',
                  ),
                  textAlign: TextAlign.center,
                  maxLength: 60,
                  onChanged: (String str) {
                    onTextChanged(str);
                  },
                  onSubmitted: (String str) {
                    onTextChanged(str);
                  }),
              new Padding(
                padding: new EdgeInsets.only(top: 120.0),
              ),
              new Text(
                _phonetizedText,
                style: new TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          floatingActionButton: new FloatingActionButton(
              elevation: 0.0,
              child: new Icon(Icons.volume_up),
              onPressed: () {
                // separate words with a dot, so tts takes a pause in between words
                String text =
                    _phonetizedText.replaceAll(new RegExp(r' '), '. ');
                if (ttsState == TtsState.stopped) {
                  speak(text);
                } else {
                  stop();
                }
              })),
    );
  }
}
