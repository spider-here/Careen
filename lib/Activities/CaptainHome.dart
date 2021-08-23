import 'package:careen/Activities/CaptainRideAssigned.dart';
import 'package:careen/Activities/Splash.dart';
import 'package:careen/DataModels/AssignedRides.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';

class CaptainHome extends StatefulWidget {
  var _captainId;

  CaptainHome(var _captainId) {
    this._captainId = _captainId;
  }

  @override
  State<StatefulWidget> createState() {
    return CaptainHomeSate(_captainId);
  }
}

class CaptainHomeSate extends State {
  var _captainId;

  CaptainHomeSate(var _captainId) {
    this._captainId = _captainId;
  }

  AppCustomComponents _customComponents = new AppCustomComponents();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  final DBRef = FirebaseDatabase.instance.reference().child("Assigned_Rides");
  List<AssignedRides> _ridesAssigned = [];
  bool arriveBtnVisibilty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: _customComponents.cTitleText(
            "Careen Captain", 20.0, Colors.grey.shade50),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(
                Icons.more_vert_outlined,
                color: Colors.white,
              ),
              onTap: onclickOptionsMenu,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: FractionalOffset.center,
            child: _customComponents.cHeaderText(
                "Sit back and relax!\n\nStay on this screen to get a ride"),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: Container(
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _onRideAssigned(var snap) {
    if (snap.captainId == _captainId) {
      FlutterBeep.playSysSound(
          AndroidSoundIDs.TONE_CDMA_CALL_SIGNAL_ISDN_INTERGROUP);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CaptainRideAssigned(snap)));
    }
  }

  _assignedRides() {
    DBRef.onChildAdded.listen(onRideAdded);
    DBRef.onChildChanged.listen(onRideChanged);
  }

  void onRideAdded(Event event) {
    setState(() {
      var snap = AssignedRides.fromSnapshot(event.snapshot);
      _ridesAssigned.add(snap);
      print(snap.captainId);
      _onRideAssigned(snap);
    });
  }

  void onRideChanged(Event event) {
    var oldEntry = _ridesAssigned.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    var snap = AssignedRides.fromSnapshot(event.snapshot);
    setState(() {
      _ridesAssigned[_ridesAssigned.indexOf(oldEntry)] = snap;
      _onRideAssigned(snap);
    });
  }

  onclickOptionsMenu() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: _customComponents.cCard(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _customComponents.cHeaderText("Options"),
                      TextButton(onPressed: signOut, child: Text("Sign Out")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });
  }

  signOut() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ]));
        });
    _firebaseAuthentication.signOut();
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Splash()));
  }

  @override
  void initState() {
    _assignedRides();
  }
}
