import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


final List colorListPicker = [
  Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.pink,
  Colors.purple, Colors.teal, Colors.orange, Colors.amber, Colors.brown
];

//REGEX OPERATORS
final RegExp regPrice = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
final Function mathFuncPrice = (Match match) => '${match[1]},';

//CAR LOCAL DATABASE REFERENCE

final Map<String, String> bodyTypeRefMap = {
  'Select body type' : 'Select body type',
  'Hatchback' : 'Hatchback',
  'Sedan' : 'Sedan',
  'SUV' : 'SUV',
  'Mini Van' : 'Mini Van',
  'MPV' : 'MPV',
  'Coupe' : 'Coupe',
};

final Map<String, String> layoutRefMap = {
  'Select driven wheel' : 'Select driven wheel',
  '2WD' : '2WD',
  '4WD' : '4WD',
  'AWD' : 'AWD',
  'FWD' : 'FWD',
  'RWD' : 'RWD',
};

final Map<String, List<String>> brandModel = {
'Honda' : [
  'Accord', 'BR-V', 'City', 'Civic', 'CR-V', 'HR-V', 'Jazz', 'Odyssey'
],
'Perodua' : [
  'Alza', 'Bezza', 'Myvi'
],
'Proton' : [
  'Ertiga', 'Exora', 'Iriz', 'Perdana', 'Persona', 'Saga', 'X70'
],
'Toyota' : [
  'Alphard', 'Vellfire', 'Avanza', 'C-HR', 'Camry', 'Fortuner', 'Harrier', 'Hilux',
  'Innova', 'Rush', 'Supra', 'Vios', 'Yaris' 
]
};

final Map<String, List<String>> brandModelVer2 = {
'Brand' : [],
'Honda' : [
  'Model','Accord', 'BR-V', 'City', 'Civic', 'CR-V', 'HR-V', 'Jazz', 'Odyssey'
],
'Perodua' : [
  'Model','Alza', 'Bezza', 'Myvi'
],
'Proton' : [
  'Model','Ertiga', 'Exora', 'Iriz', 'Perdana', 'Persona', 'Saga', 'X70'
],
'Toyota' : [
  'Model','Alphard', 'Vellfire', 'Avanza', 'C-HR', 'Camry', 'Fortuner', 'Harrier', 'Hilux',
  'Innova', 'Rush', 'Supra', 'Vios', 'Yaris' 
]
};

final Map<String,String> collectionRef = {
  'Honda' : 'Honda_spec',
  'Proton' : 'Proton_spec',
  'Perodua' : 'Perodua_spec',
  'Toyota' : 'Toyota_spec'
};

final Map<String, int> priceQuery = {
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

final List<String> yearQuery = ['Any year','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

final Map<String, int> mileageQuery = {
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

class CarLogoModel {
  final String brandName;
  final String imagePath;

  CarLogoModel({@required this.brandName, @required this.imagePath});
}

List<CarLogoModel> brandLogo = [
  CarLogoModel(brandName: "Proton", imagePath: null),
  CarLogoModel(brandName: "Perodua", imagePath: null),
  CarLogoModel(brandName: "Honda", imagePath: null),
  CarLogoModel(brandName: "Toyota", imagePath: null),
];