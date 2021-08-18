import 'package:careen/Activities/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(new MaterialApp(
      title: "Careen",
      theme: ThemeData(
          backgroundColor: Colors.grey.shade50,
          primaryColor: Colors.black,
          accentColor: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black87,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0))))),
          fontFamily: "Nunito"),
      home: Splash()));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}