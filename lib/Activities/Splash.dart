import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login.dart';

class Splash extends StatelessWidget {
  AppCustomComponents _customComponents = new AppCustomComponents();

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: _customComponents.cTitleText("Careen", 50.0, Colors.black87),
      nextScreen: Login(),
      backgroundColor: Theme.of(context).backgroundColor,
      splashTransition: SplashTransition.slideTransition,
      duration: 2000,
      centered: true,
    );
  }
}
