import 'package:firebase_database/firebase_database.dart';

class Rides {
  String captainID,
      lat,
      long,
      captainName,
      captainMobileNo,
      vehicleID,
      otherInfo;

  Rides(this.captainID, this.lat, this.long, this.captainName,
      this.captainMobileNo, this.vehicleID, this.otherInfo);

  Rides.fromSnapshot(DataSnapshot snapshot)
      : captainID = snapshot.value["Captain_ID"].toString(),
        lat = snapshot.value["Latitude"].toString(),
        long = snapshot.value["Longitude"].toString(),
        captainName = snapshot.value["Captain's_Name"].toString(),
        captainMobileNo = snapshot.value["Captain's_Mobile_No"].toString(),
        vehicleID = snapshot.value["Vehicle_ID"].toString(),
        otherInfo = snapshot.value["Vehicle_Model_Color"].toString();

  toJson() {
    return {
      "Captain_ID": captainID,
      "Latitude": lat,
      "Longitude": long,
      "Captain's_Name": captainName,
      "Vehicle_ID": vehicleID,
      "Vehicle_Model_Color": otherInfo,
    };
  }
}
