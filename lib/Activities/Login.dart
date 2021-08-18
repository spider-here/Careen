import 'package:careen/Activities/Home.dart';
import 'package:careen/Activities/Register.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  checkAuth() async{
    bool auth = await _firebaseAuthentication.checkAuth();
    if(auth){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  authenticate(String email, String password) {
    Future message() async {
      String message = await _firebaseAuthentication.signIn(email, password);
      if (message == "SignedIn") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
      else if (message == "NoUser") {
        final snackBar = SnackBar(content: Text('Incorrect Email!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else if (message == "IncorrectPassword") {
        final snackBar = SnackBar(content: Text('Incorrect Password!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    message();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Padding(padding: EdgeInsets.only(top: 40.0)),
              _customComponents.cTitleText("Careen", 30.0, Colors.black87),
              _customComponents.cCard(Column(
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
                    TextInputType.text,),
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
                          style: TextStyle(
                              color: Colors.blue, fontSize: 12.0),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                      ),
                      Spacer(),
                      ElevatedButton(
                          onPressed: authenticate(_emailController.text.trim(), _passController.text),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ))
                    ],
                  )
                ],
              ),
                  MediaQuery.of(context).size.height/2.5,
                  MediaQuery.of(context).size.width/1.2, EdgeInsets.only(top: 20.0, bottom: 10.0)),
            ],
          ),
        ));
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
    checkAuth();
  }
}
