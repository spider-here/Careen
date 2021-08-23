import 'package:careen/Activities/CaptainHome.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Splash.dart';

class CaptainInitialInfo extends StatefulWidget {
  var _captainId;

  CaptainInitialInfo(var _captainId) {
    this._captainId = _captainId;
  }

  @override
  State<StatefulWidget> createState() {
    return CaptainInitialInfoState(_captainId);
  }
}

class CaptainInitialInfoState extends State {
  var _captainId;
  var _currentLatitude;
  var _currentLongitude;

  CaptainInitialInfoState(var _captainId) {
    this._captainId = _captainId;
  }

  AppCustomComponents _customComponents = new AppCustomComponents();
  TextEditingController _editName = new TextEditingController();
  TextEditingController _editMobile = new TextEditingController();
  TextEditingController _editVehicleId = new TextEditingController();
  TextEditingController _editVehicleDescription = new TextEditingController();
  final DBRef = FirebaseDatabase.instance.reference().child("Available_Rides");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: _customComponents.cTitleText(
            "Careen Captain", 20.0, Colors.grey.shade50),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Align(
            alignment: FractionalOffset.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.all(20.0)),
                _customComponents.cHeaderText(
                    "Please enter your today's ride info to continue."),
                Padding(padding: EdgeInsets.all(15.0)),
                _customComponents.cTextField("Full Name", _editName, false,
                    Icon(Icons.perm_identity_outlined), TextInputType.text),
                Padding(padding: EdgeInsets.all(5.0)),
                _customComponents.cTextField("Mobile#", _editMobile, false,
                    Icon(Icons.phone_android), TextInputType.number),
                Padding(padding: EdgeInsets.all(5.0)),
                _customComponents.cTextField("Vehicle#", _editVehicleId, false,
                    Icon(Icons.directions_car_outlined), TextInputType.text),
                Padding(padding: EdgeInsets.all(5.0)),
                _customComponents.cTextField(
                    "Vehicle Model & Color",
                    _editVehicleDescription,
                    false,
                    Icon(Icons.directions_car_outlined),
                    TextInputType.text),
              ],
            ),
          ),
          Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _cancelInfo,
                      child: Text(
                        "Cancel",
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: _saveInfo,
                      child: Text(
                        "Done",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _saveInfo() async {
    if (_editName.text.trim().length > 3 &&
        _editMobile.text.trim().length > 11 &&
        _editVehicleId.text.trim().length > 2 &&
        _editVehicleDescription.text.trim().length > 5) {
      await _postInfo().then((value) => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CaptainHome(_captainId))));
    } else {
      final snackBar =
          SnackBar(content: Text('Please enter all/valid details'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _postInfo() async {
    DBRef.child(_captainId).child("Captain_ID").set(_captainId);
    DBRef.child(_captainId).child("Captain's_Name").set(_editName.text);
    DBRef.child(_captainId).child("Captain's_Mobile_No").set(_editMobile.text);
    DBRef.child(_captainId).child("Vehicle_ID").set(_editVehicleId.text);
    DBRef.child(_captainId)
        .child("Vehicle_Model_Color")
        .set(_editVehicleDescription.text);
    await DBRef.child(_captainId).child("Latitude").set(_currentLatitude);
    await DBRef.child(_captainId).child("Longitude").set(_currentLongitude);
  }

  void _cancelInfo() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Splash()));
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = position.latitude;
    _currentLongitude = position.longitude;
  }

  @override
  void initState() {
    _getUserLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _editVehicleDescription.dispose();
    _editVehicleId.dispose();
    _editMobile.dispose();
    _editName.dispose();
  }
}
