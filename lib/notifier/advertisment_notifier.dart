

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AdvertistmentNotifier with ChangeNotifier {

  Advertisment _userNewAd;
  List<Asset> _image = List<Asset>();
  String _adTitle;
  int _progressIndicatorVal;
  CarSpecification _carDoc;
  String _brandName;
  double _top;
  bool _isImageDone;

  initAdvertisment() {
    _image = null;
    _progressIndicatorVal = 1;
    _isImageDone = false;
    _carDoc = null;
  }

  // INITIALLIZE THE MODEL
  set setCarDocRef(CarSpecification ref) {
    _carDoc = ref;
    notifyListeners();
  }

  set setCarBrand(String brand) {
    _brandName = brand;
    notifyListeners();
  }

  set setUserNewAd(Advertisment ads) {
    _userNewAd = ads;
    notifyListeners();
  }
  // -------------------------------------------------------------------
  set setProgressBarIndicator(int x) {
    _progressIndicatorVal = x;
    notifyListeners();
  }

  set setAdTitle(String title) {
    _adTitle = title;
    notifyListeners();
  }

  updateProgressBarIndicator(bool isincrement) {
    if (isincrement) {
      _progressIndicatorVal += 1;
    } else {
      _progressIndicatorVal -= 1;
    }
    notifyListeners();
  }

  // =============== CAR DETAILS PAGE LOGIC ===================================
  set setInitialTopValue(double x) {
    _top = x;
  }

  set setTopValueofHeader(double x) {
    _top = x;
    notifyListeners();
  }

  // =============== MultiImagePicker Value ===================================

  set setImageAsset(List<Asset> image) {
    _image = image;
    // print("[IMAGEDATA] : ${_image.length}");
    notifyListeners();
  }

  set setIsImageDone(bool con) {
    _isImageDone = con;
    notifyListeners();
  }


  double get getTopVal => _top;
  CarSpecification get getCarDoc => _carDoc;
  Advertisment get getUserAdd => _userNewAd;
  int get getProgressBarVal => _progressIndicatorVal;
  String get getBrandName => _brandName;
  String get getAdtitle => _adTitle;
  List<Asset> get getAssetImage => _image;
  bool get getIsImageDone => _isImageDone;
}