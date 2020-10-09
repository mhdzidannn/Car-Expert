import 'dart:io';

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/searchNotifier.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:random_string/random_string.dart';

class DatabaseService {
  DocumentReference dealerRef = Firestore.instance.collection("UserData").document("Dealer");
  DocumentReference userRef = Firestore.instance.collection("UserData").document("User");

// ======================================================================================================================================
// ========================================= DEALER BASED EVENTS ========================================================================
// ======================================================================================================================================

  Stream<List<Advertisment>> getDealerAdvertisment(String uid) {
    return dealerRef
        .collection("AdvertDoc")
        .where('UID', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.documents.map((DocumentSnapshot data) => Advertisment.fromMap(data.data, data.documentID)).toList());
  }

  deleteNotification(Map data, String uid) async {
    await dealerRef.collection("DealerProfile").document(uid).updateData({
      'likeNotification' : FieldValue.arrayRemove([{
        'time' : data['time'],
        'userName' : data['userName'],
        'adTitle' : data['adTitle']
      }])
    }).then((value) => print("[DealerDetails] Updated Notification"));
  }




  deleteDealerAdvertisment(Advertisment doc, UserNotifier dealer, List<dynamic> urls) async {
    WriteBatch batchWrite = Firestore.instance.batch();
    try {
      await Future.wait(urls.map((url) async {
        await FirebaseStorage.instance.getReferenceFromUrl(url).then((value) async {
          await value.delete().then((_) => print("[FirebaseStorage] Image Deletion Succesful"));
        });
      })).then((_) async {
        doc.likedUser.forEach((element) {
          batchWrite.updateData(userRef.collection("UserProfile").document(element.toString()), {
            'deletedCars': FieldValue.arrayUnion([
              {'docID': doc.docID, 'adTitle': doc.adTitle, 'deletedAt': Timestamp.now()}
            ])
          });
        });
        batchWrite.delete(dealerRef.collection('AdvertDoc').document(doc.docID));
   
        await batchWrite.commit().then((_) async {
          await Firestore.instance.runTransaction((transaction) async {
            UserGeneralInfo currentInfo = await transaction.get(dealerRef).then((value) => UserGeneralInfo.fromMapDealer(value.data));
            DealerDetails currentDealer = await transaction.get(dealerRef.collection("DealerProfile").document(dealer.userUID)).then((value) => DealerDetails.fromMap(value.data));
            await transaction.update(dealerRef, {
              "Adcount": currentInfo.adCount - 1,
              "CarDocument": FieldValue.arrayRemove([doc.docID])
            });
            await transaction.update(dealerRef.collection("DealerProfile").document(dealer.userUID), {
              'adCount': currentDealer.adCount - 1,
              'refDocument': FieldValue.arrayRemove([doc.docID])
            });
            if (doc.likedUser != null) {
              doc.likedUser.map((id) async {
                await transaction.update(userRef.collection("UserProfile").document(id), {
                  'deletedCars': FieldValue.arrayUnion([doc.docID])
                });
              });
            }
          }).then((_) {
            print("[Advertisment] Successfully update Info and Profile (DELETE MODE)");
            dealer.updateUserAdvertismentList(doc.docID);
          });
        });
      });
    } catch (e) {
      print("[Advertisment] Error during deleting your Advertisment : ${e.toString()}");
    }
  }

  Future<bool> submitDealerAdvertisment(Advertisment adData, UserNotifier dealer, List<Asset> asset) async {
    DocumentReference dealerDocRef = dealerRef.collection("DealerProfile").document(dealer.userUID);

    try {
      return Future.wait([uploadCarImage(asset, dealer.userUID)]).then((value) async {
        adData.setCarImageURL = value[0];
        return dealerRef.collection("AdvertDoc").add(adData.toMap()).then((doc) {
          print("[Advertisment] Succesfully upload advertisment document");
          return Firestore.instance.runTransaction((transaction) async {
            DealerDetails currentDealer = await transaction.get(dealerDocRef).then((value) => DealerDetails.fromMap(value.data));
            UserGeneralInfo currentInfo = await transaction.get(dealerRef).then((value) => UserGeneralInfo.fromMapDealer(value.data));
            await transaction.update(dealerDocRef, {
              'adCount': currentDealer.adCount + 1,
              'refDocument': FieldValue.arrayUnion([doc.documentID])
            });
            await transaction.update(dealerRef, {
              'Adcount': currentInfo.adCount + 1,
              'CarDocument': FieldValue.arrayUnion([doc.documentID])
            });
          }).then((_) {
            print("[Advertisment] Updated General and Profile");
            return AuthService().getDealerProfileLocal(dealer.userUID).then((newData) {
              dealer.notifyCurrentDealer = newData;
              return true;
            });
          });
        });
      });
    } catch (e) {
      print("[Advertisment] Error in adding Ads : ${e.toString()}");
      return false;
    }
  }

// ======================================================================================================================================
// ======================================================================================================================================
// ======================================================================================================================================

// ======================================================================================================================================
// ========================================= Generic Database Fetch =====================================================================
// ======================================================================================================================================

