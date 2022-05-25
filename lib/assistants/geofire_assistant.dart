import 'package:riders_app/models/active_neraby_drivers.dart';

class GeoFireAssistant{
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList=[];
  static void deleteOfflineDriversFromList(String driverId){
    int indexNumber=activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId==driverId);
    activeNearbyAvailableDriversList.removeAt(indexNumber);
  }
  static void updateActiveNearbyAvailableDriversList(ActiveNearbyAvailableDrivers movedDriver){
   int indexNumber=activeNearbyAvailableDriversList.indexWhere((element) => element.driverId==movedDriver.driverId);
   activeNearbyAvailableDriversList[indexNumber].locationLongitude=movedDriver.locationLongitude;
   activeNearbyAvailableDriversList[indexNumber].locationLatitude=movedDriver.locationLatitude;
  }
}