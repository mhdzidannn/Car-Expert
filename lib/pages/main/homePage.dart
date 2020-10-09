import 'dart:io';
import 'dart:typed_data';

import 'package:carexpert/model/user.dart';
import 'package:carexpert/pages/user/explorePage.dart';
import 'package:carexpert/pages/main/inboxPage.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/dealer/myAdsPage.dart';
import 'package:carexpert/pages/main/profilePage.dart';
import 'package:carexpert/pages/user/likedPage.dart';
import 'package:carexpert/pages/user/rssFeedPage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GButton> userNavBar = [
    GButton(
      icon: Icons.home,
      text: 'Home',
    ),
    GButton(
      icon: Icons.favorite,
      text: 'Favourite',
    ),
    GButton(
      icon: Icons.rss_feed,
      text: 'News',
    ),
    GButton(icon: Icons.person_outline, text: 'Profile')
  ];

  List<GButton> dealerNavBar = [
    GButton(
      icon: Icons.book,
      text: 'My Ads',
    ),
    GButton(
      icon: Icons.mail_outline,
      text: 'Inbox',
    ),
    GButton(icon: Icons.person_outline, text: 'Profile')
  ];

  Future<File> _downloadProfilePic(String url) async {
    return await FirebaseStorage.instance.getReferenceFromUrl(url)
    .then((ref) async => await ref.getData(2048).then((data) {
      return File.fromRawPath(data);
    }));
  }

  @override
  void initState() {
    UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);
    if (userNotifier.dealerMode) {
      AuthService().getDealerProfileLocal(userNotifier.userUID).then((data) {
        userNotifier.currentDealer = data;
        if (data.profilePic.isNotEmpty) {
           _downloadProfilePic(data.profilePic).then((image) => userNotifier.setProfilePic = image);
        }
      });
    } else {
      AuthService().getUserProfileLocal(userNotifier.userUID).then((data) {
        userNotifier.currentUser = data;
        if (data.profilePic.isNotEmpty) {
           _downloadProfilePic(data.profilePic).then((image) => userNotifier.setProfilePic = image);
        }
      });
    }
    super.initState();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // var userStream = Provider.of<User>(context);
    // String userUID = userStream.uid;

    return Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return Scaffold(
        key: scaffoldKey,
        drawer: MainDrawer(),
        body: PageView(
            onPageChanged: (index) {
              _selectedIndex = index;
            },
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: <Widget>[
              if (notifier.dealerMode) ...{
                MyAdvertismentPage(
                  key: PageStorageKey('MyAdsPage'),
                  uid: notifier.userUID,
                ),
                InboxPage(
                  key: PageStorageKey('InboxPage'),
                ),
                ProfilePage(),
              } else ...{
                ExplorePage(
                  key: PageStorageKey('ExplorePage'),
                ),
                LikeCarPage(key: PageStorageKey('LikeCarPage')),
                // InboxPage(key: PageStorageKey('InboxPage')),
                RSSFeedPage(),
                ProfilePage()
              }
            ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))]),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 6),
              child: GNav(
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabBackgroundColor: Colors.blue,
                tabs: notifier.dealerMode ? dealerNavBar : userNavBar,
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                    pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.ease);
                    // pageController.jumpToPage(index);
                  });
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

class MainDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);

    return Drawer(
        child: ListView(
      children: <Widget>[
        if (notifier.dealerMode) ...{
          UserAccountsDrawerHeader(
              currentAccountPicture: ClipOval(
                  child: Material(
                    color: Colors.cyan[300],
                    child: InkWell(
                      splashColor: Colors.lightBlueAccent,
                      child: SizedBox(width: 30, height: 30, child: Icon(Icons.account_circle, size: 40, color: Colors.white,)),
                      onTap: () {
                      // Navigator.push(
                      //   context, MaterialPageRoute(builder: (context) => ProfilePage()),
                      // );
                    },
                  ),
                ),
              ),
              accountName: Text(
                notifier.getDealerDetails.username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(notifier.getDealerDetails.email))
        } else ...{
          UserAccountsDrawerHeader(
              currentAccountPicture: ClipOval(
                child: Material(
                  color: Colors.cyan[300],
                  child: InkWell(
                    splashColor: Colors.lightBlueAccent,
                    child: SizedBox(width: 30, height: 30, child: Icon(Icons.account_circle, size: 40, color: Colors.white,)),
                    onTap: () {
                      // Navigator.push(
                      //   context, MaterialPageRoute(builder: (context) => ProfilePage()),
                      // );
                    },
                  ),
                ),
              ),
              accountName: Text(
                "${notifier.getUserDetails.firstName} ${notifier.getUserDetails.lastName}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(notifier.getUserDetails.email))
        },
        Divider(
          thickness: 1,
        ),
        SwitchListTile(
          title: Text("Inbox Notification"),
          value: true,
          onChanged: (val) {},
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text('Settings'),
          trailing: Icon(Icons.settings),
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text('Give Feedback'),
          trailing: Icon(Icons.feedback),
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text('Help'),
          trailing: Icon(Icons.help_outline),
          onTap: () {},
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text('Sign Out'),
          trailing: Icon(Icons.exit_to_app),
          onTap: () {
            Navigator.pop(context);
            _auth.signOut(notifier);
          },
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(),
        Center(
          child: Text('V 1.0.0'),
        )
      ],
    ));
  }
}
