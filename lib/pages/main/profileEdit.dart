import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final String userUID;

  EditProfile({
    Key key,
    this.userUID,
  }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  //Stream<DocumentSnapshot> userDetails;

  String _uid;
  String _userName;
  String _firstName;
  String _lastName;
  String _address;
  String _phoneNumber;
  String _selectedState;

  @override
  void initState() {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    _uid = widget.userUID;
    if (notifier.dealerMode) {
      _userName = notifier.getDealerDetails.username;
      _address = notifier.getDealerDetails.address;
      _phoneNumber = notifier.getDealerDetails.phone;
      _selectedState = notifier.getDealerDetails.state;
    } else {
      _userName = notifier.getUserDetails.username;
      _firstName = notifier.getUserDetails.firstName;
      _lastName = notifier.getUserDetails.lastName;
      _phoneNumber = notifier.getUserDetails.phone;
      _selectedState = notifier.getUserDetails.state;
    }
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit your profile',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(children: <Widget>[
              userNameField(),
              if (!notifier.dealerMode) ...{
                firstNameField(),
                lastNameField(),
              } else ...{
                addressField(),
              },
              phoneNumberField(),
              stateSelection(),
              buttonSubmit(),
              SizedBox(
                height: 20,
              )
            ]),
          )
        ],
      ),
    );
  }

  Widget userNameField() {
    return Consumer<UserNotifier>(builder: (context, value, widget) {
      return Padding(
          padding: EdgeInsets.only(top: 40, left: 50, right: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Username:',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
              TextFormField(
                initialValue: _userName,
                maxLines: 1,
                onSaved: (value) => _userName = value.trim(),
                validator: (value) =>
                    _userName.isEmpty ? 'Enter your username' : null,
                onChanged: (value) => setState(() => _userName = value),
              )
            ],
          ));
    });
  }

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
              initialValue: _firstName,
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
              initialValue: _lastName,
              maxLines: 1,
              onSaved: (value) => _lastName = value,
              validator: (value) =>
                  _lastName.isEmpty ? 'Enter your last name' : null,
              onChanged: (value) => setState(() => _lastName = value),
            )
          ],
        ));
  }

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
              initialValue: _address,
              minLines: 1,
              maxLines: null,
              maxLength: 200,
              onSaved: (value) => _address = value,
              validator: (value) =>
                  _address.isEmpty ? 'Enter your address' : null,
              onChanged: (value) => setState(() => _address = value),
            )
          ],
        ));
  }

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
              initialValue: _phoneNumber,
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
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12)),
            child: DropdownButton(
              hint: Text('$_selectedState'),
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

  Widget buttonSubmit() {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
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
          RaisedButton(
            elevation: 5,
            color: Colors.blue,
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              //edit data
              if (_formKey.currentState.validate()) {
                print('[ProfileEdit] No Errors, Data Update Successfully');
                if (notifier.dealerMode) {
                  await _auth.editProfile(
                    _uid,
                    _userName,
                    _phoneNumber,
                    _selectedState,
                    notifier,
                    address: _address,
                  );
                } else {
                  await _auth.editProfile(
                    _uid,
                    _userName,
                    _phoneNumber,
                    _selectedState,
                    notifier,
                    firstName: _firstName,
                    lastName: _lastName,
                  );
                }

                Navigator.pop(context);
              } else {
                print('[ProfileUpdate] wey masukan data la');
              }
            },
          ),
        ],
      ),
    );
  }
}
