import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riders_app/assistants/request_assistant.dart';
import 'package:riders_app/models/predicted_places.dart';

import '../config/configMaps.dart';
import '../widget/place_prediction_tile.dart';
class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placePredictionsList=[];
  void findPlaceAutoCompleteSearch(String inputText) async{
    if(inputText.length>1){
      String urlAutoCompleteSearch="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:ET";
      var responseAutoCompleteSearch=await RequestAssistant.recieveRequest(urlAutoCompleteSearch);
      if(responseAutoCompleteSearch == "Error Occurred, Failed. No Response"){
        return;
      }
      if(responseAutoCompleteSearch["status"]=="OK"){
        var placePredictions=responseAutoCompleteSearch["predictions"];
         var placePredictionsListTemp=(placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();
        setState(() {
          placePredictionsList=placePredictionsListTemp;
        });

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search place UI
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7)
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  Stack(
                    children:  [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                          child:
                          const Icon(Icons.arrow_back, color: Colors.black,)),
                      const  Center(
                        child:  Text(
                          "Search & Set Destination Location",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    children:  [
                      const Icon(Icons.adjust_sharp, color: Colors.black,),
                      const SizedBox(width: 18,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped){
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: const InputDecoration(
                              hintText: "Search here....",
                              hintStyle: TextStyle(
                                color: Colors.black
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 11.0,top: 8.0,bottom: 8.0)
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Display Place Predictions
          (placePredictionsList.isNotEmpty)?
              Expanded(
                  child:ListView.separated(
                    physics: const ClampingScrollPhysics(),
                      itemBuilder: (context,index){
                      return PredictionPlacesTile(predictedPlaces:  placePredictionsList[index]);
                      },
                      separatorBuilder: (BuildContext context,int index){
                      return const Divider(
                        height: 1,
                        color: Colors.black,
                        thickness: 1,
                      );

                      },
                      itemCount: placePredictionsList.length
                  )

              )
              :Container(),
        ],
      ),
    );
  }
}
