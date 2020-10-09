import 'dart:io';

import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/main/profileEdit.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))),
            expandedHeight: 200,
            elevation: 20,
            forceElevated: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                //onPressed: null,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfile(
                              userUID: notifier.userUID,
                            ))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: ClipOval(
                          child: Material(
                            color: Colors.cyan[300],
                            child: InkWell(
                              splashColor: Colors.lightBlueAccent,
                              child: SizedBox(
                                  width: 111,
                                  height: 111,
                                  child: notifier.getProfilePicture != null
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      : 
                                      // Image.file(
                                      //     notifier.getProfilePicture,
                                      //   )
                                      Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/car-database-34fe0.appspot.com/o/LBXiBXe5nVZ132oZ0MxQjFmVl9b2%2F738555030070U10?alt=media&token=9956079c-03b8-450c-be30-1d42f1a43db3',
                                      ),
                                        ),
                              onTap: () {
                                _showErrorAlertDialog(context);
                              },
                            ),
                          ),
                        ))
                  ],
                )),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: 450,
            color: Colors.white.withOpacity(0.0),
            child: Padding(
              padding: EdgeInsets.only(left: 2, right: 2, top: 3),
              child: Card(
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 10),
                      child: userInformation(),
                      //child: CircularProgressIndicator(),
                    ),
                    Positioned(
                        top: 25,
                        left: 22,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.info,
                              color: Colors.cyan,
                              size: 19,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'User Information',
                              style: TextStyle(color: Colors.cyan, fontSize: 18, fontWeight: FontWeight.w400),
                            )
                          ],
                        ))
                  ],
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 20,
              ),
            ),
          )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: 360,
            color: Colors.white.withOpacity(0.0),
            child: Padding(
              padding: EdgeInsets.only(left: 2, right: 2, top: 3),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 20,
                child: settingOption(),
              ),
            ),
          )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 10),
            child: GestureDetector(
              onTap: () async {
                await _auth.signOut(notifier);
              },
              child: Container(
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )),
            ),
          )),
        ],
      );
    });
  }

  Widget userInformation() {
    return Consumer<UserNotifier>(
      builder: (context, value, widget) {
        return ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            if (value.dealerMode) ...{
              //DEALER
              ListTile(
                title: Text('Username'),
                subtitle: Text(value.getDealerDetails.username),
              ),
              ListTile(
                title: Text('Address'),
                subtitle: Text(value.getDealerDetails.address),
              ),
              ListTile(
                title: Text('State'),
                subtitle: Text(value.getDealerDetails.state),
              ),
              ListTile(
                title: Text('Phone'),
                subtitle: Text(value.getDealerDetails.phone),
              ),
              ListTile(
                title: Text('Email'),
                subtitle: Text(value.getDealerDetails.email),
              ),
            } else ...{
              //USER
              ListTile(
                title: Text('Username'),
                subtitle: Text(value.getUserDetails.username),
              ),
              ListTile(
                title: Text('Full Name'),
                subtitle: Text(value.getUserDetails.firstName + ' ' + value.getUserDetails.lastName),
              ),
              ListTile(
                title: Text('State'),
                subtitle: Text(value.getUserDetails.state),
              ),
              ListTile(
                title: Text('Phone'),
                subtitle: Text(value.getUserDetails.phone),
              ),
              ListTile(
                title: Text('Email'),
                subtitle: Text(value.getUserDetails.email),
              ),
            }
          ],
        );
      },
    );
  }

  Widget settingOption() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Divider(
            thickness: 1,
          ),
          ListTile(
            trailing: Icon(Icons.settings),
            title: Text('Setting'),
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            trailing: Icon(Icons.collections_bookmark),
            title: Text('Privacy Policy & Term of Services'),
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            trailing: Icon(Icons.feedback),
            title: Text('Feedback'),
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            trailing: Icon(Icons.star_half),
            title: Text('Rate Us'),
          ),
          Divider(
            thickness: 1,
          ),
        ],
      ),
    );
  }

  _showErrorAlertDialog(BuildContext context) {
    //UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);

    var pickedFile;

    //bool isUpdate = userNotifier.getProfilePicture == null ? false : true;

    return showDialog(
        context: context,
        builder: (context) {
          return Consumer<UserNotifier>(builder: (context, noti, widget) {
            return AlertDialog(
              actionsPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Center(
                child: Column(children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.account_box,
                        size: 40,
                        color: Colors.blue,
                      ),
                      onPressed: null),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    noti.getProfilePicture == null ? 'Upload a profile picture?' : 'Update your profile picture?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ]),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.photo_camera),
                      Text(
                        "Camera",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    pickedFile = await imagePicker.getImage(source: ImageSource.camera);
                    File image = File(pickedFile.path);
                    await _onSubmitImage(context, image);
                    // await DatabaseService().updateProfilePic(userNotifier, isUpdate, image);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.image),
                      Text(
                        "Gallery",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
                    File image = File(pickedFile.path);
                    await _onSubmitImage(context, image);
                    // DatabaseService().updateProfilePic(userNotifier, isUpdate, image);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  Future<bool> _onSubmitImage(BuildContext context, File image) {
    UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);

    bool isUpdate = userNotifier.getProfilePicture == null ? true : false;

    return showDialog(
        context: context,
        builder: (context) => FutureBuilder<bool>(
              future: DatabaseService().updateProfilePic(userNotifier, isUpdate, image),
              builder: (context, snapshot) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Container(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (snapshot.connectionState == ConnectionState.done) ...{
                          Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 40),
                              child: RichText(
                                text: TextSpan(style: TextStyle(color: Colors.black, fontSize: 20), children: <TextSpan>[
                                  if (snapshot.data) ...{
                                    TextSpan(text: 'You have succesfully upload the profile picture'),
                                  } else ...{
                                    TextSpan(text: 'Error occured during upload'),
                                  }
                                ]),
                              )),
                          GestureDetector(
                            child: Text(
                              snapshot.data ? 'Done' : 'Try Again',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            onTap: snapshot.data
                                ? () {
                                    Navigator.of(context).pop(true);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                : () {
                                    Navigator.of(context).pop(false);
                                  },
                          )
                        } else ...{
                          Center(
                            child: SizedBox(
                              height: 75,
                              width: 75,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        }
                      ],
                    ),
                  ),
                );
              },
            ));
  }
}
