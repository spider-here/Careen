import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Splash.dart';

class CaptainRideAssigned extends StatefulWidget {
  var snap;

  CaptainRideAssigned(this.snap);

  @override
  State<StatefulWidget> createState() {
    return CaptainRideAssignedState(snap);
  }
}

class CaptainRideAssignedState extends State {
  var snap;

  CaptainRideAssignedState(this.snap);

  AppCustomComponents _customComponents = new AppCustomComponents();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  final DBRef = FirebaseDatabase.instance.reference();
  int arrivedCounter = 0;
  var _captainLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title:
            _customComponents.cTitleText("Careen", 20.0, Colors.grey.shade50),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(
                Icons.exit_to_app_outlined,
                color: Colors.white,
              ),
              onTap: onclickOptionsMenu,
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          _customComponents.cTitleText("Ride Assigned!", 18.0, Colors.black87),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Passenger ID: "),
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    snap.passengerId,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ))
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _openMap(snap.pickupLat, snap.pickupLong, context);
            },
            label: Text(
              "Open Navigation",
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.navigation_outlined,
              color: Colors.white,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: _customComponents.cHeaderText(
                "Only click the button below when you arrive at the pickup location."),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _onCaptainArrived(snap);
            },
            label: Text(
              "Arrived at Pickup Location",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.map_outlined,
              color: Colors.white,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          Spacer(),
        ],
      ),
    );
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
    if (arrivedCounter > 0) {
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
    } else {
      final snackBar = SnackBar(
          content:
              Text("You're not allowed to signout during an active ride."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _openMap(
      String latitude, String longitude, BuildContext context) async {
    print(latitude + " " + longitude);
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      final snackBar =
          SnackBar(content: Text('Could not open the maps at this moment.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _onCaptainArrived(var snap) async {
    var distance = await _validateArrival(snap);
    if (distance < 50.0) {
      DBRef.child("Assigned_Rides")
          .child(snap.passengerId)
          .child("Captain_Arrived")
          .set("true");
      final snackBar = SnackBar(
          content: Text('Great! Let us inform this to the Passenger.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      arrivedCounter++;
    } else {
      final snackBar = SnackBar(
          content: Text("Sorry! You're not reached the pickup location yet."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<double> _validateArrival(snap) async {
    var distance;
    await _getUserLocation().then((value) {
      distance = Geolocator.distanceBetween(
          snap.pickupLat,
          snap.pickupLong,
          double.parse(_captainLocation.lat),
          double.parse(_captainLocation.long));
    });
    return distance;
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _captainLocation = LatLng(position.latitude, position.longitude);
  }

  _removeAvailableStatus() async {
    String uid = await _firebaseAuthentication.getCurrentUID();
    DBRef.child("Available_Rides").child(uid).remove();
  }

  @override
  void initState() {
    FlutterBeep.playSysSound(
        AndroidSoundIDs.TONE_CDMA_CALL_SIGNAL_ISDN_INTERGROUP);
    _getUserLocation();
    _removeAvailableStatus();
  }
}
