import 'dart:io';
import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/advertisment_notifier.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/dealer/CarModelPage.dart';
import 'package:carexpert/pages/dealer/selectImagePage.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class CreateAdsPage2 extends StatefulWidget {
  final String plateNum;
  final String refNum;

  CreateAdsPage2({Key key, this.plateNum, this.refNum}) : super(key: key);

  @override
  _CreateAdsPage2State createState() => _CreateAdsPage2State();
}

class _CreateAdsPage2State extends State<CreateAdsPage2> {
  var _dismissKeyBoard = FocusNode();
  var _dismissDescription = FocusNode();

  String _plateNum;
  String _refNum;
  String _originState;
  String _carDocRef;
  int _mileage;
  int _price;
  String _adTitle;
  String _adDescription;
  String _registrationCardImage;
  String _carCondition;
  File _vhcImage;
  List<Asset> _carImages;
  //List<String> _carImageURLs;  //image url

  final picker = ImagePicker();

  bool _isLocationDone = false;
  bool _isMileageDone = false;
  bool _isPriceDone = false;
  bool _isTitleDone = false;
  bool _isAdsDescriptionDone = false;

  final List<String> _locationList = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Putrajaya',
    'Pulau Pinang',
    'Perak',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Labuan',
    'Kuala Lumpur'
  ];

  @override
  void initState() {
    AdvertistmentNotifier adNotifier = Provider.of<AdvertistmentNotifier>(context, listen: false);
    adNotifier.initAdvertisment();
    // Future.delayed(Duration(milliseconds: 1)).then((_) {
    //   adNotifier.setImageAsset = null;
    //   adNotifier.setCarDocRef = null;
    //   adNotifier.setProgressBarIndicator = 1;
    //   adNotifier.setIsImageDone = false;
    // });

    _plateNum = widget.plateNum;
    _refNum = widget.refNum;
    _originState = '';
    _carDocRef = '';
    _mileage = 0;
    _price = 0;
    _adTitle = '';
    _adDescription = '';
    _registrationCardImage = '';
    _carImages = null;
    _carCondition = 'Used';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AdvertistmentNotifier adNotifier =
        Provider.of<AdvertistmentNotifier>(context, listen: true);

    return WillPopScope(
      onWillPop: (adNotifier.getProgressBarVal ?? 1) < 2
          ? _onExitPress
          : _onCancelPressed,
      child: Scaffold(
        bottomNavigationBar: _bottomAppBar(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: AppBar(
            elevation: 10,
            flexibleSpace: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  child: _progressBarIndicator(),
                )
              ],
            ),
            title: Text(
              'Ad Details',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_dismissKeyBoard),
          child: Container(
            color: Colors.grey[200],
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                _plateNumAndRefShow(),
                _uploadVehiclePicture(),
                _vehicleTypeAndLocation(),
                SizedBox(
                  height: 20,
                ),
                _vehicleStatus(),
                SizedBox(
                  height: 20,
                ),
                _userInformation(),
                SizedBox(
                  height: 20,
                )
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _plateNumAndRefShow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Container(
              width: 75,
              height: 30,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Used',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Vehicle Plate Number',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (_refNum.isNotEmpty) ...[
                  Text(
                    '  /  ',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  Text(
                    'Reference Number',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  )
                ]
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$_plateNum',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                if (_refNum.isNotEmpty) ...[
                  Text(
                    '  /  ',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_refNum',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInformation() {
    return Consumer<DealerDetails>(
      builder: (context, value, widget) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          height: 200,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 10,
                top: 10,
                child: Icon(
                  Icons.person,
                  color: Colors.cyan,
                  size: 30,
                ),
              ),
              Positioned(
                bottom: 15,
                right: 10,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        'Verified User',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Icon(
                      Icons.verified_user,
                      color: Colors.greenAccent,
                      size: 30,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 15,
                right: 10,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              Positioned(
                top: 15,
                left: 60,
                child: Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60, left: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${value.username}',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${value.email}',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '+6${value.phone}',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _vehicleStatus() {
    return Consumer<AdvertistmentNotifier>(
      builder: (context, value, widget) {
        return Container(
          height: 480,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: 120,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 70, right: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Mileage',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 20),
                          ),
                          TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            decoration: InputDecoration(
                              errorText: _mileage > 100
                                  ? null
                                  : 'Mileage must be above 100KM',
                              suffixText: 'Km',
                              hintText: 'Enter the mileage',
                            ),
                            onChanged: (val) {
                              setState(() {
                                int temp = int.parse(val);
                                if (temp > 100) {
                                  _mileage = temp;
                                  if (!_isMileageDone) {
                                    _isMileageDone = !_isMileageDone;
                                    value.updateProgressBarIndicator(true);
                                  }
                                } else {
                                  if (_isMileageDone) {
                                    _mileage = 0;
                                    _isMileageDone = false;
                                    value.updateProgressBarIndicator(false);
                                  }
                                }
                              });
                            },
                            validator: _mileage > 100
                                ? (val) {
                                    _isMileageDone = true;
                                    return '';
                                  }
                                : (val) {
                                    _isMileageDone = false;
                                    return 'Mileage must be above 100KM';
                                  },
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 45,
                      child: Icon(
                        LineIcons.tachometer,
                        color: Colors.cyan,
                        size: 45,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 120,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 70, right: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Price',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 20),
                          ),
                          TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            decoration: InputDecoration(
                                prefixText: 'RM',
                                hintText: 'Enter the price',
                                errorText: _price > 4999
                                    ? null
                                    : 'Price must be above RM5000'),
                            onChanged: (val) {
                              setState(() {
                                int temp = int.parse(val);
                                if (temp > 5000) {
                                  _price = temp;
                                  if (!_isPriceDone) {
                                    _isPriceDone = !_isPriceDone;
                                    value.updateProgressBarIndicator(true);
                                  }
                                } else {
                                  if (_isPriceDone) {
                                    _price = 0;
                                    _isPriceDone = false;
                                    value.updateProgressBarIndicator(false);
                                  }
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 45,
                      child: Icon(
                        LineIcons.money,
                        color: Colors.cyan,
                        size: 45,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 120,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 70, right: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Ad Title',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 20),
                          ),
                          TextFormField(
                            maxLines: 1,
                            //initialValue: value.getAdtitle,
                            maxLength: 150,
                            autofocus: false,
                            decoration: InputDecoration(
                              hintText: 'Enter ad title',
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val.isNotEmpty) {
                                  _adTitle = val;
                                  if (!_isTitleDone) {
                                    _isTitleDone = !_isTitleDone;
                                    value.updateProgressBarIndicator(true);
                                  }
                                } else {
                                  if (_isTitleDone) {
                                    _isTitleDone = false;
                                    value.updateProgressBarIndicator(false);
                                  }
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 45,
                      child: Icon(
                        Icons.title,
                        color: Colors.cyan,
                        size: 45,
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('Ad Description'),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.keyboard),
                              onPressed: () => FocusScope.of(context)
                                  .requestFocus(_dismissDescription),
                            )
                          ],
                        ),
                        body: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 30),
                                child:
                                    Text('Enter the Advertisment Description.'),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 40, right: 40),
                                  child: TextFormField(
                                    initialValue: _adDescription,
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: null,
                                    maxLength: 3000,
                                    decoration: InputDecoration(
                                        hintText: 'Ad Description'),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val.isNotEmpty) {
                                          _adDescription = val;
                                          if (!_isAdsDescriptionDone) {
                                            _isAdsDescriptionDone =
                                                !_isAdsDescriptionDone;
                                            value.updateProgressBarIndicator(
                                                true);
                                          }
                                        } else {
                                          if (_isAdsDescriptionDone) {
                                            _isAdsDescriptionDone = false;
                                            value.updateProgressBarIndicator(
                                                false);
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey[200]),
                          top: BorderSide(color: Colors.grey[200]))),
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 70, right: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (_adDescription.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Ad Description',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  _adDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ] else ...[
                              Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text(
                                  'Ad Description',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 20),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      Positioned(
                        left: 13,
                        bottom: 45,
                        child: Icon(
                          LineIcons.comment,
                          color: Colors.cyan,
                          size: 45,
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 12,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _progressBarIndicator() {
    return Consumer<AdvertistmentNotifier>(
      builder: (context, value, widget) {
        return Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Progress',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 280),
                        child: Text(
                          '${value.getProgressBarVal} of 8',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          decoration: BoxDecoration(
                              color: _returnProgressIndicatorStatus(
                                      1, value.getProgressBarVal)
                                  ? Colors.greenAccent[700]
                                  : Colors.grey,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  topLeft: Radius.circular(5))),
                          height: 9,
                          width: 45,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  2, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  3, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  4, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  5, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  6, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          height: 9,
                          width: 45,
                          color: _returnProgressIndicatorStatus(
                                  7, value.getProgressBarVal)
                              ? Colors.greenAccent[700]
                              : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          decoration: BoxDecoration(
                              color: _returnProgressIndicatorStatus(
                                      8, value.getProgressBarVal)
                                  ? Colors.greenAccent[700]
                                  : Colors.grey,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          height: 9,
                          width: 45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  Widget _bottomAppBar() {
    //publish button
    AdvertistmentNotifier advertistmentNotifier =
        Provider.of<AdvertistmentNotifier>(context, listen: true);
    return Consumer<UserNotifier>(
      builder: (context, notifier, widget) {
        return RaisedButton(
          onPressed: (advertistmentNotifier.getProgressBarVal ?? 1) > 7
              ? () {
                  Advertisment ad = Advertisment(
                      userLike: 0,
                      uid: notifier.userUID,
                      plateNum: _plateNum,
                      refNum: _refNum,
                      registrationImage: _registrationCardImage,
                      year: advertistmentNotifier.getCarDoc.yearRelease,
                      carDocRef: advertistmentNotifier.getCarDoc.docID,
                      location: _originState,
                      adTitle: _adTitle,
                      adDescription: _adDescription,
                      mileage: _mileage,
                      price: _price,
                      carImages: _carImages,
                      condition: _carCondition,
                      dateCreated: Timestamp.now(),
                      brandName: advertistmentNotifier.getBrandName,
                      drivenWheel: advertistmentNotifier.getCarDoc.layout,
                      bodyType: advertistmentNotifier.getCarDoc.bodyType,
                      model: advertistmentNotifier.getCarDoc.model,
                      variant: advertistmentNotifier.getCarDoc.variant 
                      );
                  _onSubmitPressed(
                      ad, notifier, advertistmentNotifier.getAssetImage);
                }
              : null,
          disabledColor: Colors.grey[400],
          disabledTextColor: Colors.white,
          disabledElevation: 0,
          color: Colors.blue,
          elevation: 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            child: Center(
              child: Text(
                'Publish',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _uploadVehiclePicture() {
    //add car photo
    return Consumer<AdvertistmentNotifier>(builder: (context, value, widget) {
      return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SelectCarImagePage(
                      initData: value.getAssetImage,
                    ))),
        onLongPress: () {},
        child: Container(
          height: 170,
          color: Colors.white.withOpacity(0),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
              child: value.getAssetImage == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Upload Image',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            size: 40,
                            color: Colors.green,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Tap to edit selection',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _vehicleTypeAndLocation() {
    return Container(
      color: Colors.white,
      height: 270,
      child: Column(
        children: <Widget>[
          _selectVehicleModel(),
          _getVehicleRegistrationCard(),
          _getSellerLocation()
        ],
      ),
    );
  }

  Widget _getSellerLocation() {
    return Consumer<AdvertistmentNotifier>(
      builder: (context, value, widget) {
        return GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Select Country'),
              ),
              body: Container(
                color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: _locationList.length,
                  itemBuilder: (BuildContext context, int index) {
                    String tempLocation = _locationList[index];
                    return Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _originState = tempLocation;
                            if (!_isLocationDone) {
                              value.updateProgressBarIndicator(true);
                              _isLocationDone = !_isLocationDone;
                            }
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, top: 27),
                            child: Text(
                              '${_locationList[index]}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          })),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                      color: Colors.grey[200],
                    ),
                    bottom: BorderSide(
                      color: Colors.grey[200],
                    ))),
            height: 90,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(
                            Icons.add_location,
                            color: Colors.cyan,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: _originState.isNotEmpty
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.start,
                          mainAxisAlignment: _originState.isNotEmpty
                              ? MainAxisAlignment.spaceEvenly
                              : MainAxisAlignment.center,
                          children: <Widget>[
                            if (_originState.isNotEmpty) ...[
                              Text(
                                'Location',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '$_originState',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              )
                            ] else ...[
                              Text(
                                'Location',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey[700]),
                              )
                            ]
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 15,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 25,
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  Widget _getVehicleRegistrationCard() {
    return Consumer<AdvertistmentNotifier>(builder: (context, value, widget) {
      return GestureDetector(
          onTap: _selectUploadSource,
          onLongPress: () {},
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                      color: Colors.grey[200],
                    ),
                    bottom: BorderSide(
                      color: Colors.grey[200],
                    ))),
            height: 90,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.note_add,
                      color: Colors.cyan,
                    ),
                  ),
                  Text(
                    'Vehicle Registration Card',
                    style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                  ),
                  _vhcImage == null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 59.0),
                          child: Icon(
                            Icons.add,
                            size: 30,
                            color: Colors.black,
                          ),
                        )
                      :
                      // Image.file(_vhcImage, width: 30, height: 50, fit: BoxFit.cover),
                      Padding(
                          padding: const EdgeInsets.only(left: 59.0),
                          child: Icon(
                            Icons.check,
                            size: 30,
                            color: Colors.green,
                          ),
                        ),
                ],
              ),
            ),
          ));
    });
  }

  Widget _selectVehicleModel() {
    return Consumer<AdvertistmentNotifier>(
      builder: (context, value, widget) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(name: '/AdsPage2'),
                    builder: (context) => CarModel()));
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                      color: Colors.grey[200],
                    ),
                    bottom: BorderSide(
                      color: Colors.grey[200],
                    ))),
            height: 90,
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: <Widget>[
                    Row(
                      //mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.cyan,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Column(
                              crossAxisAlignment: _carDocRef.isNotEmpty
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.start,
                              mainAxisAlignment: _carDocRef.isNotEmpty
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                              children: <Widget>[
                                if (value.getCarDoc == null ?? true) ...[
                                  Text(
                                    'Vehicle Details',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey[700]),
                                  )
                                ] else ...[
                                  Text(
                                    'Vehicle Details',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[700]),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${value.getCarDoc.model} ${value.getCarDoc.carDesc}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 10,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 25,
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  bool _returnProgressIndicatorStatus(int val, int progressIndicator) {
    int temp = progressIndicator.compareTo(val) ?? 1.compareTo(val);
    if (temp == 0 || temp == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _onSubmitPressed(Advertisment ad, UserNotifier userData, List<Asset> asset) {
    return showDialog(
        context: context,
        builder: (context) => FutureBuilder<bool>(
              future: DatabaseService().submitDealerAdvertisment(ad, userData, asset),
              builder: (context, snapshot) {
                return AlertDialog(
                  content: Container(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (snapshot.connectionState ==
                            ConnectionState.done) ...{
                          Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 40),
                              child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 22),
                                    children: <TextSpan>[
                                      if (snapshot.data) ...{
                                        TextSpan(
                                            text:
                                                'You have succesfully upload the advertisment !'),
                                      } else ...{
                                        TextSpan(
                                            text:
                                                'An error has occured during the upload-Error:conn.Error'),
                                      }
                                    ]),
                              )),
                          GestureDetector(
                            child: Text(
                              snapshot.data ? 'OK' : 'Try Again',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[300]),
                            ),
                            onTap: snapshot.data
                                ? () {
                                    Navigator.of(context).pop(true);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                : () {
                                    Navigator.of(context).pop(false);
                                  },
                          )
                        } else ...{
                          Center(
                            child: SizedBox(
                              height: 75,
                              width: 75,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        }
                      ],
                    ),
                  ),
                );
              },
            ));
  }

  Future<bool> _onExitPress() {
    return Future.delayed(Duration(milliseconds: 1)).then((value) => true);
  }

  Future<bool> _onCancelPressed() {
    return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Discard this Ad?'),
                  content: Text('All progress made will be discarded.'),
                  elevation: 10,
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'DISCARD',
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )) ??
        false;
  }

  Future getImage(int number) async {
    //for single file

    var pickedFile;

    if (number == 1) {
      pickedFile = await picker.getImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }

    setState(() {
      _vhcImage = File(pickedFile.path);
      Navigator.pop(context);
    });
  }

  Future<bool> _selectUploadSource() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose the source'),
        content: Text('Upload the Vehicle Registration Card'),
        elevation: 10,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () async {
                getImage(1);
              },
              child: Text(
                'Camera',
                style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                getImage(2);
              },
              child: Text(
                'Gallery',
                style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
