import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/model/search.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/searchNotifier.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  GlobalKey<ScaffoldState> _searchScaffoldState;

  @override
  void initState() {
    _searchScaffoldState = GlobalKey();
    super.initState();
  }

  void reRunFuture() {
    setState(() {});
  }

  void dispose() {
    super.dispose();
  }

  DealerDetails _dealerDetail;

  @override
  Widget build(BuildContext context) {
    SearchNotifier searchData = Provider.of<SearchNotifier>(context, listen: false);

    return Scaffold(
      key: _searchScaffoldState,
      endDrawerEnableOpenDragGesture: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Search results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[Container()],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(elevation: 10, child: Icon(Icons.assignment), onPressed: () => _searchScaffoldState.currentState.openEndDrawer()
          // onPressed: () => _reRunFuture(),
          ),
      endDrawer: FilterDrawer(this.reRunFuture),
      body: FutureBuilder<List<Advertisment>>(
        future: DatabaseService().getSearchResult(searchData),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data.isNotEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[Colors.lightBlue[50], Colors.white]),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 20, bottom: 5),
                                    child: Text(
                                      '${snapshot.data.length} Cars available',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  buildCarTabLarge(snapshot, index, context)
                                ],
                              );
                            }
                            return buildCarTabLarge(snapshot, index, context);
                          },
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    // stops: [0.2,0.3],
                    colors: <Color>[Colors.lightBlue[50], Colors.white],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 225,
                        width: 225,
                        child: Image.asset('assets/images/noResult2.png', fit: BoxFit.scaleDown),
                      ),
                      Padding(
                        padding: EdgeInsets.only(),
                        child: Text(
                          'No Result ?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                );
              }
            } else {
              return Center(
                child: Text('Can\'t find your dream car.'),
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

  Padding buildCarTabLarge(AsyncSnapshot<List<Advertisment>> snapshot, int index, BuildContext context) {
    Advertisment car = snapshot.data[index];
    var formatter = NumberFormat.compact();
    double r = 3.55 / 12 / 100;
    double n = 5.0 * 12;
    double result = (car.price * r * pow((1 + r), n) / (pow((1 + r), n) - 1));

    List<CachedNetworkImage> _imageList = List<CachedNetworkImage>();
    if (car.carImages != null) {
      car.carImages.forEach((url) => _imageList.add(CachedNetworkImage(
            imageUrl: url,
            progressIndicatorBuilder: (context, string, progress) => CircularProgressIndicator(value: progress.progress),
            fit: BoxFit.cover,
          )));
    }

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: snapshot.data.length == index + 1 ? 50 : 0),
      child: Card(
        elevation: 10,
        child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarDetailPage(
                  advertDoc: car,
                ),
              )),
          child: Container(
              height: 450,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Expanded(
                      flex: 10,
                      child: Stack(
                        children: <Widget>[
                          if (car.carImages == null) ...{
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Icon(
                                    Icons.camera_alt,
                                    size: 34,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'No Image Uploaded',
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          } else ...{
                            Carousel(
                              boxFit: BoxFit.cover,
                              dotSize: 4.0,
                              dotBgColor: Colors.transparent,
                              dotIncreaseSize: 2,
                              dotSpacing: 10,
                              dotVerticalPadding: 0,
                              indicatorBgPadding: 10,
                              autoplay: false,
                              images: _imageList,
                            ),
                          },
                          Positioned(
                            bottom: 15,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'RM ${result.toStringAsFixed(0)}/month',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'RM ${car.price.toString().replaceAllMapped(regPrice, mathFuncPrice)}',
                                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              // color: Colors.red,
                              height: 30,
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                car.adTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                '${formatter.format(car.mileage)} KM  -  Automatic  -  ${car.location}',
                                style: TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  height: 22,
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                                  child: Center(child: Text('Used')),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 22,
                                  width: 70,
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                          child: Center(
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Center(
                                          child: Text('Dealer'),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(border: Border(top: BorderSide(width: 2, color: Colors.grey[200]))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                print('PHONE');
                                contactAlertDialog(context, car);
                              },
                              onLongPress: () {},
                              child: Container(
                                  decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(4)),
                                  height: 55,
                                  width: 140,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.phone,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          'Contact',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                print('WHAZAZAZAAZAZAZAz');
                                whatsappAlertDialog(context, car);
                              },
                              onLongPress: () {},
                              child: Container(
                                  decoration: BoxDecoration(color: Colors.greenAccent[400], borderRadius: BorderRadius.circular(4)),
                                  height: 55,
                                  width: 144,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        LineIcons.whatsapp,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          'Whatsapp',
                                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  contactAlertDialog(BuildContext context, Advertisment data) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
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
      content: Text("Clicking 'Proceed' will leave the Car Expert app and open the phone dialler of your phone. Proceed?"),
      actions: [
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
        Navigator.pop(context);
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
      content: Text("Clicking 'Proceed' will leave the Car Expert app and open Whatsapp on your phone. Proceed?"),
      actions: [
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

class FilterDrawer extends StatefulWidget {
  Function reRunFuture;

  FilterDrawer(this.reRunFuture);
  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  List<String> priceList = priceQuery.keys.toList();
  List<String> mileageList = mileageQuery.keys.toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SearchNotifier notifier = Provider.of<SearchNotifier>(context, listen: true);

    return Drawer(
        child: Container(
      // color: Colors.blue,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 40,
                  ),
                  child: Text(
                    'Filter Search',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey),
                  ),
                ),
                _carBrandandModel(),
                _carCondition(),
                SizedBox(
                  height: 5,
                ),
                _carStatusSelector(),
                _carGeneralSpecOne(),
                _carGeneralSpecTwo(),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Consumer<SearchNotifier>(
                    builder: (context, noti, widget) {
                      if (noti.getBrandRef == 'Brand' &&
                          noti.getCarLayout == 'Select driven wheel' &&
                          noti.getState == 'Select State' &&
                          noti.getBodyType == 'Select body type' &&
                          noti.getCondition == 'All' &&
                          noti.getTransmission == 'All' &&
                          noti.getPrice == 'Any price' &&
                          noti.getMaxPrice == 'Any price' &&
                          noti.getMileage == 'Any Mileage' &&
                          noti.getMaxMileage == 'Any Mileage' &&
                          noti.getModelYear == 'Any year' &&
                          noti.getMaxModelYear == 'Any year') {
                        return Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                            child: RaisedButton(
                              child: Container(
                                  height: 50,
                                  child: Center(
                                      child: Text(
                                    'Reset',
                                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                  ))),
                              onPressed: null,
                            ),
                          ),
                        );
                      } else {
                        return Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                            child: RaisedButton(
                              color: Colors.yellow,
                              child: Container(
                                  height: 50,
                                  child: Center(
                                      child: Text(
                                    'Reset',
                                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                  ))),
                              onPressed: () => noti.resetAllQueryFilter(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: RaisedButton(
                          color: Colors.blue,
                          child: Container(
                              height: 50,
                              child: Center(
                                  child: Text(
                                'Apply',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ))),
                          onPressed: () {
                            this.widget.reRunFuture();
                            Navigator.pop(context);
                          }),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _carBrandandModel() {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: Card(
              elevation: 1,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 15,
                    left: 19,
                    child: Text(
                      'Select Brand, Model & Variant',
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                            width: 260,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: notifier.getBrandRef,
                                  onChanged: (val) {
                                    notifier.setBrandRef = val;
                                    notifier.setCarModel = 'Model';
                                  },
                                  items: brandModelVer2.keys.toList().map((String _brand) {
                                    return DropdownMenuItem(
                                      value: _brand,
                                      child: Text(_brand),
                                    );
                                  }).toList(),
                                  elevation: 1,
                                  isExpanded: true,
                                  hint: Text(
                                    'Brand',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          //MODEL CAR SELECTOR
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                            width: 260,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  disabledHint: Text(
                                    'Model',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  value: notifier.getBrandRef == 'Brand' ? null : notifier.getCarModel,
                                  onChanged: (val) {
                                    notifier.setCarModel = val;
                                    notifier.setCarVariant = 'Variant';
                                  },
                                  items: notifier.getBrandRef == 'Brand'
                                      ? null
                                      : brandModelVer2[notifier.getBrandRef].toList().map((String _model) {
                                          return DropdownMenuItem(
                                            value: _model,
                                            child: Text(_model),
                                          );
                                        }).toList(),
                                  elevation: 1,
                                  isExpanded: true,
                                  hint: Text(
                                    'Model',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          //VARIANTs CAR SELECTOR
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                            width: 260,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  disabledHint: Text(
                                    'Variant',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  value: notifier.getCarModel == 'Model' ? null : notifier.getCarVariant,
                                  onChanged: (val) {
                                    notifier.setCarVariant = val;
                                    notifier.setCarVariantDoc = notifier.getCarVariatMap[val];
                                  },
                                  items: notifier.getCarModel == 'Model'
                                      ? null
                                      : (notifier.getCarVariantList == null
                                          ? null
                                          : notifier.getCarVariantList.map((variant) {
                                              return DropdownMenuItem(
                                                value: variant,
                                                child: Text(variant),
                                              );
                                            }).toList()),
                                  elevation: 1,
                                  isExpanded: true,
                                  hint: Text(
                                    'Variant',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _carCondition() {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 210,
            child: Card(
              elevation: 1,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 15,
                    left: 20,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Condition',
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Tooltip(
                            showDuration: Duration(minutes: 3),
                            padding: EdgeInsets.all(8),
                            preferBelow: false,
                            margin: EdgeInsets.only(left: 35, right: 35),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(6)),
                            message: notifier.getCondition == 'Used'
                                ? 'Used cars by dealers and previous owners where the cars are used beforehand'
                                : notifier.getCondition == 'New'
                                    ? 'New cars by dealers straight from the factory ulala'
                                    : 'The condition of the cars, either New or Used.\n\nBy default, both New and Used cars will be included in the results',
                            child: Icon(
                              Icons.info,
                              size: 15,
                              color: Colors.cyan,
                            ))
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 20,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Select State',
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Tooltip(
                            showDuration: Duration(minutes: 3),
                            padding: EdgeInsets.all(8),
                            preferBelow: false,
                            margin: EdgeInsets.only(left: 35, right: 35),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(6)),
                            message: 'The state where the cars are currently located',
                            child: Icon(
                              Icons.info,
                              size: 15,
                              color: Colors.cyan,
                            ))
                      ],
                    ),
                    // ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => notifier.setCarCondition = 'All',
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'All' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getCondition == 'All' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(),
                              child: GestureDetector(
                                onTap: () => notifier.setCarCondition = 'New',
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'New' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'NEW',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getCondition == 'New' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: () => notifier.setCarCondition = 'Used',
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'Used' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'USED',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getCondition == 'Used' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                          width: 260,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: notifier.getState,
                                onChanged: (val) => notifier.setState = val,
                                items: <DropdownMenuItem<String>>[
                                  DropdownMenuItem(
                                    child: Text('Select State'),
                                    value: 'Select State',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Johor'),
                                    value: 'Johor',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Kedah'),
                                    value: 'Kedah',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Kelantan'),
                                    value: 'Kelantan',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Melaka'),
                                    value: 'Melaka',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('N. Sembilan'),
                                    value: 'N. Sembilan',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Pahang'),
                                    value: 'Pahang',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('P. Pinang'),
                                    value: 'Pulau Pinang',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Perak'),
                                    value: 'Perak',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Perlis'),
                                    value: 'Perlis',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Sabah'),
                                    value: 'Sabah',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Sarawak'),
                                    value: 'Sarawak',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Selangor'),
                                    value: 'Selangor',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Terengganu'),
                                    value: 'Terengganu',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('K. Lumpur'),
                                    value: 'K. Lumpur',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Labuan'),
                                    value: 'Labuan',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Putrajaya'),
                                    value: 'Putrajaya',
                                  ),
                                ],
                                elevation: 1,
                                isExpanded: true,
                                hint: Text(
                                  'State',
                                  style: TextStyle(color: Colors.black),
                                ),
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _carStatusSelector() {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 260,
            child: Card(
              elevation: 1,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 15,
                    top: 20,
                    child: Text(
                      'Price, Year & Mileage',
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    top: 45,
                    left: 40,
                    child: Text('min :'),
                  ),
                  Positioned(
                    top: 45,
                    left: 205,
                    child: Text('max :'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: notifier.getPrice,
                                      onChanged: (val) {
                                        notifier.setPrice = val;
                                        notifier.setMinPriceList = val;
                                      },
                                      items: notifier.getMaxPrice == 'Any price'
                                          ? notifier.getDefaultPriceList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()
                                          : notifier.getMaxPriceList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()),
                                ),
                              ),
                            ),
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: notifier.getMaxPrice,
                                      onChanged: (val) {
                                        notifier.setMaxPrice = val;
                                        notifier.setMaxPriceList = val;
                                      },
                                      items: notifier.getPrice == 'Any price'
                                          ? notifier.getDefaultPriceList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()
                                          : notifier.getMinPriceList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          // YEAR ======================================================================================
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: notifier.getModelYear,
                                    onChanged: (val) => notifier.setYear = val,
                                    items: yearQuery.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: notifier.getMaxModelYear,
                                    onChanged: (val) => notifier.setMaxYear = val,
                                    items: yearQuery.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          // MILEAGE ======================================================================================
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: notifier.getMileage,
                                      onChanged: (val) {
                                        notifier.setMileage = val;
                                        notifier.setMinMileageList = val;
                                      },
                                      items: notifier.getMaxMileage == 'Any Mileage'
                                          ? notifier.getDefaultMileageList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()
                                          : notifier.getMaxMileageList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()),
                                ),
                              ),
                            ),
                            Container(
                              width: 135,
                              decoration: BoxDecoration(border: Border.all(width: 0.1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: notifier.getMaxMileage,
                                      onChanged: (val) {
                                        notifier.setMaxMileage = val;
                                        notifier.setMaxMileageList = val;
                                      },
                                      items: notifier.getMileage == 'Any Mileage'
                                          ? notifier.getDefaultMileageList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()
                                          : notifier.getMinMileageList.map<DropdownMenuItem<String>>((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList()),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _carGeneralSpecOne() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 225,
        child: Card(
            elevation: 1,
            color: Colors.white,
            child: Consumer<SearchNotifier>(
              builder: (context, notifier, widget) {
                return Stack(children: <Widget>[
                  Positioned(
                    top: 25,
                    left: 20,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Body Type',
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Tooltip(
                            showDuration: Duration(minutes: 3),
                            padding: EdgeInsets.all(8),
                            preferBelow: false,
                            margin: EdgeInsets.only(left: 35, right: 35),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(6)),
                            message: notifier.getBodyType == 'Hatchback'
                                ? 'A compact or subcompact sedan with a squared-off roof and a rear flip-up hatch door that provides access to the vehicle\'s cargo area instead of a conventional trunk.'
                                : notifier.getBodyType == 'Sedan'
                                    ? 'Has four doors and a traditional trunk.'
                                    : notifier.getBodyType == 'SUV'
                                        ? 'Sport-Utility Vehicle is taller and boxier than sedans, offer an elevated seating position, and have more ground clearance'
                                        : notifier.getBodyType == 'Mini Van'
                                            ? 'Family-car, the best at carrying people and cargo in an efficient package.'
                                            : notifier.getBodyType == 'MPV'
                                                ? 'Multi Purpose Vehicle, or people carrier, is typically a large hatchback with seating for six or more.'
                                                : notifier.getBodyType == 'Coupe'
                                                    ? 'A two-door car with a trunk and a solid roof'
                                                    : 'Car classification schemes that are used for various purposes including regulation, description and categorization of cars.\n\nSelect a body type to display its description.',
                            child: Icon(
                              Icons.info,
                              size: 15,
                              color: Colors.cyan,
                            ))
                      ],
                    ),
                  ),
                  Positioned(
                    top: 125,
                    left: 20,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Driven Wheel',
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Tooltip(
                            showDuration: Duration(minutes: 3),
                            padding: EdgeInsets.all(8),
                            preferBelow: false,
                            margin: EdgeInsets.only(left: 35, right: 35),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(6)),
                            message: notifier.getCarLayout == '2WD'
                                ? '[2WD] Vehicles that transmit torque to at most two road wheels, referred to as either front- or rear-wheel drive.'
                                : notifier.getCarLayout == '4WD'
                                    ? '[4WD] This configuration allows all four road wheels to receive torque from the power plant simultaneously, common in off-road vehicles.'
                                    : notifier.getCarLayout == 'AWD'
                                        ? '[AWD] An all-wheel drive vehicle is one with a powertrain capable of providing power to all its wheels, whether full-time or on-demand.'
                                        : notifier.getCarLayout == 'FWD'
                                            ? '[FWD] Front-wheel drive vehicles engines drive the front wheels.'
                                            : notifier.getCarLayout == 'RWD'
                                                ? '[RWD] Rear-wheel drive vehicles typically places the engine in the front of the vehicle, with a driveshaft running the length of the vehicle to the differential transmission.'
                                                : 'A drive wheel is a wheel of a motor vehicle that transmits force, transforming torque into tractive force from the tires to the road, causing the vehicle to move.\n\nExample: A two-wheel drive vehicle has two driven wheels, typically both at the front or back, while a four-wheel drive has four.',
                            child: Icon(
                              Icons.info,
                              size: 15,
                              color: Colors.cyan,
                            ))
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                            width: 260,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: notifier.getBodyType,
                                  onChanged: (val) => notifier.setBodyType = val,
                                  items: bodyTypeRefMap.keys.toList().map((bodytype) {
                                    return DropdownMenuItem(
                                      value: bodyTypeRefMap[bodytype],
                                      child: Text(bodytype),
                                    );
                                  }).toList(),
                                  elevation: 1,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select body type',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                            width: 260,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: notifier.getCarLayout,
                                  onChanged: (val) => notifier.setLayout = val,
                                  items: layoutRefMap.keys.toList().map((layout) {
                                    return DropdownMenuItem(
                                      value: layoutRefMap[layout],
                                      child: Text(layout),
                                    );
                                  }).toList(),
                                  elevation: 1,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select driven wheel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]);
              },
            )),
      ),
    );
  }

  Widget _carGeneralSpecTwo() {
    return Consumer<SearchNotifier>(builder: (context, notifier, widget) {
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: Card(
            elevation: 1,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 15,
                  top: 20,
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Transmission',
                        style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Tooltip(
                          showDuration: Duration(minutes: 3),
                          padding: EdgeInsets.all(8),
                          preferBelow: false,
                          margin: EdgeInsets.only(left: 35, right: 35),
                          decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(6)),
                          message: notifier.getTransmission == 'Manual'
                              ? 'The car\'s gearbox. \n\n[Manual] = The car\'s gears changes manually by the driver through the gearbox and cluth control.'
                              : notifier.getTransmission == 'auto'
                                  ? 'The car\'s gearbox. \n\n[Automatic] = The car\'s gears changes automatically by the car.'
                                  : 'The car\'s gearbox. \n\n[Automatic] = The car\'s gears changes automatically by the car.\n[Manual] = The car\'s gears changes manually by the driver through the gearbox and cluth control.',
                          child: Icon(
                            Icons.info,
                            size: 15,
                            color: Colors.cyan,
                          ))
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => notifier.setTransmission = 'All',
                                child: Container(
                                  width: 60,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getTransmission == 'All' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getTransmission == 'All' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(),
                              child: GestureDetector(
                                onTap: () => notifier.setTransmission = 'auto',
                                child: Container(
                                  width: 100,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getTransmission == 'auto' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'AUTOMATIC',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getTransmission == 'auto' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: () => notifier.setTransmission = 'Manual',
                                child: Container(
                                  width: 80,
                                  height: 30,
                                  decoration: BoxDecoration(color: notifier.getTransmission == 'Manual' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'MANUAL',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getTransmission == 'Manual' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
