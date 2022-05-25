import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riders_app/assistants/assistant_methods.dart';
import 'package:riders_app/global/global.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class SelectNearestActiveDriversScreen extends StatefulWidget {
  DatabaseReference? referenceRideRequest;
  SelectNearestActiveDriversScreen({this.referenceRideRequest});
  @override
  State<SelectNearestActiveDriversScreen> createState() => _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState extends State<SelectNearestActiveDriversScreen> {
  String fareAmount="";
  getFareAmountAccordingToVehicleType(int index){
    if(tripDirectionDetailsInfo !=null){
      if(dList[index]["car_details"]["type"].toString()=="Normal"){
        fareAmount=(AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString();
    }else if(dList[index]["car_details"]["type"].toString()=="MiniVas"){
        fareAmount=(AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)*1.5).toStringAsFixed(1);
      }else if(dList[index]["car_details"]["type"].toString()=="Motor Bicycle"){
        fareAmount=(AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)/2).toStringAsFixed(1);
      }
      else if(dList[index]["car_details"]["type"].toString()=="Luxury"){
        fareAmount=(AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)*2).toStringAsFixed(1);
      }
    }
    return fareAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: const Text("Nearest Online Drivers",
        style: TextStyle(
          fontSize: 18
        ),
        ),
        leading: IconButton(
          icon:const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: (){
            // delete/remove the ride request to the database
           widget.referenceRideRequest!.remove();
           Fluttertoast.showToast(msg: "You have cancelled the ride request");
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
          itemCount: dList.length,
          itemBuilder: (BuildContext context,int index)
          {
            return  GestureDetector(
              onTap: (){
                setState(() {
                  chosenDriverId= dList[index]["id"].toString();
                });
               Navigator.pop(context,"driverChoosed");
              },
              child: Card(
                color: Colors.grey,
                elevation: 3,
                shadowColor: Colors.green,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Image.asset(
                      (dList[index]["car_details"]["type"].toString()=="Normal")?"images/uber-go.png":"images/uber-x.png",
                      width:70 ,
                    ),
                  ),
                  title: Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          dList[index]["name"].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54
                        ),
                      ),
                      Text(
                          dList[index]["car_details"]["car_model"].toString(),
                        style:const TextStyle(
                            fontSize: 12,
                            color: Colors.white54
                        ),
                      ),
                      SmoothStarRating(
                        rating: 3.5,
                        color: Colors.black,
                        borderColor: Colors.black,
                        allowHalfRating: true,
                        starCount: 5,
                        size: 15,
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Text(
                        getFareAmountAccordingToVehicleType(index)+" ETB",
                        style:const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        tripDirectionDetailsInfo !=null?tripDirectionDetailsInfo!.duration_text!:"",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 12
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        tripDirectionDetailsInfo !=null?tripDirectionDetailsInfo!.distance_text!:"",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
