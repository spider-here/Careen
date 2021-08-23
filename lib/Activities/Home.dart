import 'dart:async';
import 'dart:math';

import 'package:careen/Activities/CaptainIntialInfo.dart';
import 'package:careen/Activities/Splash.dart';
import 'package:careen/DataModels/Rides.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_beep/flutter_beep.dart';

class Home extends StatefulWidget {
  LatLng _passengerLocation = LatLng(33, 73);
  var _passengerId;

  Home(LatLng _passengerLocation, var _passengerId) {
    this._passengerLocation = _passengerLocation;
    this._passengerId = _passengerId;
  }

  @override
  State<StatefulWidget> createState() {
    return HomeState(_passengerLocation, _passengerId);
  }
}

class HomeState extends State {
  HomeState(LatLng _passengerLocation, var _passengerId) {
    this._passengerLocation = _passengerLocation;
    this._passengerId = _passengerId;
  }

  AppCustomComponents _customComponents = new AppCustomComponents();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  Completer<GoogleMapController> _mapController = Completer();
  LatLng _passengerLocation = LatLng(33, 73);
  LatLng _pickupLocation = LatLng(33, 73);
  MapType _currentMapType = MapType.normal;

  // late StreamSubscription<Event> _onAvailabeRidesAddedSubsciption;
  // late StreamSubscription<Event> _onAvailabeRidesChangedSubsciption;
  var _currentLocation;
  var _passengerId;

  final DBRef = FirebaseDatabase.instance.reference();

