import 'package:cached_network_image/cached_network_image.dart';
import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:line_icons/line_icons.dart';
import 'package:carexpert/pages/user/calculatorPage.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/services/auth_service.dart';

class CarDetailPage extends StatefulWidget {
  final Advertisment advertDoc;
  DealerDetails dealerDetail = DealerDetails();

  CarDetailPage(
      {Key key, this.advertDoc, this.dealerDetail}) : super(key: key);
  //CarDetailPage({Key key, this.advertDoc}) : super(key:key);

  @override
  _CarDetailPage createState() => _CarDetailPage();
}

class _CarDetailPage extends State<CarDetailPage> with TickerProviderStateMixin {
  TabController _tabController;
  double _top = 340;
  Advertisment _adData;
  CarSpecification _adCarSpec;
  DealerDetails _dealerDetail;
  String carType;
  String message = 'I am interested to know more about your car';
  // List<NetworkImage> _listOfImages = <NetworkImage>[];

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    _adData = widget.advertDoc;

    if (widget.dealerDetail == null ) {
      //get uid of the seller instead of the own user
      AuthService().getDealerProfileLocal(_adData.uid).then((value) {
        setState(() => _dealerDetail = value);
        print('[CarDetailPage] Dealer Detail A : ${_dealerDetail.email}');
      });
    } else {
      //somehow never got to here lmao
      _dealerDetail = widget.dealerDetail;
      print('[CarDetailPage] Dealer Detail B : ${_dealerDetail.email}');
    }

