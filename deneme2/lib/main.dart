import 'package:audioplayers/audioplayers.dart';
import 'package:deneme2/Player.dart';
import 'package:deneme2/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //audioquery class ını çağırıyorum
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  //müzikleri tutacak song sınıfından list oluşturuyorum müzikleri bu listeye çekicem
  List<Song> songs = [];
  //eğer müzik eklenmişse true oluyor bikaç defa çağırıldığından dolayı belirledim
  bool songsadded = false;
  //müzik oynatma sınıfı
  AudioPlayer audioPlayer = AudioPlayer();
  AnimationController animationController;
  bool isPlaying = false;
  String nowplayingtitle;
  String nowplayingartist;
  //müzikleri çekip songs listesine attığım kısım Future olmasının sebebi çekene kadar bekletmemiz gerektiğinden
  Future<List<Song>> getSongProperties() async {
    var songsquery = await audioQuery.getSongs();
    if(songsadded == false) {
      for (var s in songsquery) {
        Song tempsong = Song(s.id, s.title, s.artist, s.duration,s.filePath,s.albumArtwork);
        songs.add(tempsong);
      }
      songsadded = true;
    }
    print(songs.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height-160,
                    child: getPlaylistList()),
                Container(
                    height: 63,
                    child: MusicBox()),

              ],
            ),
          ),
        ),
      ),
    );
  }

  //müziklerin eklendiği liste widgeti
  Widget getPlaylistList(){
    return FutureBuilder(
      future: getSongProperties(),
      builder: (context,AsyncSnapshot snapshot){
        if(songs.length <= 0){
          return CircularProgressIndicator();
        }
        else{
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (BuildContext context,int index){
              return playListCard("assets/godzillaeminem.png" ,songs[index].title,songs[index].artist,songs[index].duration,songs[index].url,index);
            },
          );
        }
      },
    );
  }

  Widget MusicBox(){
    return  Align(
      alignment: Alignment.bottomCenter,
      child:  InkWell(
        onTap: (){
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15.0),topLeft: Radius.circular(15.0)),
          child: Container(
            height: 68,
            width : MediaQuery.of(context).size.width,
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _albumCard("assets/favourite.jpg"),
                  SizedBox(width: 10.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(nowplayingtitle == null ? 'Music Name' : nowplayingtitle, style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),),
                      Text(nowplayingartist == null ? 'Artist' : nowplayingartist, style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        color: Colors.black,
                      ),),
                    ],
                  ),
                  Spacer(),

                  SizedBox(width: 10.0,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //favorilere aldığımda ekleniyodu zaten eskisinden gelme takma
  List<String> favourites = [];

  playListCard(String asset, String title, String artist, String duration,String url,int index) {
    final alreadySaved = favourites.contains(asset);
    return InkWell(
      onTap: (){
        nowplayingtitle = title;
        nowplayingartist = artist;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Player(singer: artist,songName: title,duration: duration,songPath: url,image: asset,player: audioPlayer,playlistsongs: songs,index: index,)),
        );
      },
      child: Container(
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(asset, fit: BoxFit.cover, height:70, width: 90,),
            ),
            SizedBox(width: 10.0,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title.length > 20 ? title.substring(0,20) : title, style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),),
                Text(artist.length > 15 ? artist.substring(0,15) : artist, style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  color: Colors.black,
                ),),
              ],
            ),
            Spacer(),
            Text(formatMillitoDisplay(duration), style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                color: Colors.black
            ),),
            SizedBox(width: 15.0,),
            InkWell(
              onTap: (){
                setState(() {
                  if (alreadySaved) {
                    favourites.remove(asset);
                  } else {
                    favourites.add(asset);
                  }
                });
              },
              child: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatMillitoDisplay(String toformat){
    Duration duration = new Duration(minutes: 0,seconds: 0,milliseconds: int.parse(toformat));
    String durationstring =  duration.toString().split('.')[0];
    List<String> durationlist = durationstring.split(':');
    return durationlist[1]+":"+durationlist[2];
  }

  void _handleOnPressed() {
    setState(() {
      isPlaying = !isPlaying;
      isPlaying
          ? animationController.forward()
          :animationController.reverse();
    });
  }

  _albumCard(String assetImg) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Image.asset(assetImg, fit: BoxFit.cover, height: 50,width: 50, ),
      ),
    );
  }

}

class Song {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String url;
  final String photo;
  Song( this.id, this.title, this.artist, this.duration, this.url, this.photo);
}
