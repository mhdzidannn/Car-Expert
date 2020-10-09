import 'dart:math';

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class DealerShowPage extends StatefulWidget {
  final DealerDetails dealerProfile;
  final Color pickedColor;
  DealerShowPage({this.dealerProfile, this.pickedColor});
  @override
  _DealerShowPageState createState() => _DealerShowPageState();
}

class _DealerShowPageState extends State<DealerShowPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  DealerDetails dealerProfile;
  Future<List<Advertisment>> dealerListing;
  TextStyle infoTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 18,
  );

  @override
  void initState() {
    print("ADDSADASSADSAD ${widget.dealerProfile.uid}");
    dealerListing = DatabaseService().getDealerListing(widget.dealerProfile.uid);
    _tabController = TabController(length: 2, vsync: this);
    dealerProfile = widget.dealerProfile;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.share),
            )
          ],
          title: Text('Dealer Preview'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            tabs: <Widget>[
              Tab(
                text: 'About',
              ),
              Tab(
                text: 'Listings (${dealerProfile.adCount})',
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            buildAboutTab(maxWidth),
            buildListingTab(maxWidth),
          ],
        ));
  }

  Container buildListingTab(double maxWidth) {
    return Container(
      width: maxWidth,
      child: FutureBuilder<List<Advertisment>>(
        future: dealerListing,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                //LOCAL VARIABLE
                Advertisment car = snapshot.data[index];
                var formatter = NumberFormat.compact();
                double r = 3.55 / 12 / 100;
                double n = 5.0 * 12;
                double result =
                    (car.price * r * pow((1 + r), n) / (pow((1 + r), n) - 1));

                return GestureDetector(
                  onLongPress: () {},
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CarDetailPage(
                                advertDoc: car,
                                dealerDetail: dealerProfile,
                              ))),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15,
                        left: 10,
                        right: 10,
                        bottom: snapshot.data.length == index + 1 ? 50 : 0),
                    child: Container(
                      height: 210,
                      child: Card(
                        elevation: 10,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 9,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                          child: car.carImages != null
                                              ? Image.network(
                                                  car.carImages[0],
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(Icons.camera_alt),
                                                        Text(
                                                            "No image available")
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        width: maxWidth,
                                        color: Colors.black,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'RM ${result.toStringAsFixed(0).replaceAllMapped(regPrice, mathFuncPrice)}/month',
                                                style: TextStyle(
                                                    color: Colors.grey[300]),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                'RM ${car.price.toString().replaceAllMapped(regPrice, mathFuncPrice)}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 10,
                                    child: Container(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 5,
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 50,
                                                    height: 22,
                                                    padding: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Center(
                                                        child: Text('Used')),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Container(
                                                    height: 22,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    padding: EdgeInsets.all(2),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle_outline,
                                                                color: Colors
                                                                    .white,
                                                                size: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Center(
                                                            child:
                                                                Text('Dealer'),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Text(
                                                car.adTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: Text(
                                                  '${formatter.format(car.mileage)} KM  -  AT  -  ${car.location}',
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.grey[200]))),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                contactAlertDialog(context);
                                                print('PHONE');
                                              },
                                              onLongPress: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                height: 40,
                                                width: 70,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.phone,
                                                    color: Colors.black,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                whatsappAlertDialog(context);
                                                print('WAZAZZAAZAZAP');
                                              },
                                              onLongPress: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.greenAccent[400],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                height: 40,
                                                width: 70,
                                                child: Center(
                                                  child: Icon(
                                                    LineIcons.whatsapp,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Container buildAboutTab(double maxWidth) {
    return Container(
      color: Colors.grey[100],
      width: maxWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 40, bottom: 10),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: widget.pickedColor,
              child: Center(
                child: Text(//'adadsd',
                  dealerProfile.username[0].toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Text(
            dealerProfile.username,
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Private Dealer',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Icon(
                    Icons.verified_user,
                    color: Colors.green[300],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Card(
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.map),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        dealerProfile.state,
                        style: infoTextStyle,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Card(
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.email),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        dealerProfile.email,
                        style: infoTextStyle,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Card(
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.phone),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        dealerProfile.phone,
                        style: infoTextStyle,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton.icon(
                  // color: Colors.grey,
                  icon: Icon(
                    Icons.message,
                    size: 24,
                    color: Colors.blue,
                  ),
                  label: Text(
                    "Chat",
                    style: TextStyle(fontSize: 22),
                  ),
                  onPressed: () {},
                ),
                RaisedButton.icon(
                  color: Colors.yellow,
                  icon: Icon(
                    Icons.report,
                    size: 24,
                    color: Colors.red,
                  ),
                  label: Text("Report", style: TextStyle(fontSize: 22)),
                  onPressed: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  contactAlertDialog(BuildContext context) {
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
        launch("tel:${dealerProfile.phone}");
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
        
        return alert;
      },
    );
  }

  whatsappAlertDialog(BuildContext context) {
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
          launch("https://wa.me/6${dealerProfile.phone}");
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
        
        return alert;
      },
    );
  }

  
}
