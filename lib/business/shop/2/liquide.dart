import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:newapp/business/shop/2/lecturevideo.dart';
// import 'package:better_player/better_player.dart';

class Liquides2hop extends StatefulWidget {
  const Liquides2hop({Key? key}) : super(key: key);

  @override
  _Liquides2hopState createState() => _Liquides2hopState();
}

class _Liquides2hopState extends State<Liquides2hop> {
  final List<Map> tiktokItems = [
    {
      "video": "assets/video_1.mp4",
    },
    {
      "video": "assets/video_2.mp4",
    },
    {
      "video": "assets/video_3.mp4",
    },
    {
      "video": "assets/video_4.mp4",
    },
    {
      "video": "assets/video_5.mp4",
    },
    {
      "video": "assets/video_6.mp4",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            height: double.infinity,
            scrollDirection: Axis.vertical,
            viewportFraction: 1.0,
          ),
          items: tiktokItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  color: Color(0xFF141518),
                  child: Stack(
                    children: [
                      // BetterPlayer.network(
                      //   "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                      //   betterPlayerConfiguration: BetterPlayerConfiguration(
                      //     autoPlay: true,
                      //     looping: true,
                      //     // aspectRatio: 16 / 9,
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        PostContent(),
      ],
    ));
  }
}

class PostContent extends StatelessWidget {
  const PostContent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          padding: EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Liquidé',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Liquidé',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '@extremesports_95',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Goein full send in Squaw Valley. #snow @snowboarding # extremesports #sendit #winter',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: const CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(
                                  'assets/google-logo.png',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 12,
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 80,
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.message,
                              color: Colors.white.withOpacity(0.85),
                              size: 45,
                            ),
                          ],
                        ),
                      ),
                      // AnimatedLogo(),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
