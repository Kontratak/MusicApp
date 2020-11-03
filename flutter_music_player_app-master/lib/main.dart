import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/musichome.dart';
import 'package:flutter_music_player_app/player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/home',
      routes: {
        '/home': (context) => MusicHome(),
        '/player': (context) => Player(),
      },
    );
  }
}