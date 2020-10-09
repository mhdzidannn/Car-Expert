class CarSpecification {

  String model;
  String carDesc;
  String docID;
  String variant;
  String bodyType;
  String engineDescription;
  String layout;
  String yearRelease;
  String transmission;

  Map<String,dynamic> carEngine;
  Map<String,dynamic> carDimension;
  Map<String, dynamic> generalSpec; 
  List<String> carEngineKey;
  List<String> carDimensionKey;
  List<String> generalSpecKey;

  CarSpecification();

  CarSpecification.fromMap(Map <String, dynamic> data) {
    model = data['Model'];
    carDesc = data['CarDescription'];
    variant = data['Variant'];
    bodyType = data['BodyType'];
    layout = data['Layout'];
    yearRelease = data['Year'];
    engineDescription = data['EngineDesc'];
    generalSpec = data['General'];            //map
    carDimension = data['Dimensions'];        //map
    carEngine = data['Engine'];               //map
    transmission = data['Transmission'] ?? null;
    
    carEngineKey = carEngine.keys.toList();
    carDimensionKey = carDimension.keys.toList();
    generalSpecKey = generalSpec.keys.toList();
  } 
}