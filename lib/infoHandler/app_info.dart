import 'package:flutter/material.dart';
import 'package:riders_app/models/trips_history_model.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
Directions? userPickUpLocation, userDropOffLocation;
Locale _currentLocal= Locale("am");
Locale get currentLocal => _currentLocal;
List<String> historyTripKeysList=[];
List<TripsHistoryModel> listOfTripHistories=[];

void updatePickUpLocationAddress(Directions userPickupAddress){
  userPickUpLocation=userPickupAddress;
  notifyListeners();
}
void updateDropOffLocationAddress(Directions userDropOffAddress){
  userDropOffLocation=userDropOffAddress;
  notifyListeners();
}
 changeLanguagePreference(String _locale){
  _currentLocal=Locale(_locale);
  notifyListeners();
}
 updateAllTripKeys(List<String> tripKeysList){
historyTripKeysList=tripKeysList;
notifyListeners();
}
 updateAllTripHistoryData(TripsHistoryModel tripHistories){
   listOfTripHistories.add(tripHistories);
   notifyListeners();
}
}