  Future<bool> updateProfilePic(UserNotifier notifier, bool isUpdate, File image) async {
    //setProfilePic
    //getProfilePic
    try {
      if (notifier.dealerMode) {
        return await FirebaseStorage.instance.ref().child('/${notifier.userUID}/${randomAlphaNumeric(15)}')
        .putFile(image).onComplete.then((url) async {
          if (url.error == null) {
            await url.ref.getData(2048).then((byte) {
               notifier.setProfilePic = File.fromRawPath(byte);
            });
            return await url.ref.getDownloadURL().then((imageURL) async {
              if (isUpdate) {
                await FirebaseStorage.instance.getReferenceFromUrl(notifier.getDealerDetails.profilePic)
                .then((value) async => await value.delete().then((value)
                => print('[FirebaseStorage] Deleted old Profile Pic')));
              }
              notifier.getDealerDetails.profilePic = imageURL;
              return await dealerRef.collection("DealerProfile").document(notifier.userUID)
              .updateData({
                'profilePic' : imageURL,
              }).then((_) {
                return true;
              });
            });
          } else {
            print("[FirebaseStorage] Error during upload : ${url.error.toString()}");
            return false;
          }
        });
      } else {
        return await FirebaseStorage.instance.ref().child('/${notifier.userUID}/${randomAlphaNumeric(15)}')
        .putFile(image).onComplete.then((url) async {
          if (url.error == null) {
            await url.ref.getData(2048).then((byte) {
               notifier.setProfilePic = File.fromRawPath(byte);
            });
            return await url.ref.getDownloadURL().then((imageURL) async {
              if (isUpdate) {
                await FirebaseStorage.instance.getReferenceFromUrl(notifier.getUserDetails.profilePic)
                .then((value) async => await value.delete().then((value)
                => print('[FirebaseStorage] Deleted old Profile Pic')));
              }
              notifier.getUserDetails.profilePic = imageURL;
              return await dealerRef.collection("UserProfile").document(notifier.userUID)
              .updateData({
                'profilePic' : imageURL,
              }).then((_) {
                return true;
              });
            });
          } else {
            print("[FirebaseStorage] Error during upload : ${url.error.toString()}");
            return false;
          }
        });
      }
    } catch (e) {
      print('[UserNotifier] Error in updating profile Pic');
      return false;
    }
  }

  // Future<void> updateProfilePic(UserNotifier notifier, bool isUpdate, File image) async {
  //   StorageReference storageReference;

  //   try {
  //     if (notifier.dealerMode) {
  //       storageReference = FirebaseStorage.instance.ref().child('/${notifier.userUID}/${randomAlphaNumeric(15)}');

  //       final StorageUploadTask uploadTask = storageReference.putFile(image);

  //       final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

  //       final String url = (await downloadUrl.ref.getDownloadURL());

  //       print("URL is $url");

  //       await dealerRef.collection("DealerProfile").document(notifier.userUID).updateData({
  //         'profilePic': url,
  //       });

  //       notifier.getDealerDetails.profilePic = url;
  //     } else {
  //       storageReference = FirebaseStorage.instance.ref().child('/${notifier.userUID}/${randomAlphaNumeric(15)}');

  //       final StorageUploadTask uploadTask = storageReference.putFile(image);

  //       final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

  //       final String url = (await downloadUrl.ref.getDownloadURL());

  //       print("URL is $url");

  //       await dealerRef.collection("UserProfile").document(notifier.userUID).updateData({
  //         'profilePic': url,
  //       });

  //       notifier.getUserDetails.profilePic = url;
  //     }
  //   } catch (e) {
  //     print('Error Handling $e');
  //   }
  // }

