import 'package:flutter/material.dart';

import '../components/nft_card.dart';

class TrendingTab extends StatelessWidget {
  const TrendingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        itemBuilder: (BuildContext, index) {
          return NftCard(
            imagePath: 'assets/nft/mask.jpeg',
          );
        });
    ;
  }
}
