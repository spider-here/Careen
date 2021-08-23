import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppCustomComponents {
  //TitleText
  Widget cTitleText(
    String titleText,
    double fontSize,
    Color color,
  ) {
    return Text(
      titleText,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 5.0,
          fontFamily: "Nunito"),
    );
  }

  //TextField
  Widget cTextField(String label, TextEditingController controller,
      bool obscure, Widget suffixIcon, TextInputType textInputType) {
    return Container(
        width: 300.0,
        height: 40.0,
        color: Colors.transparent,
        margin: EdgeInsets.only(top: 10.0),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: textInputType,
          decoration: new InputDecoration(
            fillColor: Colors.white,
            filled: true,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.all(20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            labelText: label,
            labelStyle: TextStyle(
                backgroundColor: Colors.transparent,
                color: Colors.black87,
                fontSize: 13.0,
                fontFamily: "Nunito"),
          ),
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black87,
          ),
        ));
  }

  //Login/Register Card
  Widget cCard(Widget widget, double height, double width, EdgeInsets margin) {
    return Container(
        width: width,
        height: height,
        child: Card(
            color: Colors.white,
            elevation: 10.0,
            margin: margin,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: widget,
            )));
  }

  Widget cHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 14.0,
      ),
    );
  }
}
