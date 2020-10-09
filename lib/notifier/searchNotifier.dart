import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/widgets.dart';

class SearchNotifier with ChangeNotifier {
  bool _isAdvancedMode;
  String _brandRef;
  String _carModel;
  String _carVariant;
  String _carVariantDoc;
  String _condition;
  String _state;
  String _bodyType;
  String _layout;
  String _transmission;
  String _price;
  String _maxPrice;
  String _year;
  String _maxYear;
  String _mileage;
  String _maxMileage;
  Map<String, String> _carVariantMap;
  List<String> _carVariantList;

  List<String> _maxPriceList;
  List<String> _minPriceList;
  List<String> _minMileageList;
  List<String> _maxMileageList;

  final Map<String, int> _priceQuery = {
  'Any price' : 0,'RM 1,000' : 1000,
  'RM 5,000' : 5000,'RM 10,000' : 10000,
  'RM 20,000' : 20000,'RM 30,000' : 30000,
  'RM 40,000' : 40000,'RM 50,000' : 50000,
  'RM 60,000' : 60000,'RM 70,000' : 70000,
  'RM 80,000' : 80000,'RM 90,000' : 90000,
  'RM 100,000' : 100000,'RM 150,000' : 150000,
  'RM 200,000' : 200000,'RM 300,000' : 300000,
  'RM 400,000' : 400000,'RM 500,000' : 500000,
  'RM 600,000' : 600000,'RM 700,000' : 700000,
  'RM 800,000' : 800000,'RM 900,000' : 900000,
  'RM 1,000,000' : 1000000,'RM 1,500,000' : 1500000,
  'RM 2,000,000' : 2000000,
  };

  final Map<String, int> _mileageQuery = {
  'Any Mileage' : 0,'5,000 km' : 5000,
  '10,000 km' : 10000, '15,000 km' : 15000,
  '20,000 km' : 20000, '25,000 km' : 25000,
  '30,000 km' : 30000, '35,000 km' : 35000,
  '40,000 km' : 40000, '45,000 km' : 45000,
  '50,000 km' : 50000, '55,000 km' : 55000,
  '60,000 km' : 60000, '65,000 km' : 65000,
  '70,000 km' : 70000, '75,000 km' : 75000,
  '80,000 km' : 80000, '85,000 km' : 85000,
  '90,000 km' : 90000, '95,000 km' : 95000,
  '100,000 km' : 100000, '110,000 km' : 110000,
  '120,000 km' : 120000, '130,000 km' : 130000,
  '140,000 km' : 140000, '150,000 km' : 150000,
  '160,000 km' : 160000, '170,000 km' : 170000,
  '180,000 km' : 180000, '190,000 km' : 190000,
  '200,000 km' : 200000, '250,000 km' : 250000,
  '300,000 km' : 300000, '350,000 km' : 350000,
  '400,000 km' : 400000, '450,000 km' : 450000,
  '500,000 km' : 500000,
};
  
  bool get getSearchMode => _isAdvancedMode;
  String get getBrandRef => _brandRef;
  String get getCarModel => _carModel;
  String get getCarVariant => _carVariant;
  String get getCarVariantDoc => _carVariantDoc;
  String get getCondition => _condition;
  String get getState => _state;
  String get getBodyType => _bodyType;
  String get getCarLayout => _layout;
  String get getTransmission => _transmission;
  String get getModelYear => _year;
  String get getMaxModelYear => _maxYear;
  String get getPrice => _price;
  String get getMaxPrice => _maxPrice;
  String get getMileage => _mileage;
  String get getMaxMileage => _maxMileage;
  Map<String,String> get getCarVariatMap => _carVariantMap;
  List<String> get getCarVariantList => _carVariantList;
  List<String> get getMaxPriceList => _maxPriceList;
  List<String> get getMinPriceList => _minPriceList;
  List<String> get getDefaultPriceList => _priceQuery.keys.toList();
  List<String> get getMaxMileageList => _maxMileageList;
  List<String> get getMinMileageList => _minMileageList;
  List<String> get getDefaultMileageList => _mileageQuery.keys.toList();
  
  //Speacial Query Data
  set setMinPriceList(String key) {
    List<String> temp = _priceQuery.keys.toList();
    int index = temp.indexWhere((data) => data == key);
    List<String> tempList = ['Any price']; 
    tempList.addAll(temp.sublist(index+1, temp.length -1));
    _minPriceList = tempList;
    notifyListeners();
  }

  set setMaxPriceList(String key) {
    List<String> temp = _priceQuery.keys.toList();
    int index = temp.indexWhere((data) => data == key);
    List<String> tempList = ['Any price']; 
    tempList.addAll(temp.sublist(1, index));
    _maxPriceList = tempList;
    notifyListeners();
  }