  Future<String> uploadSingleImage(File image, String uid) async {
    String fileName = randomAlphaNumeric(15);
    return await FirebaseStorage.instance.ref().child('/$uid/$fileName').putFile(image).onComplete.then((snapshot) async {
      if (snapshot.error == null) {
        return await snapshot.ref.getDownloadURL().then((value) => value.toString());
      } else {
        print("[FirebaseStorage] Error during upload : ${snapshot.error.toString()}");
        return null;
      }
    });
  }

  Future<List<String>> uploadCarImage(List<Asset> asset, String uid) async {
    List<String> uploadUrl = [];
    await Future.wait(
        asset.map((Asset image) async {
          String fileName = randomAlphaNumeric(15);
          ByteData byteData = await image.getByteData(quality: 100);
          List<int> imageData = byteData.buffer.asUint8List();
          StorageTaskSnapshot snapshot = await FirebaseStorage.instance.ref().child('/$uid/$fileName').putData(imageData).onComplete;
          if (snapshot.error == null) {
            String downloadUrl = await snapshot.ref.getDownloadURL();
            uploadUrl.add(downloadUrl);
            print('[FirebaseStorage] Success Upload');
          } else {
            print('[FirebaseStorage] Error during upload : ${snapshot.error.toString()}');
            throw ('This file is not an image');
          }
        }),
        eagerError: true,
        cleanUp: (_) {
          print('[FirebaseStorage] CleanUp Error');
        });
    print("UDAH ANTAR");
    return uploadUrl;
  }

  Future<List<CarSpecification>> getCarVariant(String path, String model) async {
    List<CarSpecification> _carList = [];
    return Firestore.instance.collection(path).where('Model', isEqualTo: model).getDocuments().then((query) {
      query.documents.forEach((doc) {
        CarSpecification car = CarSpecification.fromMap(doc.data);
        car.docID = doc.documentID;
        _carList.add(car);
      });
      return _carList;
    });
  }

  //BASIC DATA GRAB
  Future<CarSpecification> getCarSpecificationAdvertisment(Advertisment carAd) async {
    return await Firestore.instance.collection(collectionRef[carAd.brandName]).document(carAd.carDocRef).get().then((value) => CarSpecification.fromMap(value.data));
  }

// ======================================================================================================================================
// ======================================================================================================================================
// ======================================================================================================================================

// ======================================================================================================================================
// ========================================  USER FUNCTIONS ===========================================================================
// ======================================================================================================================================

  //Favourite Page
  Stream<List<Advertisment>> getUserFavouriteAdvertismentStream(String uid) {
    return dealerRef
        .collection("AdvertDoc")
        .where("likedUser", arrayContains: uid)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.documents.map((DocumentSnapshot data) => Advertisment.fromMap(data.data, data.documentID)).toList());
  }

  //Explore Page Top 10 deals
  Future<List<Advertisment>> getTopTenDealForExplorePage() async {
    return await dealerRef
        .collection("AdvertDoc")
        .orderBy('Price', descending: false)
        .limit(10)
        .getDocuments()
        .then((QuerySnapshot snapshot) => snapshot.documents.map((DocumentSnapshot data) => Advertisment.fromMap(data.data, data.documentID)).toList());
  }

