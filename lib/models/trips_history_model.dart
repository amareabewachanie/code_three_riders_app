import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;
  TripsHistoryModel({this.driverName,this.destinationAddress,
    this.originAddress,this.fareAmount,
    this.car_details,this.status,this.time});
  TripsHistoryModel.fromSnapShot(DataSnapshot snapshot){
    time=(snapshot.value as Map)["time"];
    originAddress=(snapshot.value as Map)["originAddress"];
    destinationAddress=(snapshot.value as Map)["destinationAddress"];
    status=(snapshot.value as Map)["status"];
    fareAmount=(snapshot.value as Map)["fareAmount"];
    driverName=(snapshot.value as Map)["driverName"];
    car_details=(snapshot.value as Map)["car_details"]["car_color"]+" "+
        (snapshot.value as Map)["car_details"]["car_model"]+" Plate Number:"+
        (snapshot.value as Map)["car_details"]["car_number"];
  }
}