import 'dart:ui';
import 'package:carexpert/pages/dealer/createAdsPage2.dart';
import 'package:flutter/material.dart';

class CreateAdsPage1 extends StatefulWidget {
  @override
  _CreateAdsPage1State createState() => _CreateAdsPage1State();
}

class _CreateAdsPage1State extends State<CreateAdsPage1> {
  final _textEditor = TextEditingController();
  var _blankFocusNode = FocusNode();
  var _dismissKeyboard = FocusNode();
  final _nextTextField = FocusNode();

  bool _isValid;
  bool _isEmpty;
  String _plateNumber;
  String _refNumber;

  @override
  void initState() {
    _isEmpty = true;
    _isValid = true;
    _plateNumber = null;
    _refNumber = '';
    super.initState();
  }

  @override
  void dispose() {
    _textEditor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Ad',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: RaisedButton(
        disabledElevation: 0,
        disabledColor: Colors.grey,
        color: Colors.blue,
        textColor: Colors.white,
        elevation: 8,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: Center(
                child: Text(
              'Next',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ))),
        onPressed: _isEmpty
            ? null
            : () {
                FocusScope.of(context)
                    .requestFocus(_dismissKeyboard);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateAdsPage2(
                              plateNum: _plateNumber,
                              refNum: _refNumber,
                            )));
              }),
      body: GestureDetector(
        //behavior: ,
        onTap: () => FocusScope.of(context).requestFocus(_blankFocusNode),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Text(
                    'Let\'s upload a vehicle',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(text: 'A vehicle plate number or a reference'),
                          TextSpan(
                              text: '\n number will help you find ads easily')
                        ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 80, right: 50),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(text: 'Vehicle plate number '),
                          TextSpan(text: '*', style: TextStyle(color: Colors.red))
                        ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  child: TextFormField(
                    controller: _textEditor,
                    maxLines: 1,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    maxLength: 30,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Enter the vehicle\'s plate number',
                      hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      icon: Icon(
                        Icons.drive_eta,
                        color: Colors.cyan,
                      ),
                      errorText:
                          !_isValid ? 'Plate number cant\'t be empty!' : null,
                    ),
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).requestFocus(_nextTextField);
                    },
                    onChanged: (val) {
                      setState(() {
                        if (val.isEmpty) {
                          _isEmpty = true;
                          _isValid = false;
                        } else {
                          _isEmpty = false;
                          _isValid = true;
                        }
                        _plateNumber = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, right: 75),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(text: 'Reference number '),
                        ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  child: TextFormField(
                    maxLines: 1,
                    focusNode: _nextTextField,
                    maxLength: 15,
                    keyboardType: TextInputType.number,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      hintText: 'Any Number to identify the vehicle',
                      icon: Icon(
                        Icons.insert_drive_file,
                        color: Colors.cyan,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _refNumber = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
