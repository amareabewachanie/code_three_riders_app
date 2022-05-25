import 'package:flutter/material.dart';
import 'package:riders_app/mainScreens/about_screen.dart';
import 'package:riders_app/mainScreens/profile_screen.dart';
import 'package:riders_app/mainScreens/tips_history_screen.dart';
import 'package:riders_app/splashScreen/splash_screen.dart';

import '../global/global.dart';
class MyDrawer extends StatefulWidget {
String? name;
String? email;
MyDrawer({Key? key, this.name,this.email}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: ListView(
        children: [
        // Drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black54
              ),
              child: Row(
                children:  [
                  const Icon(Icons.person,size: 80,color: Colors.white,),
                  const SizedBox(height: 16,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Text(widget.name.toString(),style:  const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),),
                      const SizedBox(height: 10,),
                      Text(widget.email.toString(),style:const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                      ),)
                    ],
                  )
                ],
              ),
            ),
          ),
          // Drawer body
           const SizedBox(height: 12,),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=>TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.polyline,color: Colors.white54,),
              title: Text("Trip History",style: TextStyle(
                color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.person,color: Colors.white54,),
              title: Text("Profile",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=>AboutScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.details,color: Colors.white54,),
              title: Text("About",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: const ListTile(
              leading: Icon(Icons.note,color: Colors.white54,),
              title: Text("Terms And Conditions",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: const ListTile(
              leading: Icon(Icons.wallet_giftcard,color: Colors.white54,),
              title: Text("Wallet Activity",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: const ListTile(
              leading: Icon(Icons.lock,color: Colors.white54,),
              title: Text("Lock Out",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
          GestureDetector(
            onTap: (){
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.logout,color: Colors.white54,),
              title: Text("Logout",style: TextStyle(
                  color:Colors.white54
              ),),
            ),
          ),
        ],
      ),
    );
  }
}
