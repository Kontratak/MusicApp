import 'package:audioplayers/audioplayers.dart';
import 'package:deneme2/Player.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Container(
           child:Padding(padding:EdgeInsets.all(8.0),child: getPlaylistList())
        ),
      ),
    );
  }

  Widget albumWidget(){
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0,top: 30),
              child: Text("Songs", style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Nunito-Regular',
                  fontSize: 30
              ),),
            ),

            Container(
              child: getPlaylistList(),
            )
          ],
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

  //favorilere aldığımda ekleniyodu zaten eskisinden gelme takma
  List<String> favourites = [];

  playListCard(String asset, String title, String artist, String duration,String url,int index) {
    final alreadySaved = favourites.contains(asset);
    return InkWell(
      onTap: (){ //player tarafına atıyor
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
              child: Image.asset(asset, fit: BoxFit.cover, height:100, width: 120,),
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
            Text(duration, style: TextStyle(
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
            )
          ],
        ),
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
