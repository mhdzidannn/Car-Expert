import 'dart:math';

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../main/carDetailPage.dart';

class TopFeaturedDeal extends StatefulWidget {
  final List<Advertisment> topDeal;

  TopFeaturedDeal({this.topDeal});

  @override
  _TopFeaturedDealState createState() => _TopFeaturedDealState();
}

class _TopFeaturedDealState extends State<TopFeaturedDeal> {
  List<Advertisment> _topDeal;

  @override
  void initState() {
    _topDeal = widget.topDeal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Featured Deals'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _topDeal.length,
        itemBuilder: (context, index) {
          //LOCAL VARIABLE
          Advertisment car = _topDeal[index];
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
                        ))),
            child: Padding(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 10,
                  right: 10,
                  bottom: _topDeal.length == index + 1 ? 50 : 0),
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
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.camera_alt),
                                                  Text("No image available")
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
                                          'RM ${result.toStringAsFixed(0)}/month',
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
                                                      BorderRadius.circular(5)),
                                              child:
                                                  Center(child: Text('Used')),
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
                                                      BorderRadius.circular(5)),
                                              padding: EdgeInsets.all(2),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .check_circle_outline,
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
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: Text(
                                          car.adTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          print('PHONE');
                                        },
                                        onLongPress: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.yellow,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
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
                                          print('WAZAZZAAZAZAP');
                                        },
                                        onLongPress: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent[400],
                                              borderRadius:
                                                  BorderRadius.circular(4)),
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
      ),
    );
  }
}
