import 'package:firebase_database/firebase_database.dart';

class Rides{
  String userId;
  String lat, long;

  Rides(this.userId, this.lat, this.long);

  Rides.fromSnapshot(DataSnapshot snapshot) :
    userId = snapshot.value["User_ID"],
    lat = snapshot.value["Latitude"].toString(),
    long = snapshot.value["Longitude"].toString();

  toJson(){
    return {
      "User_ID" : userId,
      "Latitude" : lat,
      "Longitude" : long,
    };
  }
}