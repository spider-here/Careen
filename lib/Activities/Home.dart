import 'dart:async';

import 'package:careen/Activities/Splash.dart';
import 'package:careen/DataModels/Rides.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  LatLng _userLocation = LatLng(33, 73);
  var _userId;
  Home(LatLng _userLocation, var _userId) {
    this._userLocation=_userLocation;
    this._userId=_userId;
  }
  @override
  State<StatefulWidget> createState() {
    return HomeState(_userLocation, _userId);
  }
}

class HomeState extends State {

  HomeState(LatLng _userLocation, var _userId) {
    this._userLocation=_userLocation;
    this._userId=_userId;
  }

  AppCustomComponents _customComponents = new AppCustomComponents();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  Completer<GoogleMapController> _mapController = Completer();
  LatLng _userLocation = LatLng(33, 73);
  LatLng _pickupLocation = LatLng(33, 73);
  MapType _currentMapType = MapType.normal;
  late StreamSubscription<Event> _onAvailabeRidesAddedSubsciption;
  late StreamSubscription<Event> _onAvailabeRidesChangedSubsciption;
  var _currentLocation;
  var _userId;

  final DBRef =FirebaseDatabase.instance.reference();

  List<Rides> _ridesAvailable = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: _customComponents.cTitleText("Careen", 20.0, Colors.grey.shade50),
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
                target: _userLocation,
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
                      Text("Longitude: " + _pickupLocation.longitude.toString()),
                      Spacer(),
                      ElevatedButton(
                          onPressed: _confirmPickup,
                          child: Text("Confirm Pickup"),
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 1.5,
                                  20.0))),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                      "Pickup from here!",
                      style: TextStyle(color: Colors.white, fontSize: 8.0),
                    ),
              )
                  ),
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
                          onPressed: () {},
                          child: Text("Switch to Driver Account")),
                      TextButton(onPressed: signOut, child: Text("Sign Out")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });
  }

  _onMapCreated(GoogleMapController controller) {
    setState((){
      _mapController.complete(controller);
    });
  }

  _onCameraMove(CameraPosition position) {
    setState(() {
      _pickupLocation = position.target;
    });
  }

  _confirmPickup() async{
    _requestRide();
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
                      TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });
  }

  _availableRides(){
    var getRefQuery = DBRef.child("Ride_Requests");
    getRefQuery.onChildAdded.listen(onRideAdded);
    getRefQuery.onChildChanged.listen(onRideChanged);
  }

  void _requestRide(){
    DBRef.child("Available_Rides").child(_userId.toString()).set({
      "User_ID" : _userId.toString(),
      "Latitude" : _pickupLocation.latitude.toString(),
      "Longitude" : _pickupLocation.longitude.toString()
    });
  }

  void onRideAdded(Event event) {
    setState(() {
      _ridesAvailable.add(Rides.fromSnapshot(event.snapshot));
      print(_ridesAvailable[0].lat);
    });
  }

  void onRideChanged(Event event) {
    var oldEntry = _ridesAvailable.singleWhere((entry) {
      return entry.userId == event.snapshot.key;
    });

    setState(() {
      _ridesAvailable[_ridesAvailable.indexOf(oldEntry)] =
          Rides.fromSnapshot(event.snapshot);
    });
  }

  @override
  void initState() {
    super.initState();
    _pickupLocation = _userLocation;
    _availableRides();
  }

}
