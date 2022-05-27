import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:riders_app/assistants/request_assistant.dart';
import 'package:riders_app/config/configMaps.dart';
import 'package:riders_app/global/global.dart';
import 'package:riders_app/infoHandler/app_info.dart';
import 'package:riders_app/models/direction_details_info.dart';
import 'package:riders_app/models/directions.dart';
import 'package:riders_app/models/trips_history_model.dart';
import 'package:riders_app/models/user_model.dart';
import 'package:http/http.dart' as http;

class AssistantMethods{

  static Future<String> searchAddressForGeographicCoordinates(Position position,context) async{
    String apiUrl="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    String humanReadableAddress="";
    var requestResponse=await RequestAssistant.recieveRequest(apiUrl);
    if(requestResponse!="Error Occurred, Failed. No Response"){
     humanReadableAddress= requestResponse["results"][0]["formatted_address"];
     Directions userPickUpAddress=Directions();
     userPickUpAddress.locationLatitude=position.latitude;
     userPickUpAddress.locationLongitude=position.longitude;
     userPickUpAddress.locationName=humanReadableAddress;

     Provider.of<AppInfo>(context,listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
  return humanReadableAddress;
  }
  static void readCurrentOnlineUserInfo() async{
    currentFirebaseUser=fAuth.currentUser!;
    DatabaseReference userRef=FirebaseDatabase.instance.ref()
        .child("users").child(currentFirebaseUser!.uid);
    userRef.once().then((snap)  {
      if(snap.snapshot.value !=null){
        userModelCurrentInfo= UserModel.fromSnapShot(snap.snapshot);
      }
    });
  }
  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng origin, LatLng destination)async{
  String urlOriginToDestinationDirectionDetails="https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey";
  var responseDirectionApi= await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionDetails);
  if(responseDirectionApi=="Error Occurred, Failed. No Response"){
    return null;
  }
  DirectionDetailsInfo directionDetailsInfo=DirectionDetailsInfo();
  directionDetailsInfo.e_points= responseDirectionApi["routes"][0]["overview_polyline"]["points"];
  directionDetailsInfo.distance_text=responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
  directionDetailsInfo.distance_value=responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
  directionDetailsInfo.duration_text=responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
  directionDetailsInfo.duration_value=responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
  return directionDetailsInfo;
  }
  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double initialPrice=50;
    double timeTraveledFareAmountPerMinute=(directionDetailsInfo.duration_value! / 60)*10;
    double distanceTraveledFareAmountPerKilloMetter=(directionDetailsInfo.distance_value!/1000)*15;
    double totalFareAmount=initialPrice+timeTraveledFareAmountPerMinute+distanceTraveledFareAmountPerKilloMetter;
    return double.parse(totalFareAmount.toStringAsFixed(1));
  }
  static sendNotificationToDriver(String token,context, String ride_request_id) async{
   String destinationAddress=userDropOffAddress;
   print("Drope off location"+destinationAddress);
    Map<String,String> headerMap={
      "Content-Type": "application/json",
      "Authorization": serverToken,
    };
    Map bodyNotification={
      "body":"Destination Address:\n$destinationAddress",
      "title":"New Trip Request"
    };
    Map dataMap={
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId":ride_request_id
    };
    Map officialNotificationFormat={
      "notification":bodyNotification,
      "data":dataMap,
      "priority":"high",
      "to":token,
    };
    var res= http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerMap,
        body: jsonEncode(officialNotificationFormat));
  }

  // Retrive the trip KEYS for the online users
  // trp key= ride request id
static void readTripKeysForOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("userPhone")
        .equalTo(userModelCurrentInfo!.phone).once()
        .then((snap) {
          if(snap.snapshot.value !=null){
           Map tripKeys= snap.snapshot.value as Map;
           // share trip keys with providers;
            List<String> tripKeysList=[];
            tripKeys.forEach((key, value) {
              tripKeysList.add(key);
            });
            Provider.of<AppInfo>(context,listen: false).updateAllTripKeys(tripKeysList);

            //Trip keys data  - Obtain the complete information of the history
            readTripsHistoryInformation(context);
          }
    });
}
static void  readTripsHistoryInformation(context){
    var tripKeys=Provider.of<AppInfo>(context,listen: false).historyTripKeysList;
    for(String key in tripKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests")
          .child(key).once().then((snap) {
            if(snap.snapshot.value !=null){
              var tripHistory=TripsHistoryModel.fromSnapShot(snap.snapshot);
                if((snap.snapshot.value as Map)["status"] =="ended"){
                  // Update-add each trip to history data list
                  Provider.of<AppInfo>(context,listen: false).updateAllTripHistoryData(tripHistory);
              }
            }
      });
    }
}
}