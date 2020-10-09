import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/searchNotifier.dart';
import 'package:carexpert/pages/user/resultPage.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  SearchNotifier initialQuery;
  List<String> priceList = priceQuery.keys.toList();
  List<String> mileageList = mileageQuery.keys.toList();

  @override
  void initState() {
    super.initState();
    initialQuery = Provider.of<SearchNotifier>(context, listen: false);
    initialQuery.initialQuery();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  bool _isSearchMode = false;

  @override
  Widget build(BuildContext context) {
    SearchNotifier searchQuery = Provider.of<SearchNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.search_ellipsis,
              progress: _animationController,
            ),
            onPressed: () => setState(() {
              _isSearchMode = !_isSearchMode;
              _isSearchMode ? _animationController.forward() : _animationController.reverse();
            }),
          ),
        ],
        title: _isSearchMode ? _appbarSearchBar() : Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _carBrandandModel(),
            _carCondition(),
            SizedBox(
              height: 5,
            ),
            if (searchQuery.getSearchMode ?? false) ...{
              _carStatusSelector(),
              _carGeneralSpecOne(),
              _carGeneralSpecTwo(),
              FlatButton(
                onPressed: () => searchQuery.setIsAdvancedMode = false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Show less '), Icon(Icons.keyboard_arrow_up)],
                ),
              )
            } else ...{
              FlatButton(
                onPressed: () => searchQuery.setIsAdvancedMode = true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Advanced search',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.lightBlueAccent,
                    )
                  ],
                ),
              )
            },
          ],
        ),
      ),
      bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 70,
          color: Colors.white.withOpacity(0),
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 6, bottom: 6, top: 6),
                  child: Consumer<SearchNotifier>(
                    builder: (context, noti, widget) {
                      if (noti.getBrandRef == 'Brand' &&
                          noti.getCarLayout == 'Select driven wheel' &&
                          noti.getState == 'Select State' &&
                          noti.getBodyType == 'Select body type' &&
                          noti.getCondition == 'All' &&
                          noti.getPrice == 'Any price' &&
                          noti.getMaxPrice == 'Any price' &&
                          noti.getMileage == 'Any Mileage' &&
                          noti.getMaxMileage == 'Any Mileage' &&
                          noti.getModelYear == 'Any year' &&
                          noti.getMaxModelYear == 'Any year') {
                        return RaisedButton(
                          onPressed: null,
                          child: Container(
                            child: Center(
                              child: Text('Reset'),
                            ),
                          ),
                        );
                      } else {
                        return RaisedButton(
                          color: Colors.yellow,
                          onPressed: () => noti.resetAllQuery(),
                          child: Container(
                            child: Center(
                              child: Text(
                                'Reset',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  )),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Center(
                      child: RaisedButton(
                    elevation: 15,
                    color: Colors.blue,
                    disabledElevation: 0,
                    disabledColor: Colors.grey[400],
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          'Search', //SearchButton
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(),
                        )),
                  )),
                ),
              ),
            ],
          )),
    );
  }

  Widget _appbarSearchBar() {
    return TextField(
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Search',
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _carBrandandModel() {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 50),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: notifier.getSearchMode ? 270 : 200,
            child: Card(
              elevation: 1,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Text(
                      notifier.getSearchMode ? 'Select Brand, Model & Variant' : 'Select Brand & Model',
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                            width: 350,
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
                            width: 350,
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
                        if (notifier.getSearchMode) ...{
                          Padding(
                            //VARIANTs CAR SELECTOR
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                              width: 350,
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
                        }
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
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 240,
            child: Card(
              elevation: 1,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Condition',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                    bottom: 90,
                    left: 15,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Select State',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                              padding: EdgeInsets.only(right: 20),
                              child: GestureDetector(
                                onTap: () => setState(() => notifier.setCarCondition = 'All'),
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'All' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        fontSize: 19,
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
                                onTap: () {
                                  setState(() {
                                    notifier.setCarCondition = 'New';
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'New' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'NEW',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getCondition == 'New' ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    notifier.setCarCondition = 'Used';
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(color: notifier.getCondition == 'Used' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'USED',
                                      style: TextStyle(
                                        fontSize: 19,
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
                        padding: EdgeInsets.only(top: 60),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[700], width: 0.5)),
                          width: 350,
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
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 260,
            child: Card(
              elevation: 1,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Text(
                      'Price, Year & Mileage',
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                    padding: EdgeInsets.only(top: 50, left: 15, right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 140,
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
                                    items: notifier.getMaxPrice == 'Any price'? notifier.getDefaultPriceList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList() : notifier.getMaxPriceList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList()
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 140,
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
                                    items: notifier.getPrice == 'Any price'? notifier.getDefaultPriceList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList() : notifier.getMinPriceList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList()
                                  ),
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
                              width: 140,
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
                              width: 140,
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
                              width: 140,
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
                                    items: notifier.getMaxMileage == 'Any Mileage'? notifier.getDefaultMileageList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList() : notifier.getMaxMileageList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList()
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 140,
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
                                    items: notifier.getMileage == 'Any Mileage'? notifier.getDefaultMileageList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList() : notifier.getMinMileageList.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList()
                                  ),
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
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 230,
        child: Card(
            elevation: 1,
            color: Colors.white,
            child: Consumer<SearchNotifier>(
              builder: (context, notifier, widget) {
                return Stack(children: <Widget>[
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Body Type',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                    top: 120,
                    left: 15,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Driven Wheel',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                            width: 350,
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
                            width: 350,
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
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 130,
        child: Card(
          elevation: 1,
          child: Consumer<SearchNotifier>(
            builder: (context, notifier, widget) {        
              return Stack(
                children: <Widget>[
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Transmission',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
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
                                : notifier.getTransmission == 'Automatic'
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
                                  onTap: () => setState(() => notifier.setTransmission = 'All'),
                                  child: Container(
                                    width: 110,
                                    height: 40,
                                    decoration: BoxDecoration(color: notifier.getTransmission == 'All' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        'ALL',
                                        style: TextStyle(
                                          fontSize: 17,
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
                                  onTap: () => setState(() => notifier.setTransmission = 'auto'),
                                  child: Container(
                                    width: 110,
                                    height: 40,
                                    decoration: BoxDecoration(color: notifier.getTransmission == 'auto' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        'AUTOMATIC',
                                        style: TextStyle(
                                          fontSize: 17,
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
                                  onTap: () => setState(() => notifier.setTransmission = 'Manual'),
                                  child: Container(
                                    width: 110,
                                    height: 40,
                                    decoration: BoxDecoration(color: notifier.getTransmission == 'Manual' ? Colors.blue[300] : Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        'MANUAL',
                                        style: TextStyle(
                                          fontSize: 17,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
