
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riders_app/assistants/request_assistant.dart';
import 'package:riders_app/config/configMaps.dart';
import 'package:riders_app/global/global.dart';
import 'package:riders_app/infoHandler/app_info.dart';
import 'package:riders_app/models/directions.dart';
import 'package:riders_app/models/predicted_places.dart';
import 'package:riders_app/widget/progress_dialog.dart';
class PredictionPlacesTile extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;
   PredictionPlacesTile({this.predictedPlaces});

  @override
  State<PredictionPlacesTile> createState() => _PredictionPlacesTileState();
}

class _PredictionPlacesTileState extends State<PredictionPlacesTile> {
  getPlaceDirectionDetails(String placeId, context)async{
     showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(
       message:"Setting Up destination location"
     ));
     String placeDirectionDetailsUrl="https://maps.googleapis.com/maps/api/place/details/json?&place_id=$placeId&key=$mapKey";
    var responseApi= await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if(responseApi== "Error Occurred, Failed. No Response"){
      return;
    }if(responseApi["status"]=="OK"){
      Directions directions=Directions();
      directions.locationId=placeId;
      directions.locationName=responseApi["result"]["name"];
      directions.locationLatitude=responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude=responseApi["result"]["geometry"]["location"]["lng"];
     Provider.of<AppInfo>(context,listen: false).updateDropOffLocationAddress(directions);
     setState(() {
       userDropOffAddress=directions.locationName!;
     });
     Navigator.pop(context,"obtainedDropOff");
     }

  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){
      getPlaceDirectionDetails(widget.predictedPlaces!.place_id!,context);
    },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children:  [
              const Icon(Icons.add_location,color: Colors.black,),
              const SizedBox(width: 14,),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0,),
                  Text(widget.predictedPlaces!.main_text!,overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,

                  )
                  ),
                  const SizedBox(height: 2.0,),
                  Text(widget.predictedPlaces!.secondary_text!,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12.0,
                    color: Colors.black
                  ),
                  )

                ],
              ))
            ],
          ),
        ));
  }
}

