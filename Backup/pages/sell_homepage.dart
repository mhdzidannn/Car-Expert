import 'package:flutter/material.dart';


class SellHompage extends StatefulWidget {
  @override
  _SellHompageState createState() => _SellHompageState();
}

class _SellHompageState extends State<SellHompage> {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  // final List<Widget> pages = [
  //   MyAdvertismentPage(
  //     key: PageStorageKey('MyAdsPage'),
  //   ),
  //   InboxPage(
  //     key: PageStorageKey('InboxPage'),
  //   ),
  //   ProfilePage(
  //     key: PageStorageKey('Profile'),
  //   )
  // ];

  final PageStorageBucket pageBucket = PageStorageBucket();

  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  //int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      //drawer: mainDrawer(),
      //body: buildPageView(pageController, pages),
      //bottomNavigationBar: 
    );
  }
}