import 'dart:io';

import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';

class SignUpPage extends StatefulWidget {
  final String email;
  final String password;
  final bool isDealer;

  const SignUpPage({Key key, this.email, this.password, this.isDealer})
      : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final _formKey = new GlobalKey<FormState>();
  final imagePicker = ImagePicker();

  String email;
  String password;
  bool isDealer;

  @override
  void initState() {
    email = widget.email;
    password = widget.password;
    isDealer = widget.isDealer;
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  String _selectedState = 'Select State';
  String _userName = '';
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _address = '';
  File _image;
  bool _acceptTnC = false;
  bool _acceptNewsletter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  userNameField(),
                  if (!isDealer) ...{
                    firstNameField(),
                    lastNameField(),
                  },
                  phoneNumberField(),
                  if (isDealer) ...{addressField()},
                  stateSelection(),
                  if (isDealer) ...{certificateOfBusiness()},
                  disclaimerAndTnC(),
                  if (!isDealer) ...{
                    newsletterCheckbox(),
                  },
                  buttonAcceptDeny(),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

//USERNAME DATA
  Widget userNameField() {
    return Padding(
        padding: EdgeInsets.only(top: 70, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Username',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'eg. CarThief69'),
              maxLines: 1,
              onSaved: (value) => _userName = value.trim(),
              validator: (value) =>
                  _userName.isEmpty ? 'Enter your username' : null,
              onChanged: (value) => setState(() => _userName = value),
            )
          ],
        ));
  }

//USER FULL NAME DATA
  Widget firstNameField() {
    return Padding(
        padding: EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'First Name',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'eg. John'),
              maxLines: 1,
              onSaved: (value) => _firstName = value,
              validator: (value) =>
                  _firstName.isEmpty ? 'Enter your first name' : null,
              onChanged: (value) => setState(() => _firstName = value),
            )
          ],
        ));
  }

  Widget lastNameField() {
    return Padding(
        padding: EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Last Name',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'eg. Doe'),
              maxLines: 1,
              onSaved: (value) => _lastName = value,
              validator: (value) =>
                  _lastName.isEmpty ? 'Enter your last name' : null,
              onChanged: (value) => setState(() => _lastName = value),
            )
          ],
        ));
  }

//USER FULL NAME DATA
  Widget phoneNumberField() {
    return Padding(
        padding: EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Phone Number',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'eg. 0123456789'),
              maxLines: 1,
              validator: (value) {
                Pattern pattern = r'^(\+?6?01)[0-46-9]-*[0-9]{7,8}$';
                RegExp regex = new RegExp(pattern);
                if (!regex.hasMatch(value))
                  return 'Enter a valid Malaysian phone number';
                else
                  return null;
              },
              onChanged: (value) {
                // get value everytime user change input
                setState(() => _phoneNumber = value);
              },
            )
          ],
        ));
  }

//for dealers, give address of the dealer
  Widget addressField() {
    return Padding(
        padding: EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Address',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              decoration:
                  InputDecoration(hintText: 'eg. 17, Jonker Street Malacca'),
              minLines: 1,
              maxLines: null,
              maxLength: 200,
              onSaved: (value) => _address = value,
              validator: (value) =>  _address.isEmpty ? 'Enter your address' : null,
              onChanged: (value) => setState(() => _address = value),
            )
          ],
        ));
  }

