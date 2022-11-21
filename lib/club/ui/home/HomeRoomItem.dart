import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smatch/club/ui/liveroom/LiveRoom.dart';
import 'package:smatch/club/utils/DynamicColor.dart';
import 'package:smatch/club/widgets/Squircle.dart';

class HomeRoomItem extends StatefulWidget {
  HomeRoomItem({Key? key, required this.nomsalon}) : super(key: key);
  String nomsalon;
  @override
  _HomeRoomItemState createState() => _HomeRoomItemState();
}

class _HomeRoomItemState extends State<HomeRoomItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.nomsalon);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => LiveRoom(
              nomsalon: widget.nomsalon,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nomsalon,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Pitch your start up idea to VCs & top Entrepreneurs",
              style: TextStyle(
                fontSize: 14,
                color: DynamicColor.withBrightness(
                    context: context, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Squircle(),
                const SizedBox(width: 5),
                const Squircle(),
                const SizedBox(width: 5),
                const Squircle(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: DynamicColor.withBrightness(
                      context: context,
                      color: const Color(0xFF404182),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        CupertinoIcons.person_fill,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "354",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        CupertinoIcons.mic_fill,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "354",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveRoom(
          nomsalon: widget.nomsalon,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
