import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AboutScreen extends StatefulWidget {


  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: ListView(
       children: [
         Container(
           height: 230,
           child: Center(
             child: Image.asset("images/car_logo.png",
             width: 260,),
           ),
         ),
         Column(
           children:  [
             const Text("Code Three Taxi Sharing App",
             style: TextStyle(
               fontSize: 28,
               color: Colors.black,
               fontWeight: FontWeight.bold
             ),),
             const Text("Power By Girum Technologies, "
               "This is the first Ethiopian made ride sharing app",
               textAlign: TextAlign.center,
               style: TextStyle(
                   fontSize: 16,
                   color: Colors.black,
                   fontWeight: FontWeight.bold
               ),),
             const SizedBox(height: 40,),
             ElevatedButton(
                 style: ElevatedButton.styleFrom(
                     primary: Colors.black
                 ),
                 onPressed: (){
                   SystemNavigator.pop();
                 },
                 child: const Text("Close",
                   style: TextStyle(
                       color: Colors.white
                   ),))
           ],
         )
       ],
      ),
    );
  }
}
