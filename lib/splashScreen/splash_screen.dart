import 'dart:async';
import 'package:riders_app/authentication/login_screen.dart';
import 'package:riders_app/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer(){
     fAuth.currentUser !=null?AssistantMethods.readCurrentOnlineUserInfo():null;
    Timer(const Duration(seconds: 3),()async{
      if(fAuth.currentUser !=null){
        currentFirebaseUser=fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      }else {
        // Send user to main screen
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });// Timer
  }
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.green,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Image.asset("images/codethreebrand.jpg"),
              const SizedBox(height: 10),
              const Text("Code Three Taxi Sharing App",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ))
            ],
          ),
        ),
      ),
    );
  }
}
