import 'package:firebase_database/firebase_database.dart';

class AssignedRides{
  String key;
  String captainId;
  String passengerId;
  String pickupLat;
  String pickupLong;


  AssignedRides(this.key, this.captainId, this.passengerId, this.pickupLat,
      this.pickupLong);

  AssignedRides.fromSnapshot(DataSnapshot snapshot): key = snapshot.key.toString(),
  captainId = snapshot.value["Captain_ID"].toString(),
  passengerId = snapshot.value["Passenger_ID"].toString(),
  pickupLat = snapshot.value["Pickup_Latitude"].toString(),
  pickupLong = snapshot.value["Pickup_Longitude"].toString();

}