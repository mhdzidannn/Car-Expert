import 'dart:math';

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/searchNotifier.dart';
import 'package:carexpert/pages/main/carDetailPage.dart';
import 'package:carexpert/pages/user/dealerShowPage.dart';
import 'package:carexpert/pages/user/resultPage.dart';
import 'package:carexpert/pages/user/topDealPage.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  final String userUID;
  ExplorePage({Key key, this.userUID}) : super(key: key);

  @override
  _ExplorePage createState() => _ExplorePage();
}

class _ExplorePage extends State<ExplorePage> {
  Future<List<DealerDetails>> getDealerList;
  Future<List<Advertisment>> getTopDeal;

  @override
  void initState() {
    //ZAIDAN
    getDealerList = DatabaseService().getListPopularDealer();
    getTopDeal = DatabaseService().getTopTenDealForExplorePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Random random = Random();

    return RefreshIndicator(
      onRefresh: () => Future.delayed(Duration(seconds: 1)).then((_) 
      => setState(() => null)),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              pinned: true,
              centerTitle: true,
              expandedHeight: 230,
              elevation: 10,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue[200],Colors.blue]
                  )
                ),
                child: FlexibleSpaceBar(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Car Expert',
                        style: TextStyle(
                          fontSize: 20,
                          
                        ),
                      )
                    ],
                  ),
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 150,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 75,
                          ),
                          Text('What do you want to do today?'),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                            left: 60,
                            right: 60,
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/SearchPage'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: 270,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Search',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 155,
                                    ),
                                    Icon(
                                      LineIcons.search,
                                      size: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          _buildTopBrand(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          buildTopFeaturedDeal1(context),
          SliverToBoxAdapter(
              child: SizedBox(
            height: 15,
          )),
          buildTopDealerList(random),
        ],
      ),
    );
  }

  SliverToBoxAdapter buildTopDealerList(Random random) {
    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.white),
            child: FutureBuilder<List<DealerDetails>>(
              future: getDealerList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      //UserDetails dealer = snapshot.data[index];
                      DealerDetails dealer = snapshot.data[index];
                      int pickedColor = random.nextInt(colorListPicker.length);
                      return Container(
                        width: 160,
                        padding: EdgeInsets.only(top: 50, bottom: 10, left: 10),
                        child: GestureDetector(
                          onLongPress: () {},
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DealerShowPage(
                                        dealerProfile: dealer,
                                        pickedColor:
                                            colorListPicker[pickedColor],
                                      ))),
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor:
                                        colorListPicker[pickedColor],
                                    maxRadius: 40,
                                    child: Text(
                                      dealer.username[0].toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${dealer.username}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20, 
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
                    child: Container(
                        color: Colors.white,
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          Positioned(
            child: Container(
                padding: EdgeInsets.only(left: 13, top: 11),
                child: Text(
                  'Popular Dealers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ),
          // Positioned(
          //   right: 0,
          //   child: FlatButton(
          //     onPressed: null,
          //     child: RichText(
          //       text: TextSpan(
          //         style: TextStyle(color: Colors.grey[700]),
          //         children: <TextSpan>[
          //           TextSpan(text: 'VIEW MORE ',style: TextStyle(fontSize: 11)),
          //           TextSpan(text: ' >', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
          //         ]
          //       ),
          //     )
          //   )
          // )
        ],
      ),
    );
  }

  SliverToBoxAdapter buildTopFeaturedDeal1(BuildContext context) {
    return SliverToBoxAdapter(
        child: FutureBuilder<List<Advertisment>>(
      future: getTopDeal,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return Center(
              child: Text("No Ads"),
            );
          } else {
            return Stack(
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length > 5
                              ? 5
                              : snapshot.data.length,
                          itemBuilder: (context, index) {
                            Advertisment data = snapshot.data[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 20,
                                  top: 50,
                                  bottom: 10,
                                  right: index + 1 == 5 ? 20 : 0),
                              child: Container(
                                  width: 210,
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CarDetailPage(
                                            advertDoc: data,
                                          ),
                                        )),
                                    child: Card(
                                      elevation: 10,
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 10,
                                              child: data.carImages == null
                                                  ? Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      color: Colors.grey[200],
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.camera_alt,
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            'No image available',
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ))
                                                  : Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      child: Image.network(
                                                        data.carImages[0],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 14),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      data.adTitle,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'RM ${data.price.toString().replaceAllMapped(regPrice, mathFuncPrice)}',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  child: Container(
                      padding: EdgeInsets.only(left: 13, top: 11),
                      child: Text(
                        'Hot Deals',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ),
                Positioned(
                    right: 0,
                    child: FlatButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TopFeaturedDeal(topDeal: snapshot.data),
                            )),
                        child: RichText(
                          text: TextSpan(
                              style: TextStyle(color: Colors.grey[700]),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'VIEW DETAILS ',
                                    style: TextStyle(fontSize: 11)),
                                TextSpan(
                                    text: ' >',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))
                              ]),
                        )))
              ],
            );
          }
        } else {
          return Container(
            height: 250,
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    ));
  }

  SliverToBoxAdapter _buildTopBrand() {
    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Consumer<SearchNotifier>(
            builder: (context, search, widget) {
              return Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                        child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            search.resetAllQuery();
                            search.setBrandRef = 'Honda';
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ResultPage(),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                            width: 135,
                            child: Card(
                              elevation: 5,
                              child: Image.asset(
                                'assets/CarLogo/honda.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            search.resetAllQuery();
                            search.setBrandRef = 'Toyota';
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ResultPage(),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                            width: 135,
                            child: Card(
                              elevation: 5,
                              child: Image.asset(
                                'assets/CarLogo/toyota.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            search.resetAllQuery();
                            search.setBrandRef = 'Proton';
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ResultPage(),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                            width: 135,
                            child: Card(
                              elevation: 5,
                              child: Image.asset(
                                'assets/CarLogo/proton.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            search.resetAllQuery();
                            search.setBrandRef = 'Perodua';
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ResultPage(),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                            width: 135,
                            child: Card(
                              elevation: 5,
                              child: Image.asset(
                                'assets/CarLogo/perodua.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
                height: 180,
                decoration: BoxDecoration(color: Colors.white),
              );
            },
          ),
          Positioned(
            child: Container(
                padding: EdgeInsets.only(left: 13, top: 11),
                child: Text(
                  'Popular Brands',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ),
          // Positioned(
          //     right: 0,
          //     child: FlatButton(
          //         onPressed: null,
          //         child: RichText(
          //           text: TextSpan(
          //               style: TextStyle(color: Colors.grey[700]),
          //               children: <TextSpan>[
          //                 TextSpan(
          //                     text: 'VIEW MORE ',
          //                     style: TextStyle(fontSize: 11)),
          //                 TextSpan(
          //                     text: ' >',
          //                     style: TextStyle(
          //                         fontWeight: FontWeight.bold, fontSize: 15))
          //               ]),
          //         )))
        ],
      ),
    );
  }
}
