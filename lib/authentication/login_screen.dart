import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:riders_app/authentication/registration_screen.dart';
import 'package:riders_app/infoHandler/app_info.dart';
import 'package:riders_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../generated/l10n.dart';
import '../global/global.dart';
import '../widget/progress_dialog.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController passwordTextEditingController=TextEditingController();
  validateUserInput(){
    if(emailTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Email can not be Empty");
    }
    else if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Invalid Email");
    }else if(passwordTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Password can not be Empty");
    }  else{
      loginUser();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(height: 10,),
               Text(S.of(context).loginAsAUser,style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
              )),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                // Validate user input
                validateUserInput();
                // Verify and logging user to Firebase
                //Navigator.push(context, MaterialPageRoute(builder: (c)=>const MainScreen()));
              },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreenAccent
                  ),
                  child:
                  const Text("Login",style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18
                  ),)
              ),
              const SizedBox(height: 20,),
              TextButton(
                  onPressed: (){
                // Save User Data to Firebase
                Navigator.push(context, MaterialPageRoute(builder: (c)=>const RegistrationScreen()));
              },
                  child:
                  const Text("Didn't have an account? Register Now",style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18
                  ),)
              ),
              const SizedBox(height: 20,),
              ToggleSwitch(
                activeBgColor: const [Colors.green,Colors.green],
                inactiveBgColor: Colors.grey,
                initialLabelIndex: Provider.of<AppInfo>(context,listen: false).currentLocal==Locale("am")?0:1,
                totalSwitches: 2,
                labels: [S.of(context).languageAmharic, S.of(context).languageEnglish],
                onToggle: (index) {
                  if(index ==0){
                    Provider.of<AppInfo>(context,listen: false).changeLanguagePreference("am");
                  }else{
                    Provider.of<AppInfo>(context,listen: false).changeLanguagePreference("en");
                  }
                },
              ),
            ],
          ),
        )
      ),
    );
  }

  void loginUser() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Processing Please wait..");
        });
    final User? firebaseUser=( await fAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim())
        .catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error"+msg.toString());
    })
  ).user;
    if(firebaseUser!=null){

      DatabaseReference usersRef=FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).once().then((driverKey){
        final snap=driverKey.snapshot;
        if(snap.value!=null){
          currentFirebaseUser=firebaseUser;
          Fluttertoast.showToast(msg: "Logged in Successfully");
          Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
        }else{
          Fluttertoast.showToast(msg: "No record exists with this email");
          fAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
        }
      });


    }else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occurred during  sign in");
    }
    }
}