    DatabaseService()
        .getCarSpecificationAdvertisment(widget.advertDoc)
        .then((value) {
      setState(() => _adCarSpec = value);
      print('[CarDetailPage] Loaded Car Specification : ${_adCarSpec.carDesc}');
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {

     UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);

    if (_adCarSpec == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
          body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              buildSliverAppBar(),
              carPrice(),
              spacers(),
              generalSpecs(),
              spacers(),
              carDetailsTab(),
              spacers(),
              documentDetails(),
              spacers(),
              if (!notifier.dealerMode) ...{
                sellerData(),
              },
              SliverToBoxAdapter(
                child: ColoredBox(
                    child: SizedBox(height: notifier.dealerMode ? 20 : 100),
                    color: Colors.grey[200]),
              )
            ],
          ),
          if (!notifier.dealerMode) ...{contactButton()}
        ],
      ));
    }
  }

  Positioned contactButton() {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        color: Colors.white,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 50,
                width: 170,
                child: RaisedButton.icon(
                  onPressed: () {
                    contactAlertDialog(context);
                  },
                  color: Colors.yellow,
                  elevation: 5,
                  icon: Icon(
                    Icons.phone,
                    size: 27,
                  ),
                  label: Text(
                    'Contact',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 170,
                child: RaisedButton.icon(
                  onPressed: () {
                    whatsappAlertDialog(context);
                  },
                  color: Colors.greenAccent[400],
                  elevation: 5,
                  icon: Icon(
                    LineIcons.whatsapp,
                    size: 27,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Whatsapp',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
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
        return alert;
      },
    );
  }

  deleteAlertDialog() {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget launchButton =
        Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return FlatButton(
        child: Text("Delete"),
        onPressed: () {
          //ZAIDAN
          // DatabaseService().deleteUserAdvertisment(
          //     _adData.docID, notifier, _adData.carImages);
          Navigator.of(context).pop(true);
          Navigator.pop(context);
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

  SliverToBoxAdapter spacers() {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: Colors.grey[200],
        child: SizedBox(
          height: 10,
        ),
      ),
    );
  }

  List<CachedNetworkImage> _getUrlImages(List<dynamic> imageURL) {
    List<CachedNetworkImage> temp = List<CachedNetworkImage>();
    imageURL.forEach((url) => temp.add(CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: url,
          progressIndicatorBuilder: (context, noti, progress) {
            return Container(
              color: Colors.grey[200],
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.progress,
                ),
              ),
            );
          },
        )));
    return temp;
  }

  SliverAppBar buildSliverAppBar() {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    List<CachedNetworkImage> _listofImage = List<CachedNetworkImage>();
    String _createdAt = timeago
        .format(DateTime.tryParse(_adData.dateCreated.toDate().toString()))
        .toString();
    String _updatedAt;
    if (_adData.dateUpdated != null)
      _updatedAt = timeago
              .format(
                  DateTime.tryParse(_adData.dateUpdated.toDate().toString()))
              .toString() ??
          null;

    if (_adData.carImages != null) {
      _listofImage = _getUrlImages(_adData.carImages);
    }

    return SliverAppBar(
        pinned: true,
        actions: <Widget>[
          if (notifier.dealerMode) ...{
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: null,
            )
          } else ...{
            Consumer<UserDetails>(
              builder: (context, value, widget) {
                if (value != null) {
                  if (value.likedCars.contains(_adData.docID)) {
                    return IconButton(
                      icon: Icon(Icons.favorite),
                      color: Colors.red,
                      onPressed: () => DatabaseService().updateLikeCountAndStatus(_adData, notifier, false),
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => DatabaseService().updateLikeCountAndStatus(_adData, notifier, true),
                    );
                  }
                } else {return Icon(Icons.track_changes);}
              },
            )
          }
        ],
        expandedHeight: 316,
        flexibleSpace: LayoutBuilder(
          builder: (context, constraint) {
            _top = constraint.biggest.height;
            // print(_top);
            return FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.only(right: 50, left: 60, bottom: 17),
              title: AnimatedOpacity(
                opacity: _top < 270.0 ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: Text(
                  '${_adData.adTitle}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _top < 226.0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
              background: Column(
                children: <Widget>[
                  if (_adData.carImages != null) ...{
                    // Expanded(
                    // child: ListView.builder(
                    // scrollDirection: Axis.horizontal,
                    // shrinkWrap: true,
                    // itemCount: _adData.carImages.length,
                    // itemBuilder: (context, count) {
                    //   _listOfImages = [];
                    //   for (int i = 0; i < _adData.carImages.length; i++) {
                    //             _listOfImages.add(NetworkImage(_adData.carImages[i]));
                    //           }
                    // return Container(
                    //   height: 250,
                    //   width: MediaQuery.of(context).size.width,
                    // child: Carousel(
                    //   boxFit: BoxFit.cover,
                    //   images: _listOfImages,
                    //   dotSize: 5.0,
                    //   dotBgColor: Colors.transparent,
                    //   dotIncreasedColor: Colors.black,
                    //   indicatorBgPadding: 10,
                    //   autoplay: false,
                    // ),
                    // );
                    // }
                    // )
                    // ),

                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        // height: 250,
                        child: Carousel(
                          boxFit: BoxFit.cover,
                          images: _listofImage,
                          dotSize: 5.0,
                          dotBgColor: Colors.transparent,
                          dotIncreasedColor: Colors.black,
                          indicatorBgPadding: 10,
                          autoplay: false,
                        ),
                      ),
                    )
                  } else ...{
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        'assets/images/noimage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  },
                  Container(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.grey, width: 0.01))),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 15,
                          top: 12,
                          // child: Text(
                          //   'Updated on $_createdAt',   // for now use dateCreated
                          child: Text(
                            _adData.dateUpdated == null
                                ? 'Created: $_createdAt'
                                : 'Updated: $_updatedAt',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 13,
                                color: Colors.grey[600]),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, top: 35, right: 15),
                          child: Text(
                            '${_adData.adTitle}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  SliverToBoxAdapter carPrice() {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Colors.grey, width: 0.4),
                bottom: BorderSide(color: Colors.grey, width: 0.4))),
        child: Padding(
          padding: EdgeInsets.only(left: 17, right: 17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                //'RM 500,000',
                'RM ${_adData.price.toString().replaceAllMapped(regPrice, mathFuncPrice)}',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              IconButton(
                color: Colors.blue,
                icon: Icon(LineIcons.calculator),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalculatorPage(
                                realCarPrice: _adData.price,
                              ) //temp directory
                          ));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter generalSpecs() {
    if (_adCarSpec.transmission == null) {
      carType = 'Auto';
    } else {
      carType = 'Manual';
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 211,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                // bottom: BorderSide(width: 0.4, color: Colors.grey),
                // top: BorderSide(width: 0.4, color: Colors.grey)
                )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey),
                        top: BorderSide(width: 0.6, color: Colors.grey))),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        left: 20,
                        top: 17,
                        child: Icon(
                          LineIcons.calendar,
                          size: 35,
                        )),
                    Positioned(
                        left: 80,
                        top: 25,
                        child: Text(
                          '${_adData.year}',
                          style: TextStyle(fontSize: 18),
                        )),
                    Positioned(
                        left: 230,
                        top: 17,
                        child: Icon(LineIcons.tachometer, size: 35)),
                    Positioned(
                        left: 290,
                        top: 25,
                        child: Text(
                          '${_adData.mileage} KM',
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                )),
            Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(width: 0.6, color: Colors.grey))),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        left: 20,
                        top: 17,
                        child: Icon(
                          LineIcons.archive,
                          size: 35,
                        )),
                    Positioned(
                        left: 80,
                        top: 25,
                        child: Text(
                          '${_adData.plateNum}',
                          style: TextStyle(fontSize: 18),
                        )),
                    Positioned(
                        left: 230,
                        top: 17,
                        child: Icon(LineIcons.space_shuttle, size: 35)),
                    Positioned(
                        left: 290,
                        top: 25,
                        child: Text(
                          '${_adCarSpec.carEngine['EngineCC']} cc',
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                )),
            Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(width: 0.6, color: Colors.grey),
                        top: BorderSide(width: 0.1, color: Colors.grey))),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        left: 20,
                        top: 17,
                        child: Icon(
                          LineIcons.map_marker,
                          size: 35,
                        )),
                    Positioned(
                        left: 80,
                        top: 25,
                        child: Text(
                          '${_adData.location}',
                          style: TextStyle(fontSize: 18),
                        )),
                    Positioned(
                        left: 230,
                        top: 17,
                        child: Icon(LineIcons.car, size: 35)),
                    Positioned(
                        left: 290,
                        top: 25,
                        child: Text(
                          '$carType',
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter carDetailsTab() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.grey),
                top: BorderSide(width: 0.5, color: Colors.grey))),
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              unselectedLabelColor: Colors.black,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              tabs: <Widget>[
                Tab(
                  text: 'Seller\'s Comment',
                ),
                Tab(
                  text: 'Specification',
                )
              ],
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 25, bottom: 50),
                        child: Container(
                            child: Text(
                          "${_adData.adDescription}",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        )),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          child: Text(
                            'Read all comments',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => sellersCommentPage(),
                              )),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 50),
                        child: _adCarSpec.layout == null
                            ? Center(child: CircularProgressIndicator())
                            : ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      'Layout',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                    trailing: Text(
                                      '${_adCarSpec.layout}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      'Engine Cc',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                    trailing: Text(
                                      '${_adCarSpec.carEngine['EngineCC']}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      'Fuel Type',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                    trailing: Text(
                                      '${_adCarSpec.carEngine['FeulType']}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      'Seat Capacity',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                    trailing: Text(
                                      '${_adCarSpec.generalSpec['SeatCapacity']}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                ],
                              ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          child: Text(
                            'See more details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => carSpecificationPage(),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  DefaultTabController carSpecificationPage() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Specification'),
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16),
            unselectedLabelColor: Colors.black,
            tabs: <Widget>[
              Tab(
                text: 'General',
              ),
              Tab(
                text: 'Dimensions',
              ),
              Tab(
                text: 'Engine',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TabBarView(
              children: <Widget>[
                ListView.separated(
                  itemCount: _adCarSpec.generalSpecKey.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${_adCarSpec.generalSpecKey[index]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      trailing: Text(
                        '${_adCarSpec.generalSpec[_adCarSpec.generalSpecKey[index]]}',
                        style: TextStyle(fontSize: 13),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1,
                    );
                  },
                ),
                ListView.separated(
                  itemCount: _adCarSpec.carDimensionKey.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${_adCarSpec.carDimensionKey[index]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      trailing: Text(
                        '${_adCarSpec.carDimension[_adCarSpec.carDimensionKey[index]]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1,
                    );
                  },
                ),
                ListView.separated(
                  itemCount: _adCarSpec.carEngineKey.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${_adCarSpec.carEngineKey[index]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      trailing: Text(
                        '${_adCarSpec.carEngine[_adCarSpec.carEngineKey[index]]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Scaffold sellersCommentPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller\'s Comments'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 30),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text('${_adData.adDescription}'),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter documentDetails() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 0.4, color: Colors.grey),
          top: BorderSide(width: 0.4, color: Colors.grey),
        )),
        width: MediaQuery.of(context).size.width,
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      '${_adData.docID}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      size: 26,
                      color: Colors.blue,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    'Share',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter sellerData() {
    if (_dealerDetail == null) {
      return SliverToBoxAdapter();
    } else {
      return SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(width: 0.4, color: Colors.grey),
            top: BorderSide(width: 0.4, color: Colors.grey),
          )),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: Text('${_dealerDetail.username}'),
            subtitle: Text('${_dealerDetail.email}'),
            leading: CircleAvatar(
              child: Text('${_dealerDetail.username[0].toUpperCase()}'),
              radius: 30,
            ),
            trailing: Icon(
              Icons.thumb_up,
              color: Colors.green[300],
            ),
          ),
        ),
      );
    }
  }
}
