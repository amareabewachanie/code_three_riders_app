import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riders_app/global/global.dart';
import 'package:riders_app/widget/profile_design_ui.dart';
class ProfileScreen extends StatefulWidget {


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the user name
            Text(userModelCurrentInfo!.name!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),
            const SizedBox(height: 38,),
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.phone!,
              iconData: Icons.phone_iphone,
            ),
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.email!,
              iconData: Icons.email,
            ),
        const SizedBox(height: 20,),
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
        ),
      ),
    );
  }
}
