import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/pages/main/homePage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyAdvertismentPage extends StatefulWidget {

  final String uid;
  MyAdvertismentPage({Key key, this.uid}) : super(key: key);

  @override
  _MyAdvertismentPageState createState() => _MyAdvertismentPageState();
}

class _MyAdvertismentPageState extends State<MyAdvertismentPage> {

  bool _deleteMode = false;
  Stream<List<Advertisment>> getMyAdvertisment;

  @override
  void initState() {
    print('INITSTATE TESTING');
    _deleteMode = false;
    getMyAdvertisment = DatabaseService().getDealerAdvertisment(widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('MyAds'),
        actions: <Widget>[
          IconButton(
            icon: _deleteMode ? Icon(Icons.cancel) : Icon(Icons.delete),
            onPressed: () => setState(() => _deleteMode = !_deleteMode),
          )
        ],
      ),
      drawer: MainDrawer(), 
      body: Consumer<DealerDetails>(
        builder: (context, dealer, widget) {
          if (dealer == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            print('[MyAds] USER ADS LOADED');
            //ZAIDAN
            return StreamBuilder<List<Advertisment>>(
              stream: getMyAdvertisment,
              builder: (context, advert) {
                if (dealer.adCount == 0) {
                  return Center(
                    child: Text('You have not posted any advertisement'),
                  );
                } else {
                  if (!advert.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: advert.data.length,
                        itemBuilder: (context, index) => _buildUserAdvertisment(
                          context,
                          advert.data[index],
                          index,
                          advert.data.length,
                        ),
                      ),
                    );
                  }
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        onPressed: () => Navigator.pushNamed(context, '/InitializeAd'),
        label: Text('Create Ads'),
        icon: Icon(Icons.save_alt),
      ),
    );
  }

  Widget _buildUserAdvertisment(BuildContext context, Advertisment data, int index, int currentIndex) {
    String _updatedAt;
    String _createdAt = timeago
        .format(DateTime.tryParse(data.dateCreated.toDate().toString()))
        .toString();
    if (data.dateUpdated != null)
      _updatedAt = timeago
              .format(DateTime.tryParse(data.dateUpdated.toDate().toString()))
              .toString() ??
          null;

    deleteAlertDialog() {
      Widget cancelButton = FlatButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      Widget launchButton =Consumer<UserNotifier>(builder: (context, notifier, widget) {
        return FlatButton(
          child: Text("Delete"),
          onPressed: () {
            DatabaseService().deleteDealerAdvertisment(data, notifier, data.carImages);
            Navigator.pop(context, true);
          },
        );
      });

      AlertDialog alert = AlertDialog(
        title: Text("Notice"),
        content: Text(
            "Clicking 'Delete' will remove the advertisement from Car Expert. \n\nProceed?"),
        actions: [
          cancelButton,
          launchButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: index + 1 == currentIndex ? 70 : 0),
      child: GestureDetector(
        onLongPress: () {},
        onTap: () => Navigator.push(
          context,MaterialPageRoute(
            builder: (context) => CarDetailPage(
              //editMode: true,
              //editMode: _deleteMode,
              advertDoc: data,
            )
          )
        ),
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
                                      child: Text(
                                        data.dateUpdated == null
                                            ? 'Created : $_createdAt'
                                            : 'Updated : $_updatedAt',
                                      ),
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        onPressed: () {
                          deleteAlertDialog();
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red,
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
}
