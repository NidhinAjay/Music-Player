import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../../provider/song_model_provider.dart';
import '../../widgets/MusicTile.dart';
import 'NowPlaying.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> allSongs = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    if (Platform.isAndroid) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent.withOpacity(.8),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(
            Icons.menu,
            color: Colors.white70,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: TextField(
            // controller: Search,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white38),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                label: Text("Search", style: TextStyle(color: Colors.white38)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(
                    width: 2, color: Colors.white70),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: "Search"),
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text("Loading")
                ],
              ),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("Nothing found!"));
          }
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Trending right now",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 35),
                  ),
                ),
                SizedBox(height: 15),
                Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          height: 220,
                          width: double.maxFinite,
                          decoration: BoxDecoration(color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white,width: 2)),
                          ),
                    )),
                SizedBox(height: 15),
                Stack(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: item.data!.length,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                        itemBuilder: (context, index) {
                          allSongs.addAll(item.data!);
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<SongModelProvider>()
                                  .setId(item.data![index].id);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NowPlaying(
                                          songModelList: [item.data![index]],
                                          audioPlayer: _audioPlayer)));
                            },
                            child: MusicTile(
                              songModel: item.data![index],
                            ),
                          );
                        },
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.bottomRight,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => NowPlaying(
                    //                   songModelList: allSongs,
                    //                   audioPlayer: _audioPlayer)));
                    //     },
                    //     child: Container(
                    //       margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
                    //       child: const CircleAvatar(
                    //         radius: 30,
                    //         child: Icon(
                    //           Icons.play_arrow,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

