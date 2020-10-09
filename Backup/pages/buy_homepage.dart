
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BuyHomepage extends StatefulWidget {

  @override
  _BuyHomepageState createState() => _BuyHomepageState();
}

class _BuyHomepageState extends State<BuyHomepage> {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  // final List<Widget> pages = [
  //   ExplorePage(
  //     key: PageStorageKey('ExplorePage')
  //   ),
  //   InboxPage(
  //     key: PageStorageKey('InboxPage'),

  //   ),
  //   ProfilePage(
  //     key: PageStorageKey('ProfilePage')
  //   )
  // ];

  final PageStorageBucket pageBucket = PageStorageBucket();

  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      //drawer: mainDrawer(),

      //body: buildPageView(pageController, pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color : Colors.white, boxShadow : [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 6),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal : 20, vertical: 5),
              duration: Duration(milliseconds: 800),
              tabBackgroundColor: Colors.cyan,
              tabs: [
                GButton(
                  icon: Icons.search,
                  text: 'Explore',
                ),
                GButton(
                  icon: Icons.mail_outline,
                  text: 'Inbox',
                ),
                GButton(
                  icon: Icons.person_outline,
                  text: 'Profile'
                )
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                  pageController.animateToPage(
                    index, 
                    duration: Duration(
                      milliseconds: 400
                    ), 
                    curve: Curves.ease
                  );
                });
              },
            ),
          ),
        ),
      )
    );
  }

}