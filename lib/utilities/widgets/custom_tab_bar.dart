import 'package:flutter/material.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/constants/home_page_tabs.dart';
import 'package:mynotes/utilities/widgets/custom_tabbar_indicator.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    Key? key,
    required TabController tabController,
  }) : _tabController = tabController, super(key: key);

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelPadding:
          const EdgeInsets.only(left: 0, right: 20),
      indicatorPadding:
          const EdgeInsets.only(left: 0, right: 20),
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicator: CustomTabIndicator(
        color: const Color(lightBlueHex),
        radius: 3,
        rectangleWidth: 40,
        rectangleHeight: 3,
        verticalOffset: 8,
      ),
      tabs: homePageTabs,
    );
  }
}