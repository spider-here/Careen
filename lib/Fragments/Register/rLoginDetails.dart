import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class rLoginDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return rLoginDetailsState();
  }
}

class rLoginDetailsState extends State {
  AppCustomComponents _customComponents = new AppCustomComponents();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: _customComponents.cCard(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _customComponents.cHeaderText("Set your access"),
                _customComponents.cTextField(
                    "Enter Username",
                    _usernameController,
                    false,
                    Icon(Icons.person_outline,
                        color: Colors.black87, size: 20.0),
                    TextInputType.text),
                _customComponents.cTextField(
                    "Enter Password",
                    _passwordController,
                    true,
                    Icon(Icons.password_outlined,
                        color: Colors.black87, size: 20.0),
                    TextInputType.text),
              ],
            ),
            MediaQuery.of(context).size.height / 2.5,
            MediaQuery.of(context).size.width / 1.2, EdgeInsets.only(top: 20.0, bottom: 10.0))
    );
  }
}
