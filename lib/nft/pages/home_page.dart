import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:smatch/nft/components/my_tabbar.dart';
import 'package:smatch/nft/tabs/top_tab.dart';
import 'package:smatch/nft/tabs/trending_tab.dart';
import 'package:smatch/nft/util/glass_box.dart';

import '../components/my_appbar.dart';
import '../components/my_bottombar.dart';
import '../tabs/recent_tab.dart';
import '../theme/const.dart';

class HomePagenft extends StatefulWidget {
  const HomePagenft({Key? key}) : super(key: key);

  @override
  State<HomePagenft> createState() => _HomePagenftState();
}

class _HomePagenftState extends State<HomePagenft> {
  // user tapped searched button
  void searchButtonTapped() {}
  final _advancedDrawerController = AdvancedDrawerController();
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
          title: const Text(
            'text',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            // title + search button
            // MyAppBar(
            //   title: 'Djolo Collections',
            //   onSearchTap: searchButtonTapped,
            // ),

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
}
