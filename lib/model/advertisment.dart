import 'package:carexpert/model/carspecs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisment {

  String uid;
  String condition;
  String plateNum;
  String refNum;
  String brandName;
  String registrationImage;
  String year;
  String docID;
  String carDocRef;
  String location;
  String adTitle;
  String adDescription;
  int userLike;
  int mileage;
  int price;
  CarSpecification carSpec;
  Timestamp dateCreated;
  Timestamp dateUpdated;
  List<dynamic> carImages = [];
  List<dynamic> likedUser;

  String variant;
  String model;
  String bodyType;
  String drivenWheel;
  String transmission;

  Advertisment({
    this.plateNum, this.uid, this.refNum, this.registrationImage, this.year, this.brandName,
    this.adTitle, this.carDocRef, this.location, this.adDescription, this.mileage,
    this.price, this.carImages, this.dateCreated, this.condition, this.dateUpdated,this.userLike,
    this.variant, this.model, this.bodyType, this.drivenWheel, this.transmission
  });

  set setCarSpec(CarSpecification spec) {
    carSpec = spec;
  }

  set setCarImageURL(List data) {
    carImages = data;
  }

  Map<String, dynamic> toMap() {
    return {
      'UID' : uid,
      'like' : userLike,
      'PlateNum' : plateNum,
      'Condition' : condition,
      'RefNum' : refNum,
      'Brand' : brandName,
      'RegistrationCard' : registrationImage.isNotEmpty? registrationImage : null,
      'year' : year,
      'CarRef' : carDocRef,
      'Location' : location,
      'AdsTitle' : adTitle,
      'AdsDesc' : adDescription,
      'Mileage' : mileage,
      'Price' : price,
      'CarImage' : carImages,   //car images
      'CreatedAt' : dateCreated,
      'UpdatedAt' : dateUpdated ?? null,
      'likedUser' : likedUser,
      'model' : model,
      'variant' : variant,
      'bodyType' : bodyType,
      'layout' : drivenWheel,
      'transmission' : 'auto'
    };
  }

  Advertisment.fromMap(Map<String, dynamic> data, String documentID) {
    uid = data['UID'];
    brandName = data['Brand'];
    plateNum = data['PlateNum'];
    refNum = data['RefNum'];
    registrationImage = data['RegistrationCard'];
    year = data['year'];
    carDocRef = data['CarRef'];
    location = data['Location'];
    adTitle = data['AdsTitle'];
    adDescription = data['AdsDesc'];
    mileage = data['Mileage'];
    price = data['Price'];
    carImages = data['CarImage'];   //car images
    dateCreated = data['CreatedAt'];
    dateUpdated = data['UpdatedAt'];
    condition = data['Condition'];
    userLike = data['like'];
    likedUser = data['likedUser'];
    model = data['model'];
    variant = data['variant'];
    bodyType = data['bodyType'];
    drivenWheel = data['layout'];
    transmission = data['transmission'];
    docID = documentID;
  }

}