import 'dart:async';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/advertisment_notifier.dart';
import 'package:carexpert/notifier/searchNotifier.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/pages/dealer/createAdsPage.dart';
import 'package:carexpert/pages/main/homePage.dart';
import 'package:carexpert/pages/main/loginPage.dart';
import 'package:carexpert/pages/user/searchPage.dart';
import 'package:carexpert/pages/main/signUpPage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifier/user_notifier.dart';
import 'pages/main/homePage.dart';
import 'services/auth_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserNotifier(),
      child: StreamBuilder<User>(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
          if (snapshot.data != null) {
            notifier.setUserUID = snapshot.data.uid;
            return FutureBuilder<bool>(
              future: AuthService().checkUserDetails(notifier),
              builder: (context, mode) {
                if (mode.hasData) {
                  if (mode.data) {
                    return MultiProvider(
                        providers: [
                          if (notifier.dealerMode) ...{
                            StreamProvider<DealerDetails>.value(value: AuthService().getDealerProfileStream(notifier.userUID))
                          } else ...{
                            StreamProvider<UserDetails>.value(value: AuthService().getUserProfileStream(notifier.userUID))
                          },
                          ChangeNotifierProvider(
                            create: (context) => SearchNotifier(),
                          ),
                          ChangeNotifierProvider(
                            create: (context) => AdvertistmentNotifier(),
                          ),
                        ],
                        child: MaterialApp(
                            debugShowCheckedModeBanner: false,
                            theme: ThemeData(primarySwatch: Colors.blue),
                            routes: {
                              '/SignUpPage': (context) => SignUpPage(),
                              '/InitializeAd': (context) => CreateAdsPage1(),
                              '/SearchPage': (context) => SearchPage(),
                              '/BuyPage': (context) => CarDetailPage(),
                            },
                            home: ClassTransitionPage()));
                  } else {
                    AuthService().signOut(notifier);
                    return Container();
                  }
                } else {
                  return MaterialApp(debugShowCheckedModeBanner: false, home: LoadingPage());
                }
              },
            );
          } else {
            return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.blue), home: LoginTransitionPage());
          }
        },
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[        
            Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                backgroundColor: Colors.blue,
                valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginTransitionPage extends StatefulWidget {
  @override
  _LoginTransitionPageState createState() => _LoginTransitionPageState();
}

class _LoginTransitionPageState extends State<LoginTransitionPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 3);
    return new Timer(duration, () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.white, Colors.blue,],
              stops: [0.5,0.5],
              radius: 3
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 280,
                width: 280,
                child: Image.asset(
                  'assets/images/initial.jpg',
                  fit: BoxFit.cover
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 300,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClassTransitionPage extends StatefulWidget {
  @override
  _ClassTransitionPageState createState() => _ClassTransitionPageState();
}

class _ClassTransitionPageState extends State<ClassTransitionPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 4);
    return new Timer(duration, () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                notifier.dealerMode ? 'Signing In to Dealers Account' : 'Signing in to Users Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                backgroundColor: Colors.blue,
                valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
