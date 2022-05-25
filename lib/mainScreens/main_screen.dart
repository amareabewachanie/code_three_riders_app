import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:riders_app/assistants/assistant_methods.dart';
import 'package:riders_app/assistants/geofire_assistant.dart';
import 'package:riders_app/global/global.dart';
import 'package:riders_app/infoHandler/app_info.dart';
import 'package:riders_app/mainScreens/rate_driver_screen.dart';
import 'package:riders_app/mainScreens/search_places_screen.dart';
import 'package:riders_app/mainScreens/select_nearest_online_drivers.dart';
import 'package:riders_app/models/active_neraby_drivers.dart';
import 'package:riders_app/widget/my_drawer.dart';
import 'package:riders_app/widget/pay_fare_amount__dialog.dart';
import 'package:riders_app/widget/progress_dialog.dart';

import '../generated/l10n.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controllerGoogleMap=Completer();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> skey=GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight=220.0;
  double waitingResponseFromDriverContainerHeight=0.0;
  double assignedDriverInfoContainerHeight=0.0;

  Position? userCurrentPosition;
  var geoLocator=Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap=0;
  List<LatLng> pLineCoordinatesList=[];
  Set<Polyline> polyLineSet={};
  Set<Marker> markerSet={};
  Set<Circle> circleSet={};
  String userName="User Name";
  String userEmail="User Email";
  bool openNavigationDrawer=true;
  bool activeNearByDriverKeysLoaded=false;

  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList=[];
  DatabaseReference? referenceRideRequest;
  String driverRideStatus="Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus="";
  bool requestPositionInfo=true;


  blackThemedGoogleMap(){
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfLocationPermissionIsAllowed() async{
   _locationPermission=await Geolocator.requestPermission();
   if(_locationPermission==LocationPermission.denied){
     _locationPermission=await Geolocator.requestPermission();
   }
  }
  locateUserPosition()async{
   Position cPosition= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   userCurrentPosition=cPosition;
   LatLng latLngPosition=LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
   CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 14);
   newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
   String humanReadableAddress=await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition!,context);
   userName=userModelCurrentInfo!.name!;
   userEmail=userModelCurrentInfo!.email!;
   initializeGeoFireListener();
   AssistantMethods.readTripKeysForOnlineUser(context);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionIsAllowed();
  }
  saveRideRequestInfo(){
    //1. Save the ride request information
    referenceRideRequest=FirebaseDatabase.instance.ref()
    .child("All Ride Requests").push();

    var originLocation=Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationLocation=Provider.of<AppInfo>(context,listen: false).userDropOffLocation;
    Map originLocationMap={
      "Latitude":originLocation!.locationLatitude!.toString(),
      "Longitude":originLocation.locationLongitude!.toString(),
    };
    Map destinationLocationMap={
      "Latitude":destinationLocation!.locationLatitude!.toString(),
      "Longitude":destinationLocation.locationLongitude!.toString(),
    };
    Map userInformationMap={
      "origin":originLocationMap,
      "destination":destinationLocationMap,
      "time":DateTime.now().toString(),
      "userName":userModelCurrentInfo!.name,
      "userPhone":userModelCurrentInfo!.phone,
      "originAddress":originLocation.locationName,
      "destinationAddress":destinationLocation.locationName,
      "driverId":"waiting"
    };
    referenceRideRequest!.set(userInformationMap);
    tripRideRequestInfoStreamSubscription= referenceRideRequest!.onValue.listen((eventSnap) async{
      if(eventSnap.snapshot.value ==null){
        return;
      }
      if((eventSnap.snapshot.value as Map)["car_details"] !=null){
        setState(() {
          driverCarDetails=(eventSnap.snapshot.value as Map)["car_details"]["car_color"].toString()+" "+(eventSnap.snapshot.value as Map)["car_details"]["car_model"].toString()
              +" "+"Plate Number: "+(eventSnap.snapshot.value as Map)["car_details"]["car_number"].toString();
        });
      }
      if((eventSnap.snapshot.value as Map)["driverPhone"] !=null){

        setState(() {
          driverPhone=(eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if((eventSnap.snapshot.value as Map)["driverName"] !=null){

        setState(() {
          driverName=(eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }
      if((eventSnap.snapshot.value as Map)["status"] !=null){
          userRideRequestStatus=(eventSnap.snapshot.value as Map)["status"].toString();
      }
      if((eventSnap.snapshot.value as Map)["driverLocation"] !=null){
        double driverCurrentPositionLat=double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng=double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());
        LatLng driverCurrentPositionLatLng=LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
        //
        // Driver is coming
       if(userRideRequestStatus=="accepted"){
            updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
       }
        // Driver is arrived
        if(userRideRequestStatus=="arrived"){
        setState(() {
          driverRideStatus="Driver has arrived";
        });
        }
        // status is ontrip
        if(userRideRequestStatus=="ontrip"){
          updateReachingTimeToUserDestinationLocation(driverCurrentPositionLatLng);
        }
        // status is ontrip
        if(userRideRequestStatus=="ended"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] !=null){
            double fareAmount=double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());
            var response=await showDialog(context: context,
                barrierDismissible: false,
                builder: (BuildContext c)=>PayFareAmountDialog(
                  fareAmount: fareAmount,
                ));
            if(response =="cashPayed"){
              // User can rate the driver now
              if((eventSnap.snapshot.value as Map)["driverId"] !=null){
                String assignedDriverId= (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (C)=>RateDriverScreen(
                    assignedDriverId:assignedDriverId
                )));
                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearByAvailableDriversList= GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }
  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async{
    if(requestPositionInfo ==true){

      requestPositionInfo=false;

        LatLng userPickupPosition=LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
        var directionDetailsInfo=await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            driverCurrentPositionLatLng, userPickupPosition);
        if(directionDetailsInfo ==null){
          return;
        }
        setState(() {
          driverRideStatus="Driver is coming :: "+directionDetailsInfo.duration_text.toString();
        });
        requestPositionInfo=true;
    }
  }
  updateReachingTimeToUserDestinationLocation(driverCurrentPositionLatLng) async{
    if(requestPositionInfo ==true){

      requestPositionInfo=false;
      var dropOffLocation=Provider.of<AppInfo>(context,listen: false).userDropOffLocation;
      LatLng userDestinationPosition=LatLng(dropOffLocation!.locationLatitude!,dropOffLocation.locationLongitude!);
      var directionDetailsInfo=await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userDestinationPosition);
      if(directionDetailsInfo ==null){
        return;
      }
      setState(() {
        driverRideStatus="Going towards destination :: "+directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo=true;
    }
  }
  searchNearestOnlineDrivers()async{
    if(onlineNearByAvailableDriversList.isEmpty){
      // Cancel/Delete Ride Request
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatesList.clear();
      });
      Fluttertoast.showToast(msg: "No online nearest driver available, Search again after a while.");
      Future.delayed(const Duration(milliseconds: 4000),(){
        SystemNavigator.pop();
      });
      return;
    }
    await retrieveOnlineDriversInfo(onlineNearByAvailableDriversList);
   var response=await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriversScreen( referenceRideRequest:referenceRideRequest)));

   if(response =="driverChoosed"){
     FirebaseDatabase.instance.ref().child("drivers")
         .child(chosenDriverId)
         .once()
         .then((snap){
          if(snap.snapshot.value !=null){
            // Send Notification to specific driver
            sendNotificationToDriverNow(chosenDriverId);
            // Response from a driver
           //Display  Waiting response from driver  UI
            showWaitingResponseFromDriverUI();

            FirebaseDatabase.instance.ref().child("drivers")
            .child(chosenDriverId).child("newRideStatus")
            .onValue.listen((eventSnapshot) {
            // 1). Driver can cancel the ride request :: push notification
              if(eventSnapshot.snapshot.value =="idle"){
                Fluttertoast.showToast(msg: "The driver has cancelled your request, please choose another one");
                Future.delayed(const Duration(milliseconds: 3000),(){
                  Fluttertoast.showToast(msg: "Restart App now");
                  SystemNavigator.pop();
                });
              }
              // 2). Driver can accept the ride request :: push notification
              if(eventSnapshot.snapshot.value =="accepted"){
                showUiForAssignedDriverInfo();
              }
            });

          }else{
            Fluttertoast.showToast(msg: "This driver do not exist, please try others!");
          }
     });
   }
  }
  showUiForAssignedDriverInfo(){
    setState(() {
      searchLocationContainerHeight=0.0;
      waitingResponseFromDriverContainerHeight=0.0;
      assignedDriverInfoContainerHeight=240.0;
    });
  }
  showWaitingResponseFromDriverUI(){
    setState(() {
      searchLocationContainerHeight=0.0;
      waitingResponseFromDriverContainerHeight=220.0;
    });
  }
  sendNotificationToDriverNow(String chosenDriverId){
    // Assign ride request id to newRideStatus
    FirebaseDatabase.instance.ref().child("drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);
    // Automate the push notification

    FirebaseDatabase.instance.ref().child("drivers")
        .child(chosenDriverId).child("token").once().then((snap){
          if(snap.snapshot.value !=null){
            String deviceRegistrationToken=snap.snapshot.value.toString();
             AssistantMethods.sendNotificationToDriver(deviceRegistrationToken, context,
                referenceRideRequest!.key.toString());
            Fluttertoast.showToast(msg: "Notification has been send to the nearest driver");
          }else{
            Fluttertoast.showToast(msg: "Please choose another driver, his phone is not recognizable");
            return;
          }

    });

  }
  //. TODO WE NEED TO FETCH THE RIGHT DRIVER SELECTED NOT THE LIST/ REFACTORE
  retrieveOnlineDriversInfo(List onlineNearestDriversList)async{
    DatabaseReference ref=FirebaseDatabase.instance.ref()
        .child("drivers");
    for(int i=0;i<onlineNearestDriversList.length;i++){
      await ref.child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot){
            var driverKeyInfo=dataSnapshot.snapshot.value;
            dList.add(driverKeyInfo);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    createActiveNearbyDriverIconMarker();
    return Scaffold(
      key: skey,
      drawer: SizedBox(
        width: 300,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.green),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children:  [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController=controller;
              // for black theme google map
              blackThemedGoogleMap();
              setState(() {
                bottomPaddingOfMap=240;
              });
              locateUserPosition();
            },
          ),
          // Custom Hamburger button for drawer
          Positioned(
              top: 36,
              left: 22,
              child: GestureDetector(
                onTap: (){
                  if(openNavigationDrawer){
                    skey.currentState!.openDrawer();
                  }else{
                    //restart-refresh-minimize app programmatically
                    SystemNavigator.pop();
                  }

                },
                child:  CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(
                   openNavigationDrawer?Icons.menu:Icons.close,
                    color: Colors.black54,),
                ),
              )
          ),
          // UI for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration:const Duration(microseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration:const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 18.0),
                  child: Column(
                    children: [
                      // From
                      Row(
                        children:  [
                         const Icon(Icons.add_location_alt,color: Colors.black),
                          const SizedBox(width: 12.0,),
                          Column(
crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(S.of(context).from,
                                style: const TextStyle(color: Colors.black,fontSize: 12),),
                              Text(Provider.of<AppInfo>(context).userPickUpLocation!=null?(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!):"Not Getting Your Current location",
                                style: const TextStyle(color: Colors.black,fontSize: 14,
                                    overflow: TextOverflow.ellipsis),),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Divider(height: 1,thickness: 1,color: Colors.black,),
                      const SizedBox(height: 16,),
                      // To
                      GestureDetector(
                        onTap: ()async{
                          // Goto search places screen
                          var responseFromSearchScreen=await Navigator.push(context, MaterialPageRoute(builder: (c)=>const SearchPlacesScreen()));
                          if(responseFromSearchScreen=="obtainedDropOff"){
                            setState(() {
                              openNavigationDrawer=false;
                            });
                              // Show Route --- Draw Polyline
                              await drawPolyLineFromSourceToDestination();
                          }
                        },
                        child: Row(
                          children:  [
                            const Icon(Icons.add_location_alt,color: Colors.black),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text(S.of(context).to,
                                  style: const TextStyle(color: Colors.black,fontSize: 12),),
                                Text(Provider.of<AppInfo>(context).userDropOffLocation !=null?(Provider.of<AppInfo>(context).userDropOffLocation!.locationName!):"Where Do you want to go?",
                                  style: const TextStyle(color: Colors.black,fontSize: 14,
                                  overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Divider(height: 1,thickness: 1,color: Colors.black,),
                      const SizedBox(height: 16,),
                      ElevatedButton(
                          onPressed: (){
                              if(Provider.of<AppInfo>(context,listen: false).userDropOffLocation !=null){
                                saveRideRequestInfo();
                              }else{
                                Fluttertoast.showToast(msg: "Please Tell Us Where Do You Want to go!");
                              }
                          },
                          child:  Text(S.of(context).requestARide),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black12,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      )
                    ],
                  ),
                ),

              ),
            ),
          ),
          // UI for waiting response from driver
          Positioned(
            bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                 decoration:const BoxDecoration(
                   color: Colors.black87,
                   borderRadius: BorderRadius.only(
                     topRight: Radius.circular(20),
                     topLeft: Radius.circular(20)
                   )
                 ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText("Waiting for response\nfrom drivers.",
                        duration:const Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        )
                        ),
                        FadeAnimatedText("Please wait...",
                            duration:const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          fontFamily: 'Canterbury'
                        )
                        )
                      ],
                    ),
                  ),
                ),
              ) ),
          // UI for displaying assigned driver info
          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Container(
              height: assignedDriverInfoContainerHeight,
                decoration:const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status of the ride
                        Center(
                          child: Text(driverRideStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:Colors.white54
                          ),
                          ),
                        ),
                      const SizedBox(height: 20.0,),
                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20.0,),
                      // Vehicle Details of the driver
                     Text(driverCarDetails,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:Colors.white54
                        ),
                      ),
                      const SizedBox(height: 2.0,),
                      // Driver name and Call Driver button
                        Text(driverName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:Colors.white54
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      const Divider(
                        color: Colors.green,
                        thickness: 2,
                        height: 2,
                      ),
                      const SizedBox(height: 20.0,),
                      Center(
                        child: ElevatedButton.icon(onPressed: (){

                        },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green
                            ),
                            icon: const Icon(Icons.phone_android,color: Colors.black54,size: 22,),
                            label: const Text("Call to driver",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold
                            ),)),
                      )
                    ],
                  ),
                ),
          ))
        ],
      )

    );
  }
  Future<void> drawPolyLineFromSourceToDestination() async{
    var sourcePosition=Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationPosition=Provider.of<AppInfo>(context,listen: false).userDropOffLocation;
    var sourceLatLng=LatLng(sourcePosition!.locationLatitude!, sourcePosition.locationLongitude!);
    var destnLatLng=LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);
    showDialog(context:context, builder: (BuildContext context)=>ProgressDialog(
      message: "Fetching Direction Details",
    ));
    var directionDetailsInfo= await AssistantMethods.obtainOriginToDestinationDirectionDetails(sourceLatLng, destnLatLng);
    setState(() {
      tripDirectionDetailsInfo=directionDetailsInfo;
    });
    Navigator.pop(context);
    PolylinePoints  pPoints=PolylinePoints();
    List<PointLatLng> decodedPPointsResultList=pPoints.decodePolyline(directionDetailsInfo!.e_points!);
    pLineCoordinatesList.clear();
    if(decodedPPointsResultList.isNotEmpty){
    decodedPPointsResultList.forEach((PointLatLng pointLatLng) {
      pLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline= Polyline(
        color: Colors.purpleAccent,
        polylineId:const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline);
    });
   LatLngBounds boundsLatLng;
   if(sourceLatLng.latitude>destnLatLng.latitude && sourceLatLng.longitude>destnLatLng.longitude){
     boundsLatLng=LatLngBounds(southwest: destnLatLng,northeast: sourceLatLng);
   }else if(sourceLatLng.longitude>destnLatLng.longitude){
     boundsLatLng=LatLngBounds(
         southwest: LatLng(sourceLatLng.latitude,destnLatLng.longitude),
         northeast: LatLng(destnLatLng.latitude,sourceLatLng.longitude));
   }
   else if(sourceLatLng.latitude>destnLatLng.latitude){
     boundsLatLng=LatLngBounds(
         southwest: LatLng(destnLatLng.latitude,sourceLatLng.longitude),
         northeast: LatLng(sourceLatLng.latitude,destnLatLng.longitude));
   }else{
     boundsLatLng=LatLngBounds(
         southwest: sourceLatLng,
         northeast: destnLatLng);
   }
 newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng,65));
   Marker originMarker=Marker(markerId: const MarkerId("originID"),
   infoWindow: InfoWindow(title: sourcePosition.locationName,snippet: "Initial"),
     position:sourceLatLng,
     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)
   );
    Marker destinationMarker=Marker(markerId: const MarkerId("destinationID"),
        infoWindow: InfoWindow(title: destinationPosition.locationName,snippet: "Destination"),
        position:destnLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle= Circle(circleId:const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng
    );
    Circle destinationCircle= Circle(circleId:const CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destnLatLng
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }
  initializeGeoFireListener(){
    Geofire.initialize("activeDrivers");
     Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
         .listen((map) {
          if(map !=null){
            var callBack=map["callBack"];
            switch(callBack){
              case Geofire.onKeyEntered: // The driver gets online and lets add to the list
                 ActiveNearbyAvailableDrivers nearbyAvailableDriver=ActiveNearbyAvailableDrivers();
                 nearbyAvailableDriver.driverId=map["key"];
                 nearbyAvailableDriver.locationLatitude=map["latitude"];
                 nearbyAvailableDriver.locationLongitude=map["longitude"];
                 GeoFireAssistant.activeNearbyAvailableDriversList.add(nearbyAvailableDriver);
                 if(activeNearByDriverKeysLoaded ==true){
                   displayActiveDriversOnUserMap();
                 }
                break;

              case Geofire.onKeyExited: // The driver become offline and let we remove it from the list
                  GeoFireAssistant.deleteOfflineDriversFromList(map["key"]);
                  displayActiveDriversOnUserMap();
                break;
              case Geofire.onKeyMoved: // The driver has moved and let update the drivers location
                  ActiveNearbyAvailableDrivers movedAvailableDriver=ActiveNearbyAvailableDrivers();
                  movedAvailableDriver.driverId=map["key"];
                  movedAvailableDriver.locationLatitude=map["latitude"];
                  movedAvailableDriver.locationLongitude=map["longitude"];
                  GeoFireAssistant.updateActiveNearbyAvailableDriversList(movedAvailableDriver);
                  displayActiveDriversOnUserMap();
                break;
              case Geofire.onGeoQueryReady:// Display those online drivers on users map
                  activeNearByDriverKeysLoaded=true;
                  displayActiveDriversOnUserMap();
                break;

            }
          }
     });
  }
  displayActiveDriversOnUserMap(){
    setState(() {
      markerSet.clear();
      circleSet.clear();
      Set<Marker> driversMarkerSet=Set<Marker>();
      for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList){
        LatLng eachDriverLatLng=LatLng(eachDriver.locationLatitude!,eachDriver.locationLongitude!);
        Marker eachDriverMarker=Marker(
            markerId:MarkerId(eachDriver.driverId!),
            position: eachDriverLatLng,
            icon: activeNearbyIcon!,
           rotation: 360
        );
        driversMarkerSet.add(eachDriverMarker);
      }
      setState(() {
        markerSet=driversMarkerSet;
      });
    });
  }
  createActiveNearbyDriverIconMarker(){
   if(activeNearbyIcon ==null){
     ImageConfiguration imageConfiguration=createLocalImageConfiguration
       (context,
         size: const Size(2.0, 2.0)
     );
     BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
       activeNearbyIcon=value;
     });
   }
  }
}
