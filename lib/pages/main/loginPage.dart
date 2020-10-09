import 'package:carexpert/pages/main/signUpPage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading;
  String _errorMessage;
  bool _isLoginForm;
  String _email;
  String _password;
  String _password2;

  final AuthService _auth = AuthService();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _errorMessage = '';
    _isLoading = false;
    _isLoginForm = true;
    //this is causing init problems
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        showForm(),
        if (_isLoading) ...{
          Container(
            color: Colors.white.withOpacity(0.7),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    strokeWidth: 5,
                    backgroundColor: Colors.blue,
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                  ),
                ],
              ),
            ),
          )
        }
      ],
    ));
  }

  Widget showForm() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              showLogo(),
              showAppName(),
              emailInputField(),
              passwordInputField(),
              if (!_isLoginForm) ...{
                passwordConfirmationField(),
              },
              loginSignUpButton(),
              secondaryButton(),
              showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  //GAMBAR ATAS
  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: CircleAvatar(backgroundColor: Colors.transparent, radius: 100.0, child: Image.asset('assets/images/login.png')),
      ),
    );
  }

  Widget showAppName() {
    return Center(
      child: Text(
        'Car Experts',
        style: TextStyle(fontSize: 32, fontFamily: 'Lexis', color: Colors.blue),
      ),
    );
  }

  //EMAIL INPUT
  Widget emailInputField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 45, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.email,
            color: Colors.cyan,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Email must not be empty' : EmailValidator.validate(_email) ? null : "Invalid email address",
        onSaved: (value) => _email = value.trim(),
        onChanged: (value) {
          setState(() => _email = value);
        },
      ),
    );
  }

  //PASSWORD INPUT
  Widget passwordInputField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 30.0, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: Icon(
            Icons.lock,
            color: Colors.cyan,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : value.length >= 6 ? null : 'Password length must be 6 or more',
        onSaved: (value) => _password = value.trim(),
        onChanged: (value) {
          // get value everytime user change input
          setState(() => _password = value);
        },
      ),
    );
  }

  Widget passwordConfirmationField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 30.0, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          icon: Icon(
            Icons.lock_outline,
            color: Colors.cyan,
          ),
        ),
        onChanged: (val) {
          setState(() => _password2 = val);
        },
        validator: (value) => _password2 != _password ? 'Password does not match' : null,
      ),
    );
  }

  Widget loginSignUpButton() {
    return Consumer<UserNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: EdgeInsets.only(top: 45, left: 80, right: 80),
          child: SizedBox(
            width: 200,
            height: 40.0,
            child: RaisedButton(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: Text(
                _isLoginForm ? 'Login' : 'Create account',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onPressed: () {
                //login
                if (_isLoginForm) {
                  setState(() => _isLoading = true);
                  continueToHome(notifier);
                } else {
                  if (_formKey.currentState.validate()) {
                    dialogSignup();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  //Dialog for toggling page mode
  dialogSignup() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Consumer<UserNotifier>(
                builder: (context, notifier, widget) {
                  return Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(
                            'Register as a ...',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.black,
                          height: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blueGrey[50],
                                  onTap: () {
                                    notifier.setDealerMode = false;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpPage(
                                                email: _email,
                                                password: _password,
                                                isDealer: notifier.dealerMode,
                                              )),
                                    );
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      SizedBox(
                                        width: 120,
                                        height: 100,
                                        child: Image.asset(
                                          'assets/images/buyer.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Text(
                                        'User',
                                        style: TextStyle(fontSize: 24, fontFamily: 'Lexis', color: Colors.black87),
                                      ),
                                      // SizedBox(
                                      //   height: 19,
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Container(height: 159, width: 1, color: Colors.black),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blueGrey[50],
                                  onTap: () {
                                    notifier.setDealerMode = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpPage(
                                                email: _email,
                                                password: _password,
                                                isDealer: notifier.dealerMode,
                                              )),
                                    );
                                  },
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      SizedBox(
                                        width: 120,
                                        height: 100,
                                        child: Image.asset(
                                          'assets/images/seller.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Text(
                                        'Dealer',
                                        style: TextStyle(fontSize: 24, fontFamily: 'Lexis', color: Colors.black),
                                      ),
                                      // SizedBox(
                                      //   height: 19,
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ));
  }

  Widget secondaryButton() {
    return FlatButton(
      child: RichText(
        text: TextSpan(style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.black), children: <TextSpan>[
          _isLoginForm
              ? TextSpan(children: <TextSpan>[TextSpan(text: 'Create an '), TextSpan(text: 'account', style: TextStyle(color: Colors.cyan))])
              : TextSpan(children: <TextSpan>[TextSpan(text: 'Have an account? '), TextSpan(text: 'Sign in', style: TextStyle(color: Colors.teal))])
        ]),
      ),
      onPressed: () => setState(() => _isLoginForm = !_isLoginForm),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(fontSize: 13.0, color: Colors.red, height: 1.0, fontWeight: FontWeight.w300),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  void continueToHome(UserNotifier notifier) async {
    // if (_formKey.currentState.validate()) {
    //   // true or false
    //   dynamic result = await _auth.signIn(_email, _password);
    //   if (result == null) {
    //     // refer to firebase authentication documentation for if-else error handling :D
    //     setState(() {
    //       _errorMessage = result;
    //     });
    //   }
    // } else {
      // setState(() {
      //   _isLoading = false;
      // });
    // }
    if (_formKey.currentState.validate()) {

      dynamic result = await _auth.signIn(_email, _password);

      if (result == AuthResultStatus.successful) {
      // setState(() {
      //   _isLoading = false;
      // });
      } else {
        final errorMessage = AuthExceptionHandler.generateExceptionMessage(result);
        _showErrorAlertDialog(errorMessage);
      }
    }
  }

  _showErrorAlertDialog(error) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: Center(
              child: Column(
                children:<Widget>[
                  IconButton(
                    icon: Icon(Icons.error, size: 40, color: Colors.blue,), 
                    onPressed: null),
                    SizedBox(height: 5,),
                  Text(
                  'Login Failed',
                  style: TextStyle(color: Colors.blue),
                ),
              ]
              ),
            ),
            content: Text(error),
            actions: <Widget>[
              FlatButton(
                child: Text("Okay", style: TextStyle(fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = false;
                  });
                },
              )
            ],
          );
        });
  }
}
