import 'package:carexpert/model/carspecs.dart';
import 'package:carexpert/notifier/advertisment_notifier.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:carexpert/model/carLogo.dart';
import 'package:provider/provider.dart';

class CarModel extends StatefulWidget {

  @override
  _CarModelState createState() => _CarModelState();
}

class _CarModelState extends State<CarModel> {


  // final List<String> _brandName = [
  //   'Honda', 'Proton', 'Perodua', 'Toyota'
  // ];
  List<String> brandName = brandModel.keys.toList();
  int _selectedBrandIndex;
  String _selectedModel;

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Year'
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(top: 3),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => _brandSelector())
                  );
                },
                child: Container(
                  color: Colors.white,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, top: 27),
                    child: Text(
                      '2019',
                      style: TextStyle(
                        fontSize: 20
                      )
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brandSelector() {
    return Scaffold(
      appBar: AppBar(
        centerTitle:  true,
        title: Text(
          'Select Brand'
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: brandModel.keys.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(top: 3),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedBrandIndex = index);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => _modelSelector(),
                  ));
                },
                child: Container(
                  color: Colors.white,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, top: 27),
                    child: Text(
                      '2019 ${brandName[index]}',
                      style: TextStyle(
                        fontSize: 20
                      )
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _modelSelector() {

    return Scaffold(
      appBar: AppBar(
        centerTitle:  true,
        title: Text(
          'Select Model'
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: brandModel[brandName[_selectedBrandIndex]].length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(top: 3),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedModel = brandModel[brandName[_selectedBrandIndex]][index]);
                  print(_selectedModel);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => _variantSelector(),
                  ));
                },
                child: Container(
                  color: Colors.white,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, top: 27),
                    child: Text(
                      '2019 ${brandModel[brandName[_selectedBrandIndex]][index]}',
                      style: TextStyle(
                        fontSize: 20
                      )
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _variantSelector() {

    AdvertistmentNotifier advertistmentNotifier = Provider.of(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('[INFO] Reset Car Selection');
            Navigator.pop(context);
          },
        ),
        centerTitle:  true,
        title: Text(
          '$_selectedModel'
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: FutureBuilder<List<CarSpecification>>(
          future: DatabaseService()
          .getCarVariant(collectionRef[brandName[_selectedBrandIndex]], _selectedModel),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  print(snapshot.data[index].carDesc);
                  return Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: GestureDetector(
                      onTap: () {
                        if (advertistmentNotifier.getCarDoc == null) {
                          advertistmentNotifier.setCarDocRef = snapshot.data[index];
                          advertistmentNotifier.setCarBrand = brandName[_selectedBrandIndex];
                          advertistmentNotifier.setAdTitle = '${snapshot.data[index].yearRelease} ${brandName[_selectedBrandIndex]} $_selectedModel ${snapshot.data[index].carDesc}';
                          advertistmentNotifier.updateProgressBarIndicator(true);
                        } else {
                          advertistmentNotifier.setCarDocRef = snapshot.data[index];
                        }
                        // Navigator.of(context).popUntil(ModalRoute.withName('/AdsPage2'));
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.white,
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                snapshot.data[index].carDesc,
                                style: TextStyle(
                                  fontSize: 20
                                )
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.graphic_eq, color: Colors.cyan,),
                                  SizedBox(width: 10,),
                                  Text(snapshot.data[index].layout, style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: 30,),
                                  Icon(Icons.control_point, color: Colors.cyan,),
                                  SizedBox(width: 10,),
                                  Text(snapshot.data[index].transmission == null ? 'Automatic' 
                                  : snapshot.data[index].transmission,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
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
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      ),
    );
  }
}