//dealerRef
  Future<List<DealerDetails>> getListPopularDealer() async {
    return await dealerRef
        .collection("DealerProfile")
        .where('adCount', isGreaterThan: 0)
        .orderBy('adCount', descending: true)
        .limit(5)
        .getDocuments()
        .then((value) => value.documents.map((e) => DealerDetails.fromMapUser(e.data, e.documentID)).toList());
  }

  //dealerListing
  Future<List<Advertisment>> getDealerListing(String uid) async {
    return await dealerRef
        .collection("AdvertDoc")
        .where('UID', isEqualTo: uid)
        .getDocuments()
        .then((value) => value.documents.map((DocumentSnapshot data) => Advertisment.fromMap(data.data, data.documentID)).toList());
  }

  //deleted DeletedCars
  deleteDeletedCars(Map<String, dynamic> data, UserNotifier notifier) async {
    try {
      await userRef.collection("UserProfile").document(notifier.userUID).updateData({
        'likeCars': FieldValue.arrayRemove([data['docID']]),
        'deletedCars': FieldValue.arrayRemove([
          {
            'deletedAt': data['deletedAt'],
            'adTitle': data['adTitle'],
            'docID': data['docID'],
          }
        ])
      });
    } catch (e) {
      print("[Advertisment] Error in deleting the history");
    }
  }

  //updatelike
  updateLikeCountAndStatus(Advertisment data, UserNotifier notifier, bool islike) async {
    try {
      if (islike) {
        await userRef.collection("UserProfile").document(notifier.userUID).updateData({
          "likeCars": FieldValue.arrayUnion([data.docID])
        }).then((_) async {
          print("[UserNotifier] Updated UserData on Firestore");
          await Firestore.instance.runTransaction((transaction) async {
            Advertisment currentAd = await transaction.get(dealerRef.collection("AdvertDoc").document(data.docID)).then((value) => Advertisment.fromMap(value.data, value.documentID));
            DealerDetails currentDealer = await transaction.get(dealerRef.collection("DealerProfile").document(data.uid)).then((value) => DealerDetails.fromMap(value.data));
            await transaction.update(dealerRef.collection("DealerProfile").document(data.uid), {
              'likeNotification' : FieldValue.arrayUnion([{
                'adTitle' : data.adTitle,
                'userName' : notifier.getUserDetails.username,
                'time' : Timestamp.now()
              }])
            });
            await transaction.update(dealerRef.collection("AdvertDoc").document(data.docID), {
              'likedUser': FieldValue.arrayUnion([notifier.userUID]),
              'like': currentAd.userLike + 1
            });
          }).then((_) => print("[Advertisment] Updated Advertisment on Firestore"));
        });
      } else {
        await userRef.collection("UserProfile").document(notifier.userUID).updateData({
          "likeCars": FieldValue.arrayRemove([data.docID]),
        }).then((_) async {
          print("[UserNotifier] Updated UserData on Firestore");
          await Firestore.instance.runTransaction((transaction) async {
            Advertisment currentAd = await transaction.get(dealerRef.collection("AdvertDoc").document(data.docID)).then((value) => Advertisment.fromMap(value.data, value.documentID));
            await transaction.update(dealerRef.collection("AdvertDoc").document(data.docID), {
              'likedUser': FieldValue.arrayRemove([notifier.userUID]),
              'like': currentAd.userLike - 1
            });
          }).then((_) => print("[Advertisment] Updated Advertisment on Firestore"));
        });
      }
    } catch (e) {
      print("[Advertisment] Failed in updating like number");
    }
  }

  // GET DEALER DETAILS IN QUERY SEARCH
  // Future<UserDetails> getDealerDetails(String uid) async {
  //   return await Firestore.instance
  //       .collection('user')
  //       .document(uid)
  //       .get()
  //       .then((value) {
  //     UserDetails dealer = UserDetails.fromMapDealer(value.data);
  //     dealer.setDealerUID = value.documentID;
  //     return dealer;
  //   });
  // }

// ======================================================================================================================================
// ======================================================================================================================================
// ======================================================================================================================================

