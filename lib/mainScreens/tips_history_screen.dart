import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:riders_app/infoHandler/app_info.dart';
import 'package:riders_app/widget/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {


  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title:const Text("Trips History",),
        leading: IconButton(
          icon:const Icon(Icons.close),
          onPressed: (){
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.separated(
      separatorBuilder: (context,i)=>const Divider(
        color: Colors.green,
        thickness: 2,
        height: 2,
      ),
      itemBuilder: (context,int i){
return HistoryDesignUiWidget(tripsHistoryModel: Provider.of<AppInfo>(context,listen: false).listOfTripHistories[i]);
      },
      itemCount: Provider.of<AppInfo>(context,listen: false).listOfTripHistories.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
