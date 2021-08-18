import 'dart:async';

import 'package:careen/Activities/Login.dart';
import 'package:careen/Utils/AppCustomComponents.dart';
import 'package:careen/Utils/FirebaseAuthentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State {
  AppCustomComponents _customComponents = new AppCustomComponents();
  FirebaseAuthentication _firebaseAuthentication = new FirebaseAuthentication();
  Completer<GoogleMapController> _mapController = Completer();

  late LatLng _initialPosition;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  var currentLocation;

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
              padding: EdgeInsets.all(5.0),
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
              markers: _markers,

              mapType: _currentMapType,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.4746,
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
                      Text(
                          "_locationData.latitude.toString() + _locationData.longitude.toString()"),
                      Spacer(),
                      ElevatedButton(
                          onPressed: () {},
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
    _firebaseAuthentication.signOut().then((value) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login())));
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
                      TextButton(onPressed: () {}, child: Text("Sign Out")),
                    ],
                  ),
                  MediaQuery.of(context).size.height / 5,
                  MediaQuery.of(context).size.width / 2,
                  EdgeInsets.only(top: 0.0, bottom: 0.0)));
        });
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController.complete(controller);
      _mapMarker();
    });
  }

  _onCameraMove(CameraPosition position) {
    _initialPosition = position.target;
  }

  _mapMarker() {
    setState(() {
      _markers.add(
          Marker(
              markerId: MarkerId(_initialPosition.toString()),
              position: _initialPosition,
              draggable: true,
              icon: BitmapDescriptor.defaultMarker));
    });
  }
}