// ======================================================================================================================================
// ======================================== QUERY SYSTEM ================================================================================
// ======================================================================================================================================

  Future<List<Advertisment>> getSearchResult(SearchNotifier notifier) async {
    
    CollectionReference searchQuery = dealerRef.collection("AdvertDoc");

    if (notifier.getBrandRef == 'Brand' &&
        notifier.getCarLayout == 'Select driven wheel' &&
        notifier.getState == 'Select State' &&
        notifier.getBodyType == 'Select body type' &&
        notifier.getCondition == 'All' &&
        notifier.getPrice == 'Any price' &&
        notifier.getMaxPrice == 'Any price' &&
        notifier.getMileage == 'Any Mileage' &&
        notifier.getMaxMileage == 'Any Mileage' &&
        notifier.getModelYear == 'Any year' &&
        notifier.getMaxModelYear == 'Any year' &&
        notifier.getTransmission == 'All') {
      print('[SEARCH QUERY] Initial Query');
      return await searchQuery.getDocuments().then((snapshot) => snapshot.documents.map((data) => Advertisment.fromMap(data.data, data.documentID)).toList());
    } else {
      Query filterSearch = searchQuery;
      print("UDAH MASODOASD");
      // Brand, Model, Variant ================================================================================

      if (notifier.getBrandRef != 'Brand') {
        filterSearch = filterSearch.where('Brand', isEqualTo: notifier.getBrandRef);
      }
      if (notifier.getCarModel != 'Model') {
        filterSearch = filterSearch.where('model', isEqualTo: notifier.getCarModel);
      }
      if (notifier.getCarVariantDoc != null) {
        filterSearch = filterSearch.where('CarRef', isEqualTo: notifier.getCarVariantDoc);
      }
      // Condition, Select State ================================================================================

      if (notifier.getCondition != 'All') {
        filterSearch = filterSearch.where("Condition", isEqualTo: notifier.getCondition);
      }
      if (notifier.getState != "Select State") {
        filterSearch = filterSearch.where("Location", isEqualTo: notifier.getState);
      }
      // Price, Year, Mileage ================================================================================

      // Price
      if (notifier.getPrice != "Any price" && notifier.getMaxPrice == 'Any price') {
        filterSearch = filterSearch.where("Price", isGreaterThanOrEqualTo: priceQuery[notifier.getPrice]);
      }
      if (notifier.getMaxPrice != "Any price" && notifier.getPrice == 'Any price') {
        filterSearch = filterSearch.where("Price", isLessThanOrEqualTo: priceQuery[notifier.getMaxPrice]);
      }
      if (notifier.getPrice != "Any price" && notifier.getMaxPrice != "Any price") {
        filterSearch = filterSearch.where("Price", isLessThanOrEqualTo: priceQuery[notifier.getMaxPrice], isGreaterThanOrEqualTo: priceQuery[notifier.getPrice]);
      }

      // //Year
      if (notifier.getModelYear != 'Any year') {
        filterSearch = filterSearch.where("year", isEqualTo: notifier.getModelYear);
      }
      if (notifier.getMaxModelYear != 'Any year' || notifier.getMaxModelYear == '2020') {
        filterSearch = filterSearch.where("year", isEqualTo: notifier.getMaxModelYear);
      }

      // // //Mileage
      if (notifier.getMileage != "Any Mileage" && notifier.getMaxMileage == 'Any Mileage') {
        filterSearch = filterSearch.where("Mileage", isGreaterThanOrEqualTo: priceQuery[notifier.getMileage]);
      }
      if (notifier.getMaxMileage != "Any Mileage" && notifier.getMileage == 'Any Mileage') {
        filterSearch = filterSearch.where("Mileage", isLessThanOrEqualTo: priceQuery[notifier.getMaxMileage]);
      }

      if (notifier.getMaxMileage != 'Any Mileage' && notifier.getMileage != 'Any Mileage') {
        filterSearch = filterSearch.where('Mileage', isLessThanOrEqualTo: mileageQuery[notifier.getMaxMileage], isGreaterThanOrEqualTo: mileageQuery[notifier.getMileage]);
      }

      // Body Type, Driven Wheel, Transmission ================================================================================

      if (notifier.getBodyType != "Select body type") {
        filterSearch = filterSearch.where("bodyType", isEqualTo: notifier.getBodyType);
      }
      if (notifier.getCarLayout != "Select driven wheel") {
        filterSearch = filterSearch.where("layout", isEqualTo: notifier.getCarLayout);
      }
      if (notifier.getTransmission != 'All') {
        filterSearch = filterSearch.where("transmission", isEqualTo: notifier.getTransmission);
      }
      print("Brand: ${notifier.getBrandRef}\nModel: ${notifier.getCarModel}\nVariant: ${notifier.getCarVariant}\nCondition: ${notifier.getCondition}\nState: ${notifier.getState}");
      print("MaxPrice: ${notifier.getMaxPrice}\nMinPrice: ${notifier.getPrice}\nMaxYear: ${notifier.getMaxModelYear}\nMinYear: ${notifier.getModelYear}\nMaxMileage: ${notifier.getMaxMileage}");
      print("MinMileage: ${notifier.getMileage}\nBodyType: ${notifier.getBodyType}\nLayout: ${notifier.getCarLayout}\nTransmission: ${notifier.getTransmission}");
      return await filterSearch.getDocuments().then((snapshot) => snapshot.documents.map((data) {
            print('[SEARCH QUERY] Get data completed');
            return Advertisment.fromMap(data.data, data.documentID);
          }).toList());
    }
  }

// ======================================================================================================================================
// ======================================================================================================================================
// ======================================================================================================================================

}
