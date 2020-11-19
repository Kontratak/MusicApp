import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flip_card/flip_card.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deneme2/constants.dart';
import 'package:flutter/material.dart';
import 'package:need_resume/need_resume.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Player extends StatefulWidget {
  Player({Key key,this.songName,this.singer,this.image,this.duration, this.songPath, this.player, this.playlistsongs, this.index}) : super(key: key);

  final String songName;
  final String singer;
  final String image;
  final String duration;
  final String songPath;
  final AudioPlayer player;
  final List<Song> playlistsongs;
  final int index;
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends ResumableState<Player> with SingleTickerProviderStateMixin{

  int durationOnPause = 0;
  double _value = 0.0;
  String title;
  String artist;
  String albumImage;
  String songduration;
  String url;
  AudioPlayer audioPlayer;
  List<Song> songs;
  int index;
  String durationnow = "0";
  String lyrics;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerDurationSubscription;
  GlobalKey<FlipCardState> cardKey;
  bool lyricsfetched = false;
  @override
  void onResume() {
    // Implement your code inside here

   audioPlayer.setUrl(songs[index].url);
   audioPlayer.seek(Duration(milliseconds: durationOnPause));
  }

  @override
  void onPause() {
    // Implement your code inside here

    print('HomeScreen is paused!');
  }

  AnimationController animationController;
  bool isPlaying = true;

  Duration _duration;
  Duration _position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //müziğin detaylarını alıyorum
    title = widget.songName;
    artist = widget.singer;
    albumImage = widget.image;
    songduration = widget.duration;
    url = widget.songPath;
    audioPlayer = widget.player;
    songs = widget.playlistsongs;
    index = widget.index;
    songduration = widget.duration;
    print(index);
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) async{
          if(index != songs.length-1)
            await audioPlayer.play(songs[++index].url, isLocal: true);
          else if(index == songs.length-1){
            index = 0;
            await audioPlayer.play(songs[index].url, isLocal: true);
          }
          setState(() {
            title = songs[index].title;
            artist = songs[index].artist;
            songduration = songs[index].duration;
            durationnow = "0";
          });
        });
    _playerDurationSubscription = audioPlayer.onAudioPositionChanged.listen((Duration  p) => {
        setState(() {
          durationnow = p.inMilliseconds.toString();
          durationOnPause = p.inMilliseconds;
          durationnow = formatMillitoDisplay(durationnow);
        }),
    });
    _positionSubscription =
        audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          _position = p;
        }));
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    audioPlayer.play(url, isLocal: true); //başlangıçta tıklanınca gelinen dosya yolunu alıp oynatıyorum
    cardKey = GlobalKey<FlipCardState>();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  //feature olarak zaten alıyoduk ben sadece albums kısmına çekilecek şekilde yaptım