  set setMinMileageList(String key) {
    List<String> temp = _mileageQuery.keys.toList();
    int index = temp.indexWhere((element) => element == key);
    List<String> tempList = ['Any Mileage'];
    tempList.addAll(temp.sublist(index+1, temp.length - 1));
    _minMileageList = tempList;
    notifyListeners();
  }

  set setMaxMileageList(String key) {
    List<String> temp = _mileageQuery.keys.toList();
    int index = temp.indexWhere((element) => element == key);
    List<String> tempList = ['Any Mileage'];
    tempList.addAll(temp.sublist(1, index));
    _maxMileageList = tempList;
    notifyListeners();
  }

  resetAllQuery() {
    _isAdvancedMode = false;
    _brandRef = 'Brand';
    _carModel = 'Model';
    _carVariant = 'Variant';
    _carVariantDoc = null;
    _condition = 'All';
    _state = 'Select State';
    _bodyType = 'Select body type';
    _layout = 'Select driven wheel';
    _transmission = 'All';
    _price = 'Any price';
    _maxPrice = 'Any price';
    _year = 'Any year';
    _maxYear = 'Any year';
    _mileage = 'Any Mileage';
    _maxMileage = 'Any Mileage';
    notifyListeners();
  }

  resetAllQueryFilter() {
    _brandRef = 'Brand';
    _carModel = 'Model';
    _carVariant = 'Variant';
    _carVariantDoc = null;
    _condition = 'All';
    _state = 'Select State';
    _bodyType = 'Select body type';
    _layout = 'Select driven wheel';
    _transmission = 'All';
    _price = 'Any price';
    _maxPrice = 'Any price';
    _year = 'Any year';
    _maxYear = 'Any year';
    _mileage = 'Any Mileage';
    _maxMileage = 'Any Mileage';
    notifyListeners();
  }

  initialQuery() {
    _isAdvancedMode = false;
    _brandRef = 'Brand';
    _carModel = 'Model';
    _condition = 'All';
    _state = 'Select State';
    _bodyType = 'Select body type';
    _layout = 'Select driven wheel';
    _transmission = 'All';
    _price = 'Any price';
    _maxPrice = 'Any price';
    _year = 'Any year';
    _maxYear = 'Any year';
    _mileage = 'Any Mileage';
    _maxMileage = 'Any Mileage';
  }

  set setMaxPrice(String price) {
    _maxPrice = price;
    notifyListeners();
  }

  set setMaxMileage(String mileage) {
    _maxMileage = mileage;
    notifyListeners();
  }

  set setMaxYear(String year) {
    _maxYear = year;
    notifyListeners();
  }

  set setIsAdvancedMode(bool isAdvancedMode) {
    _isAdvancedMode = isAdvancedMode;
    notifyListeners();
  }

  set setBrandRef(String brand) {
    _brandRef = brand;
    notifyListeners();
  }

  set setCarModel(String model) {
    _carModel = model;
    if (model != 'Model') {
      print('dasdasdasdad $model');
      _getCarVariantLocal(
        collectionRef[_brandRef],
        _carModel,
      );
    } else {
      _carVariant = 'Variant';
      _carVariantDoc = null;
    }
    notifyListeners();
  }

  set setCarVariant(String variant) {
    _carVariant = variant;
    notifyListeners();
  }

  set setCarVariantDoc(String variant) {
    _carVariantDoc = variant;
    notifyListeners();
  }

  set setCarCondition(String condition) {
    _condition = condition;
    notifyListeners();
  }

  set setState(String state) {
    _state = state;
    notifyListeners();
  }

  set setBodyType(String body) {
    _bodyType = body;
    notifyListeners();
  }

  set setLayout(String layout) {
    _layout = layout;
    notifyListeners();
  }

  set setTransmission(String trans) {
    _transmission = trans;
    notifyListeners();
  }

  set setPrice(String price) {
    _price = price;
    notifyListeners();
  }

  set setYear(String year) {
    _year = year;
    notifyListeners();
  }

  set setMileage(String mileage) {
    _mileage = mileage;
    notifyListeners();
  }

  _getCarVariantLocal(String path, String model) {
    DatabaseService().getCarVariant(path, model).then((value) {
      Map<String, String> temp;
      _carVariant = 'Variant';
      temp = {'Variant': 'Variant'};
      value.forEach((spec) {
        temp.addAll({spec.carDesc: spec.docID});
      });
      _carVariantMap = temp;
      _carVariantList = temp.keys.toList();
      notifyListeners(); 
    });
  }
}
