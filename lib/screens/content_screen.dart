import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:example/screens/like_icon.dart';
import 'package:example/screens/options_screen.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class ContentScreen extends StatefulWidget {
  final String? src;

  const ContentScreen({Key? key, this.src}) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    reelsImage();
  }

  Future initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.src!);
    await Future.wait([_videoPlayerController.initialize()]);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      showControls: false,
      looping: true,
    );
    setState(() {});
  }

  Future<void> reelsImage() async {
    try{
      final url = Uri.parse('http://192.168.0.5:3000/api/aiPro/getReelsList');
      SharedPreferences pref = await SharedPreferences.getInstance();
      var response = await http.get(url);
      var decodeResponse  = jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        print('데이터 정상으로 들어옴');
        pref.setStringList('reels', List<String>.from(decodeResponse["data"]));
        print(pref.getStringList('reels'));
      }
    } catch (e) {
      print('동작하지않음');
      Exception(e);
    }
  }



  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _liked = !_liked;
                  });
                },
                child: Chewie(
                  controller: _chewieController!,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Swiper(
                  //   itemBuilder: (BuildContext context, int index) {
                  //     return ContentScreen(
                  //       src: images[index],
                  //     );
                  //   },
                  //   itemCount: images.length,
                  //   scrollDirection: Axis.vertical,
                  //
                  // ),
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading...')
                ],
              ),
        if (_liked)
          Center(
            child: LikeIcon(),
          ),
        OptionsScreen()
      ],
    );
  }
}