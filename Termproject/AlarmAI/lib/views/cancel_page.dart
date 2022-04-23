import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:alan_voice/alan_voice.dart';


class cancel_page extends StatelessWidget {
  final String payload;


  const cancel_page({
    this.payload,
  });

  static AudioCache musicCache;
  static AudioPlayer instance;


  void playLoopedMusic(String songName) async {
    musicCache = AudioCache();
    //instance = await musicCache.loop("a_long_cold_sting.wav");
    instance = await musicCache.loop(songName);
    await instance.setVolume(1.0);
  }

  void pauseMusic() {
    instance?.pause();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm').format(now);

    String mission = payload.split(',').first;
    if(mission==null || mission.isEmpty || mission=='null') {
      print("mission empty");
      mission='';
    }
    else
      print(mission);

    String songName = payload.split(',').last;
    if(songName != '' && songName!=null && songName.isEmpty==true) {
      print("song empty");
      // default if nothing have been selected (first alarm)
      songName = "a_long_cold_sting.wav";
    }
    else
      print(songName);

    playLoopedMusic(songName);

    if(mission.isNotEmpty){
      return Scaffold(
          backgroundColor: Colors.blueGrey[700],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 64),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                      mission,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24),
                      textAlign: TextAlign.center

                  ),
                ),
                Flexible(
                  flex: 1,
                  child: FloatingActionButton.extended(
                      label: Text('Challenge'),
                      onPressed: () {
                        Sendata(mission);
                      }
                  ),
                ),
              ],
            ),
          )
      );
    }
    else {
      return Scaffold(
          backgroundColor: Colors.blueGrey[700],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 64),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: FloatingActionButton.extended(
                      label: Text('Cancel'),
                      onPressed: () {
                        pauseMusic();
                        Navigator.of(context).popUntil((route) =>
                        route.isFirst);
                      }
                  ),
                )
              ],
            ),
          )
      );
    }
  }


  //send mission to alan
  void Sendata(String msg) async{
    var isActive = await AlanVoice.isActive();
    if (isActive){
      AlanVoice.activate();
    }

    var params = jsonEncode({"read": msg, "count": 0});
    AlanVoice.callProjectApi("script::getMission", params);
  }

}

