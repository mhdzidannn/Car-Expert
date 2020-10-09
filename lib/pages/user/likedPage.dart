import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:carexpert/pages/main/homePage.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class LikeCarPage extends StatefulWidget {

  LikeCarPage({Key key}) : super(key: key);

  @override
  _LikeCarPageState createState() => _LikeCarPageState();
}

class _LikeCarPageState extends State<LikeCarPage> {

  Stream<List<Advertisment>> getUserLikeCarList;
  bool _deleteMode;
  DealerDetails _dealerDetail;

  @override
  void initState() {
    _deleteMode = false;
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    getUserLikeCarList = DatabaseService().getUserFavouriteAdvertismentStream(notifier.userUID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Favourite", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: <Widget>[
          if (!_deleteMode) ... {
            IconButton(icon: Icon(Icons.delete), onPressed: () => setState(() => _deleteMode = true))
          } else ... {
            IconButton(icon: Icon(Icons.cancel), onPressed: () => setState(() => _deleteMode = false))
          }
        ],
      ),
      drawer: MainDrawer(),
      body: Consumer<UserDetails>(
        builder: (context, user, widget) {
          if (user != null) {
            if (user.likedCars == null || user.likedCars.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 300,
                      height: 200,
                      child: Image.asset(
                        'assets/images/dream2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      'Add your dream car now..!!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                )
              );
            } else {
              return StreamBuilder<List<Advertisment>>(
                stream: getUserLikeCarList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: (snapshot.data.length * 255).toDouble(),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context , index) => _buildLikedAdvertisment(
                                context, snapshot.data[index], snapshot.data.length, index
                              )
                            ),
                          ),
                          if (user.deletedCars != null) ... {
                            if (user.deletedCars.isNotEmpty) ... {
                              Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Center(
                                  child: Text(
                                    'Unavailable Ads',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: (user.deletedCars.length * 270).toDouble(),
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: user.deletedCars.length,
                                  itemBuilder: (context, index) => _buildDeletedAdvertisment(
                                    context, 
                                    user.deletedCars[index],
                                    user.likedCars.length,
                                    index
                                  )
                                ),
                              )
                            }
                          }
                        ],
                      )
                    );
                  }
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }


  Widget _buildDeletedAdvertisment(BuildContext context, Map data, int index, int currentIndex) {

    String _deletedAt = timeago.format(DateTime.tryParse(data['deletedAt'].toDate()
    .toString())).toString(); 

    return Padding(
      padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: currentIndex + 1 == index ? 70 : 0),
      child: Card(
        elevation: 10,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[            
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Container(
                    color: Colors.grey[350],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.delete_forever,
                            color: Colors.grey,
                            size: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey, fontSize: 20),
                              children: <TextSpan> [
                                TextSpan(
                                  text: 'The Advertisment is\n no longer available'
                                )
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.93),
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 75,
                        child: Container(
                          //padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          //color: Colors.lightBlue[400],
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment(-1, 0.9),
                                  child: Text(
                                    '${data['adTitle']}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Align(
                                  alignment: Alignment(-1, 1),
                                  child: Container(
                                    //padding: EdgeInsetsDirectional.only(start: 10, top: 5),
                                    child: Text(
                                      'Deleted : $_deletedAt'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_deleteMode) ...{
                Consumer<UserNotifier>(
                  builder: (context, notifier, widget)
                  => Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        onPressed: () => DatabaseService().deleteDeletedCars(data, notifier),
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              }
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikedAdvertisment(BuildContext context, Advertisment data, int index, int currentIndex) {

    String _updatedAt;
    String _createdAt = timeago.format(DateTime.tryParse(data.dateCreated.toDate()
    .toString())).toString();
    if (data.dateUpdated != null)
      _updatedAt = timeago
              .format(DateTime.tryParse(data.dateUpdated.toDate().toString()))
              .toString() ??
          null;

    return Padding(
      padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: currentIndex + 1 == index ? 70 : 0),
      child: GestureDetector(
        onLongPress: () {},
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarDetailPage(
                  advertDoc: data,
                    ))),
        child: Card(
          elevation: 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (data.carImages != null) ...{
                  Container(
                    child: Image.network(
                      data.carImages[0],
                      fit: BoxFit.cover,
                    ),
                  )
                } else ...{
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Container(
                        color: Colors.grey[350],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 30,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'No images uploaded',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                },
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.white.withOpacity(0.93),
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 75,
                          child: Container(
                            //padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                            //color: Colors.lightBlue[400],
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment(-1, 0.9),
                                    child: Text(
                                      '${data.adTitle}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Align(
                                    alignment: Alignment(-1, 1),
                                    child: Container(
                                      //padding: EdgeInsetsDirectional.only(start: 10, top: 5),
                                      // child: Text(
                                      //   data.dateUpdated == null
                                      //       ? 'Created : $_createdAt'
                                      //       : 'Updated : $_updatedAt',
                                      // ),
                                      child: contactButton(data),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 25,
                          child: Container(
                            padding: EdgeInsets.only(top: 12, right: 35),
                            //color: Colors.green,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.favorite,
                                  color: data.userLike == 0
                                      ? Colors.grey
                                      : Colors.red,
                                  size: 24,
                                ),
                                Text('${data.userLike} Likes')
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_deleteMode) ...{
                  Consumer<UserNotifier>(
                    builder: (context, notifier, widget)
                    => Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          onPressed: () {
                            DatabaseService().updateLikeCountAndStatus(data, notifier, false);
                            // deleteAlertDialog();
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                }
              ],
            ),
          ),
        ),
      ),
    );
  }

  Positioned contactButton(Advertisment data) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 30,
        //color: Colors.white.withOpacity(0.93),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 20,
                width: 100,
                child: RaisedButton.icon(
                  onPressed: () {
                    contactAlertDialog(context, data);
                  },
                  color: Colors.yellow,
                  elevation: 5,
                  icon: Icon(
                    Icons.phone,
                    size: 18,
                  ),
                  label: Text(
                    'Contact',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 100,
                child: RaisedButton.icon(
                  onPressed: () {
                    whatsappAlertDialog(context, data);
                  },
                  color: Colors.greenAccent[400],
                  elevation: 5,
                  icon: Icon(
                    LineIcons.whatsapp,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Whatsapp',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  contactAlertDialog(BuildContext context, Advertisment data) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget launchButton = FlatButton(
      child: Text("Proceed"),
      onPressed: () {
        print('[Favourite] Phone Button');
        launch("tel:${_dealerDetail.phone}");
        Navigator.pop(context, true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text(
          "Clicking 'Proceed' will leave the Car Expert app and open the phone dialler of your phone. Proceed?"),
      actions: [
        cancelButton,
        launchButton,
      ],
    );

    // show the dialog
    showDialog(
     context: context,
      builder: (BuildContext context) {
        AuthService().getDealerProfileLocal(data.uid).then((value) {
          setState(() => _dealerDetail = value);
        });
        return alert;
      },
    );
  }

  whatsappAlertDialog(BuildContext context, Advertisment data) {
    //for ios, the whatsapp launch url would be different. So we need a way to verify if phone is android or ios
    // use = import 'dart:io' to see if phoneis ios or android
    // currently we only use android, so suck it :P

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget launchButton = FlatButton(
        child: Text("Proceed"),
        onPressed: () {
          print('[Favourite] Whatsapp Button');
          launch("https://wa.me/6${_dealerDetail.phone}");
          Navigator.pop(context, true);
        });

    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text(
          "Clicking 'Proceed' will leave the Car Expert app and open Whatsapp on your phone. Proceed?"),
      actions: [
        cancelButton,
        launchButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        AuthService().getDealerProfileLocal(data.uid).then((value) {
        setState(() => _dealerDetail = value);
        });
        return alert;
      },
    );
  }

}