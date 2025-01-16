import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:example/screens/content_screen.dart';
import 'package:http/http.dart' as http;


class ReelsPage extends StatefulWidget {

  @override
  _ReelsPageState createState() => _ReelsPageState();
  late String reelsimage;
}
class _ReelsPageState extends State<ReelsPage> {
  final List<String> videos = [
    // "192.168.0.5:3000/uploads/picClusters/hong/2024/03/07/originPics/hong_01_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/hong/2024/03/07/originPics/hong_02_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/hong/2024/03/07/originPics/hong_03_S.jpg",
    // "192.168.0.5:3000/uploads/picClusters/hong/2024/03/07/originPics/hong_04_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/hong/2024/03/07/originPics/hong_05_S.jpg",
    // "192.168.0.5:3000/uploads/picClusters/kim/2024/03/07/originPics/kimm_01_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/kim/2024/03/07/originPics/kimm_02_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/kim/2024/03/07/originPics/kimm_03_S.jpg",
    // "192.168.0.5:300 0/uploads/picClusters/kim/2024/03/07/originPics/kimm_04_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/kim/2024/03/07/originPics/kimm_05_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/meju/2024/03/07/originPics/meju_01_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/meju/2024/03/07/originPics/meju_02_T.jpg",
    // "192.168.0.5:3000/uploads/picClusters/meju/2024/03/07/originPics/meju_03_S.jpg",
    // "192.168.0.5:3000/uploads/picClusters/meju/2024/03/07/originPics/meju_04_S.jpg",
    // "192.168.0.5:3000/uploads/picClusters/meju/2024/03/07/originPics/meju_04_T.jpg"
    'https://assets.mixkit.co/videos/preview/mixkit-taking-photos-from-different-angles-of-a-model-34421-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-winter-fashion-cold-looking-woman-concept-video-39874-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-womans-feet-splashing-in-the-pool-1261-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4'
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              //We need swiper for every content
              Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return ContentScreen(
                    src: videos[index],
                  );
                },
                itemCount: videos.length,
                scrollDirection: Axis.vertical,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '영유아 Shorts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.camera_alt),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



