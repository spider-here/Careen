import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class rVerification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return rVerificationState();
  }
}

class rVerificationState extends State {
  AppCustomComponents _customComponents = new AppCustomComponents();
  TextEditingController _passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: _customComponents.cCard(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _customComponents.cHeaderText("Just a moment.."),
                _customComponents.cTextField(
                    "Retype Password",
                    _passwordController,
                    true,
                    Icon(Icons.password_outlined,
                        color: Colors.black87, size: 20.0),
                    TextInputType.text),
              ],
            ),
            MediaQuery.of(context).size.height / 2.5,
            MediaQuery.of(context).size.width / 1.2, EdgeInsets.only(top: 20.0, bottom: 10.0)));
  }
}
