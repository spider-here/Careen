import 'dart:async';

import 'package:careen/Activities/Home.dart';
import 'package:careen/Activities/Register.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State {
  AppCustomComponents _customComponents = new AppCustomComponents();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  LatLng _userLocation = LatLng(33, 73);
  var userID;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _customComponents.cTitleText("Careen", 30.0, Colors.black87),
              _customComponents.cCard(
                  Column(
                    children: [
                      _customComponents.cHeaderText("Log In"),
                      _customComponents.cTextField(
                        "Enter Email",
                        _emailController,
                        false,
                        Icon(
                          Icons.alternate_email_outlined,
                          color: Colors.black87,
                          size: 20.0,
                        ),
                        TextInputType.text,
                      ),
                      _customComponents.cTextField(
                        "Enter Password",
                        _passController,
                        true,
                        Icon(
                          Icons.password_outlined,
                          color: Colors.black87,
                          size: 20.0,
                        ),
                        TextInputType.text,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Text(
                              "Create Account",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12.0),
                            ),
                            onTap: () { _createAccount(); }),
                          Spacer(),
                          ElevatedButton(
                              onPressed: () => authenticate(
                                  _emailController.text.trim(),
                                  _passController.text),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ))
                        ],
                      )
                    ],
                  ),
                  MediaQuery.of(context).size.height / 2.5,
                  MediaQuery.of(context).size.width / 1.2,
                  EdgeInsets.only(top: 20.0, bottom: 10.0)),
            ],
          ),
        ));
  }

  _createAccount(){
      Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => Register()));
  }

  _checkAuth() async {
    bool auth = await _firebaseAuthentication.checkAuth();
    if (auth) {
      userID =await _firebaseAuthentication.getCurrentUID();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home(_userLocation, userID)));
    }
  }

  Future<ScaffoldFeatureController> authenticate(
      String email, String password) async {
      String message = await _firebaseAuthentication.signIn(email, password);
      if (message == "SignedIn") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home(_userLocation, userID)));
        final snackBar = SnackBar(content: Text('Welcome!'));
        return ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(content: Text('Incorrect Email or Password!'));
        return ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _userLocation = LatLng(position.latitude, position.longitude);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _checkAuth();
  }
}
