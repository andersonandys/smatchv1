import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:smatch/menu/menuwidget.dart';
import 'package:smatch/nft/components/my_appbar.dart';
import 'package:smatch/nft/components/my_tabbar.dart';
import 'package:smatch/nft/tabs/recent_tab.dart';
import 'package:smatch/nft/tabs/top_tab.dart';
import 'package:smatch/nft/tabs/trending_tab.dart';

class Djolo extends StatefulWidget {
  const Djolo({Key? key}) : super(key: key);

  @override
  _DjoloState createState() => _DjoloState();
}

class _DjoloState extends State<Djolo> {
  final _advancedDrawerController = AdvancedDrawerController();
  // user tapped searched button
  void searchButtonTapped() {}
  // tab options
  List tabOption = [
    ["Recent", RecentTab()],
    ["Tendance", TrendingTab()],
    ["Top", TopTab()],
  ];

  // bottom bar navigation
  int _currentBottonIndex = 0;
  void _handleIndexChanged(int? index) {
    setState(() {
      _currentBottonIndex = index!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabOption.length,
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(10),
        extendBody: true,
        // bottomNavigationBar: GlassBox(
        //   child: MyBottomBar(
        //     index: _currentBottonIndex,
        //     onTap: _handleIndexChanged,
        //   ),
        // ),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(10),
          elevation: 0,
          leading: Menuwidget(),
        ),
        body: ListView(
          children: [
            // title + search button
            MyAppBar(
              title: 'Djolo \n Collections',
              onSearchTap: searchButtonTapped,
            ),

            // tab bar
            SizedBox(
              height: 600,
              child: MyTabBar(
                tabOptions: tabOption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}