//SELECT STATE ... RETURN String eg. 'Kedah'
  Widget stateSelection() {
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 50, right: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'State',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12)),
            child: DropdownButton(
              hint: Text('Select State'),
              isExpanded: true,
              autofocus: true,
              elevation: 24,
              value: _selectedState,
              onChanged: (value) => setState(() => _selectedState = value),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  child: Text(' Select State'),
                  value: 'Select State',
                ),
                DropdownMenuItem(
                  child: Text(' Johor'),
                  value: 'Johor',
                ),
                DropdownMenuItem(
                  child: Text(' Kedah'),
                  value: 'Kedah',
                ),
                DropdownMenuItem(
                  child: Text(' Kelantan'),
                  value: 'Kelantan',
                ),
                DropdownMenuItem(
                  child: Text(' Melaka'),
                  value: 'Melaka',
                ),
                DropdownMenuItem(
                  child: Text(' N. Sembilan'),
                  value: 'N. Sembilan',
                ),
                DropdownMenuItem(
                  child: Text(' Pahang'),
                  value: 'Pahang',
                ),
                DropdownMenuItem(
                  child: Text(' P. Pinang'),
                  value: 'P. Pinang',
                ),
                DropdownMenuItem(
                  child: Text(' Perak'),
                  value: 'Perak',
                ),
                DropdownMenuItem(
                  child: Text(' Perlis'),
                  value: 'Perlis',
                ),
                DropdownMenuItem(
                  child: Text(' Sabah'),
                  value: 'Sabah',
                ),
                DropdownMenuItem(
                  child: Text(' Sarawak'),
                  value: 'Sarawak',
                ),
                DropdownMenuItem(
                  child: Text(' Selangor'),
                  value: 'Selangor',
                ),
                DropdownMenuItem(
                  child: Text(' Terengganu'),
                  value: 'Terengganu',
                ),
                DropdownMenuItem(
                  child: Text(' K. Lumpur'),
                  value: 'K. Lumpur',
                ),
                DropdownMenuItem(
                  child: Text(' Labuan'),
                  value: 'Labuan',
                ),
                DropdownMenuItem(
                  child: Text(' Putrajaya'),
                  value: 'Putrajaya',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

//for dealers, upload images
  Widget certificateOfBusiness() {
    return Padding(
        padding: EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Certificate of Business',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _image == null
                  ? FlatButton(
                      onPressed: () {
                        _selectUploadSource();
                      },
                      splashColor: Colors.cyan[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.file_upload),
                            Text('You have not yet upload a certificate'),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(child: Image.file(File(_image.path))),
                        FlatButton(
                          onPressed: () {
                            _selectUploadSource();
                          },
                          padding: EdgeInsets.all(0),
                          child: Container(
                            constraints: BoxConstraints(minHeight: 30.0),
                            alignment: Alignment.center,
                            child: Text(
                              'Reupload image',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ],
        ));
  }

//SAJA NK ACAH
  Widget disclaimerAndTnC() {
    return Padding(
      padding: EdgeInsets.only(top: 50, left: 35),
      child: Row(
        children: <Widget>[
          Checkbox(
            activeColor: Colors.blue,
            value: _acceptTnC,
            onChanged: (val) => setState(() => _acceptTnC = val),
          ),
          RichText(
            text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: 'I agree to the Car Expert '),
                  TextSpan(
                      text: 'Terms of Service ',
                      style: TextStyle(color: Colors.cyan)),
                  TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nand '),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.cyan))
                ]),
          )
        ],
      ),
    );
  }

//SAJA NK ACAH x2
  Widget newsletterCheckbox() {
    return Padding(
      padding: EdgeInsets.only(left: 35),
      child: Row(
        children: <Widget>[
          Checkbox(
            activeColor: Colors.blue,
            value: _acceptNewsletter,
            onChanged: (val) => setState(() => _acceptNewsletter = val),
          ),
          RichText(
            text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: 'I would like to receive Weekly and Monthly'),
                  TextSpan(
                    text: '\nNewsletter from Car Expert',
                  )
                ]),
          )
        ],
      ),
    );
  }

//DUA BUTTON KAT BAWAH
  Widget buttonAcceptDeny() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            elevation: 5,
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(
            width: 50,
          ),
          Consumer<UserNotifier>(
            builder: (context, notifier, widget) {
              return RaisedButton(
                elevation: 5,
                color: Colors.blue,
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  registerAccount(notifier);
                },
              );
            },
          )
        ],
      ),
    );
  }

  void registerAccount(UserNotifier notifier) async {
    if (_formKey.currentState.validate()) {
      if (isDealer) {
        await _auth.signUpWithEmailAndPassword(
            notifier, isDealer, email, password,
            certificate: _image,
            dealerData: DealerDetails(
              email: email,
              adCount: 0,
              address: _address,
              phone: _phoneNumber,
              state: _selectedState,
              refDocument: List(),
              username: _userName
            ));
        // Navigator.pop(context);
      } else {
        await _auth.signUpWithEmailAndPassword(
            notifier, isDealer, email, password,
            userData: UserDetails(
              email: email,
              phone: _phoneNumber,
              state: _selectedState,
              username: _userName,
              firstName: _firstName,
              lastName: _lastName,
              likedCars: List(),
              uidSeller: List(),
            ));
        // Navigator.pop(context);
      }
    }
  }

  Future getImage(int number) async {
    //for single file

    var pickedFile;

    if (number == 1) {
      pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    } else {
      pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    }

    setState(() {
      _image = File(pickedFile.path);
      Navigator.pop(context);
    });
  }

  Future<bool> _selectUploadSource() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose the source',
          style: TextStyle(color: Colors.blue),
        ),
        content: Text(_image == null
            ? 'Upload the Certificate of Business'
            : 'Reuploading a new certificate will discard the current certificate uploaded'),
        elevation: 10,
        buttonPadding: EdgeInsets.only(bottom: 10, left: 30, right: 30),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              getImage(1);
            },
            child: Text(
              'Camera',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () {
              getImage(2);
            },
            child: Text(
              'Gallery',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
