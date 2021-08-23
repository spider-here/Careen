import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterState();
  }
}

class RegisterState extends State {
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  AppCustomComponents _customComponents = new AppCustomComponents();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passwordRetypeController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title:
              _customComponents.cTitleText("Careen", 20.0, Colors.grey.shade50),
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _customComponents.cTitleText("Sign Up ;)", 25.0, Colors.black87),
              _customComponents.cCard(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _customComponents.cHeaderText("Set your access"),
                      _customComponents.cTextField(
                          "Enter Email",
                          _emailController,
                          false,
                          Icon(Icons.alternate_email_outlined,
                              color: Colors.black87, size: 20.0),
                          TextInputType.text),
                      _customComponents.cTextField(
                          "Enter Password",
                          _passwordController,
                          true,
                          Icon(Icons.password_outlined,
                              color: Colors.black87, size: 20.0),
                          TextInputType.text),
                      Spacer(),
                      Row(
                        children: [
                          Spacer(),
                          ElevatedButton(
                              onPressed: _retypePassword, child: Text("Next")),
                        ],
                      ),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 2.4,
                  MediaQuery.of(context).size.width / 1.2, EdgeInsets.only(top: 20.0, bottom: 10.0)),
            ],
          ),
        ));
  }

  _retypePassword() {
    if(_emailController.text.trim().length != 0 && _emailController.text.contains('@') && _emailController.text.contains(".com")){
      if(_passwordController.text.length != 0){
        if(_passwordController.text.length > 7){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                    child: _customComponents.cCard(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _customComponents.cHeaderText("Just a moment.."),
                            _customComponents.cTextField(
                                "Retype Password",
                                _passwordRetypeController,
                                true,
                                Icon(Icons.password_outlined,
                                    color: Colors.black87, size: 20.0),
                                TextInputType.text),
                            Spacer(),
                            Row(
                              children: [
                                Spacer(),
                                ElevatedButton(
                                    onPressed: _validate, child: Text("Done")),
                              ],
                            ),
                          ],
                        ),
                        MediaQuery.of(context).size.height / 3.8,
                        MediaQuery.of(context).size.width / 1.2, EdgeInsets.only(top: 0.0, bottom: 0.0)));
              });
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must be at least 8 characters.')));
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please set a password.')));
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please Enter Valid Email.')));
    }
  }

  _validate(){
    if(_passwordController.text!=_passwordRetypeController.text){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords don't match, Please try again!")));
      Navigator.pop(context);
      _passwordController.clear();
    }
    else{
      Navigator.pop(context);
      _registerUser();
    }
  }

  Future _registerUser() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ),]
        )
      );
    });
    String message = await _firebaseAuthentication.register(_emailController.text.trim(), _passwordController.text);
    if(message=="Registered"){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New Account Registered :)")));
      _firebaseAuthentication.signOut();
      Navigator.pop(context);
      Navigator.pop(context);
    }
    else if(message=="WeakPassword"){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please set a strong password.")));
      Navigator.pop(context);
    }
    else if(message=="AccountAlreadyExist"){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An account on this email already exist.")));
      Navigator.pop(context);
    }
    else{
      print(message);
    }
  }
}