  List<Rides> _ridesAvailable = [];
  var _nearestRideIndex;
  bool _pickupBtnVisibility = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                  Icons.more_vert_outlined,
                  color: Colors.white,
                ),
                onTap: onclickOptionsMenu,
              ),
            )
          ],
        ),
        body: Center(
            child: Stack(
          children: [
            GoogleMap(
              mapType: _currentMapType,
              initialCameraPosition: CameraPosition(
                target: _passengerLocation,
                zoom: 16.0,
              ),
              onMapCreated: _onMapCreated,
              zoomGesturesEnabled: true,
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: true,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: _customComponents.cCard(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Latitude: " + _pickupLocation.latitude.toString()),
                      Text(
                          "Longitude: " + _pickupLocation.longitude.toString()),
                      Spacer(),
                      Visibility(
                        visible: _pickupBtnVisibility,
                        child: ElevatedButton(
                            onPressed: _confirmPickup,
                            child: Text("Confirm Pickup"),
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width / 1.5,
                                    20.0))),
                      ),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 4.2,
                  MediaQuery.of(context).size.width / 1.1,
                  EdgeInsets.only(top: 20.0, bottom: 10.0)),
            ),
            Align(
              alignment: FractionalOffset.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                      elevation: 5.0,
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          "Pickup from here!",
                          style: TextStyle(color: Colors.white, fontSize: 8.0),
                        ),
                      )),
                  Icon(Icons.emoji_people_rounded),
                ],
              ),
            )
          ],
        )));
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
                      Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CaptainInitialInfo(_passengerId)));
                          },
                          child: Text("Switch to Captain Account")),
                      TextButton(onPressed: signOut, child: Text("Sign Out")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController.complete(controller);
    });
  }

  _onCameraMove(CameraPosition position) {
    setState(() {
      _pickupLocation = position.target;
    });
  }

  _confirmPickup() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: _customComponents.cCard(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _customComponents.cHeaderText("Searching Ride.. ."),
                      Spacer(),
                      CircularProgressIndicator(
                        color: Theme.of(context).accentColor,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 3.8,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });

    String _nearestRide = await _getNearestRide();
    if (_nearestRide != null) {
      _assignRide(_nearestRide, _passengerId, _pickupLocation).then((value) {
        Navigator.pop(context);
        _pickupBtnVisibility = false;
        setState(() {});
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  //this right here
                  child: _customComponents.cCard(
                      Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _customComponents.cHeaderText("Ride Confirmed"),
                              Padding(padding: EdgeInsets.all(10.0)),
                              _customComponents
                                  .cHeaderText("Captain is on it's way"),
                              Padding(padding: EdgeInsets.all(15.0)),
                              Row(
                                children: [
                                  Text("Captain ID: "),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _ridesAvailable[_nearestRideIndex]
                                          .captainID,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Row(
                                children: [
                                  Text("Captain's Name: "),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _ridesAvailable[_nearestRideIndex]
                                          .captainName,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Row(
                                children: [
                                  Text("Vehicle ID: "),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _ridesAvailable[_nearestRideIndex]
                                          .vehicleID,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Row(
                                children: [
                                  Text("Other Info(Vehicle): "),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _ridesAvailable[_nearestRideIndex]
                                          .otherInfo,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              ElevatedButton.icon(
                                onPressed: _callCaptain,
                                label: Text(
                                  "Call Captain?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: _customComponents.cHeaderText(
                                "Sit back and relax, you'll be informed as soon as the captain arrives.\n\nHave a safe and happy journey with Careen :)"),
                          ),
                        ],
                      ),
                      MediaQuery.of(context).size.height / 2,
                      MediaQuery.of(context).size.width / 1.2,
                      EdgeInsets.zero));
            });
        ;
        _captainArrival();
      });
    } else {
      final snackBar =
          SnackBar(content: Text('Sorry! No rides available right now.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _callCaptain() {
    setState(() {
      _makePhoneCall(
          'tel:' + _ridesAvailable[_nearestRideIndex].captainMobileNo);
    });
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      final snackBar =
          SnackBar(content: Text('Unable to call at this moment.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _availableRides() {
    var getRefQuery = DBRef.child("Available_Rides");
    getRefQuery.onChildAdded.listen(onRideAdded);
    getRefQuery.onChildChanged.listen(onRideChanged);
  }

  Future<String> _getNearestRide() async {
    List<double> distance = [];
    for (int i = 0; i < _ridesAvailable.length; i++) {
      var d = Geolocator.distanceBetween(
          _pickupLocation.latitude,
          _pickupLocation.longitude,
          double.parse(_ridesAvailable[i].lat),
          double.parse(_ridesAvailable[i].long));
      distance.add(d);
    }
    var nearest = distance.reduce(min);
    print(nearest);
    _nearestRideIndex = distance.indexOf(nearest);
    var rideFound = _ridesAvailable[_nearestRideIndex].captainID;
    return rideFound;
  }

  Future<void> _assignRide(String _nearestRideID, String _passengerId,
      LatLng _pickupLocation) async {
    var assign = DBRef.child("Assigned_Rides").child(_passengerId);
    assign.child("Captain_ID").set(_nearestRideID);
    assign.child("Passenger_ID").set(_passengerId);
    assign.child("Pickup_Latitude").set(_pickupLocation.latitude);
    assign.child("Pickup_Longitude").set(_pickupLocation.longitude);
    assign.child("Captain_Arrived").set("false");
  }

  _captainArrival() async {
    var getRefQuery = DBRef.child("Assigned_Rides")
        .child(_passengerId)
        .child("Captain_Arrived");
    await getRefQuery.onValue.listen((event) {
      print(event.snapshot.value);
      if (event.snapshot.value == "true") {
        setState(() {
          FlutterBeep.playSysSound(
              AndroidSoundIDs.TONE_CDMA_CALL_SIGNAL_ISDN_INTERGROUP);
          Navigator.pop(context);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //this right here
                    child: _customComponents.cCard(
                        Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _customComponents.cHeaderText("Ride Confirmed"),
                                Padding(padding: EdgeInsets.all(10.0)),
                                Text(
                                  "Captain Arrived!",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(padding: EdgeInsets.all(15.0)),
                                Row(
                                  children: [
                                    Text("Captain ID: "),
                                    Expanded(
                                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        _ridesAvailable[_nearestRideIndex]
                                            .captainID,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                Row(
                                  children: [
                                    Text("Captain's Name: "),
                                    Expanded(
                                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        _ridesAvailable[_nearestRideIndex]
                                            .captainName,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                Row(
                                  children: [
                                    Text("Vehicle ID: "),
                                    Expanded(
                                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        _ridesAvailable[_nearestRideIndex]
                                            .vehicleID,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                Row(
                                  children: [
                                    Text("Other Info(Vehicle): "),
                                    Expanded(
                                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        _ridesAvailable[_nearestRideIndex]
                                            .otherInfo,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                ElevatedButton.icon(
                                  onPressed: _callCaptain,
                                  label: Text(
                                    "Call Captain?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  icon: Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: _customComponents.cHeaderText(
                                  "Enjoy the ride! Have a safe journey :)"),
                            ),
                          ],
                        ),
                        MediaQuery.of(context).size.height / 2,
                        MediaQuery.of(context).size.width / 1.5,
                        EdgeInsets.zero));
              });
          ;
        });
      }
    });
  }

  void onRideAdded(Event event) {
    setState(() {
      _ridesAvailable.add(Rides.fromSnapshot(event.snapshot));
    });
  }

  void onRideChanged(Event event) {
    var oldEntry = _ridesAvailable.singleWhere((entry) {
      return entry.captainID == event.snapshot.key;
    });

    setState(() {
      _ridesAvailable[_ridesAvailable.indexOf(oldEntry)] =
          Rides.fromSnapshot(event.snapshot);
    });
  }

  @override
  void initState() {
    super.initState();
    _pickupLocation = _passengerLocation;
    _availableRides();
  }
}