//Player kısmına geçerken parametre olarak getiriyorum yani müzik listesindeki bi iteme tıkladığında çekip player'a gönderiyor
  Future<String> _getSongLyrics(String title,String artist) async {
    title = title.replaceAll(' ', "%20");
    artist = artist.replaceAll(' ', "%20");
    var songlyric;
    final String uri = "https://orion.apiseeds.com/api/music/lyric/$artist/$title?apikey=uF0lVgHOgQTMZGpYbS5IOzngYwfnqXM33tWCzlPsOtOOcC67CT23mLAEdepBypRn";
    print(uri);
    final responseData = await http.get(uri,headers: {"Accept": "application/json"});
    if(responseData.statusCode == 200){
      var convertToJson = jsonDecode(responseData.body);
      if(convertToJson!=null)
        songlyric = convertToJson['result']['track']['text'];
      print(songlyric);
    }
    else{
      songlyric = "Lyrics Not Found";
    }
    return songlyric;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                      onTap:(){
                        Navigator.pop(context);
                      },//geri tuşuna basıldığında songs kısmına dönmek için
                      child: Icon(Icons.arrow_back_ios, color: Colors.black,)),
                  Text("NOW PLAYING", style: TextStyle(
                      fontFamily: 'Nunito-Bold',
                      letterSpacing: 1.0,
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                  Icon(Icons.more_vert, color: Colors.black,)
                ],
              ),
            ),

            SizedBox(height: 20.0,),
            FlipCard(
              key: cardKey,
              flipOnTouch: false,
              front: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(albumImage, fit: BoxFit.cover, //müziğin resmi
                  height: 300,
                  width: 300,),
              ),
              back: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), //buradaki cliprrectin içine yazıyı yaz
                child: Container(
                  height: 300,
                  width: 300,
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: _setLyricsStatus(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            SizedBox(height: 20.0,),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  color: Colors.orange.withOpacity(0.5),
                  width: 160,
                  child: InkWell(
                    onTap: () async{
                      var connectivityResult = await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        lyrics = "You're not Connected To Internet";
                      } else {
                        if(lyricsfetched == false){
                          _getSongLyrics(title,artist).then((String result){
                            setState(() {
                              lyrics = result;
                              lyricsfetched = true;
                            });
                          });
                        }
                      }
                      cardKey.currentState.toggleCard();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8,left: 8),
                      child: Row(
                        children: [
                          Icon(Icons.music_note_outlined),
                          SizedBox(width: 10,),
                          Text("Tap To See The Lyrics!" , style: TextStyle( //müzik başlığı
                              fontFamily: 'Nunito-Bold',
                              letterSpacing: 1.0,
                              fontSize: 8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0,),
            Text(title.length > 20 ? title.substring(0,20) : title, style: TextStyle( //müzik başlığı
                fontFamily: 'Nunito-Bold',
                letterSpacing: 1.0,
                fontSize: 35,
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10.0,),
            Text(artist, style: TextStyle( //şarkıcı
              fontFamily: 'Nunito-Bold',
              letterSpacing: 1.0,
              fontSize: 15,
              color: Colors.black,
            ),),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Row(
                children: [
                  Text(durationnow, style: TextStyle( //şarkıcı
                    fontFamily: 'Nunito-Bold',
                    letterSpacing: 1.0,
                    fontSize:10,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-100,
                    child: Slider(
                      activeColor: Colors.orangeAccent,
                      value: (_position != null &&
                          _duration != null &&
                          _position.inMilliseconds > 0 &&
                          _position.inMilliseconds < _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                      inactiveColor: Colors.grey,
                      onChanged: (v) {
                        final Position = v * _duration.inMilliseconds;
                        audioPlayer.seek(Duration(milliseconds: Position.round()));
                        durationnow = Position.toString();
                        durationnow = formatMillitoDisplay(durationnow);
                      },
                    ),
                  ),
                  Text(formatMillitoDisplay(songduration), style: TextStyle( //şarkıcı
                    fontFamily: 'Nunito-Bold',
                    letterSpacing: 1.0,
                    fontSize: 10,
                    color: Colors.black,
                  ),),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0,bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                      onTap : () async{ //geri tuşu
                        index--;
                        if(index > 0) {
                          await audioPlayer.play(songs[index].url, isLocal: true);
                          lyrics = null;
                          lyricsfetched = false;
                          if(cardKey.currentState.isFront == false)
                            cardKey.currentState.toggleCard();
                        }
                        else if(index == -1){
                          index = 0;
                        }
                        setState(() { //tıklandığında müziğin isminin, albüm resminin ve sarkıcısının değişmesi
                          title = songs[index].title;
                          artist = songs[index].artist;
                          MusicProp.musicname = title;
                          MusicProp.musicartist = artist;
                          songduration = songs[index].duration;
                          formatMillitoDisplay(songduration);
                        });
                        print(index);
                      },
                      child: CircleAvatar(
                          backgroundColor: Colors.white10,
                          radius: 20.0,
                          child:  Icon(Icons.fast_rewind, color: Colors.black,)),
                      ),
                  CircleAvatar(
                    backgroundColor: Colors.black87,
                    radius: 40.0,
                    child: IconButton(
                      iconSize: 50,
                      color: Colors.white,
                      icon: AnimatedIcon(icon: AnimatedIcons.pause_play, progress: animationController),
                      onPressed: () async{
                        _handleOnPressed();
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      index++;//ileri gitmek için geri gitmeyle aynı
                      if(index < songs.length) {
                        await audioPlayer.play(songs[++index].url, isLocal: true);
                        lyrics = null;
                        lyricsfetched = false;
                        if(cardKey.currentState.isFront == false)
                          cardKey.currentState.toggleCard();
                      }
                      else if(index == songs.length){
                        index = songs.length-1;
                      }
                      setState(() {
                        title = songs[index].title;
                        artist = songs[index].artist;
                        MusicProp.musicname = title;
                        MusicProp.musicartist = artist;
                        songduration = songs[index].duration;
                        formatMillitoDisplay(songduration);
                      });
                    },
                      child: CircleAvatar(
                        backgroundColor: Colors.white10,
                        radius: 20.0,
                        child:  Icon(Icons.fast_forward, color: Colors.black,)
                        ),
                      ),
                ],
              ),
            )
          ],
        ),

      ),
    );
  }

  Widget _setLyricsStatus(){
    if(lyrics == null)
      return Padding(
        padding: const EdgeInsets.only(top: 110),//boyut/2-45
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10,),
            Text("Loading Lyrics" , style: TextStyle( //müzik başlığı
            fontFamily: 'Nunito-Bold',
            letterSpacing: 1.0,
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),),
          ],
        ),
      );
    else if(lyrics == "You're not Connected To Internet"){
      return Padding(
        padding: const EdgeInsets.only(top: 130),//boyut/2-45
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("You're not Connected To Internet" , style: TextStyle( //müzik başlığı
                fontFamily: 'Nunito-Bold',
                letterSpacing: 1.0,
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),),
          ],
        ),
      );
    }
    else
      return Text(lyrics , style: TextStyle( //müzik başlığı
          fontFamily: 'Nunito-Bold',
          letterSpacing: 1.0,
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold
      ),);
  }

  String formatMillitoDisplay(String toformat){
      Duration duration = new Duration(minutes: 0,seconds: 0,milliseconds: int.parse(toformat));
      String durationstring =  duration.toString().split('.')[0];
      List<String> durationlist = durationstring.split(':');
      return durationlist[1]+":"+durationlist[2];
  }



  Future<bool> _onBackPressed() async{
    Navigator.pop(context); //geri tuşuna basıldığında songs kısmına dönmek için
    return true;
  }

  void _handleOnPressed(){ //oynat durdur basıldığında çalışan kısım
    setState(() async {
      isPlaying = !isPlaying;
      if(isPlaying == true){
        await audioPlayer.resume();
        animationController.reverse();
      }
      else{
        await audioPlayer.pause();
        animationController.forward();
      }
    });
  }
}
