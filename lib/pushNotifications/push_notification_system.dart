import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging=FirebaseMessaging.instance;
  Future initializeCloudMessaging()async{
  // 1). Terminated
    // When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage()
    .then((RemoteMessage? remoteMessage) {
        if(remoteMessage !=null){
            // Display user information who has requested a ride

        }
    });
    // 2). Foreground
    // When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {

    });
    // 3). Background
    // When the app is in the background and app opens directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {

    });
  }
  // Future<String> generateAndGetToken()async{
  //   String? registrationToken=await messaging.getToken();
  //
  // }
}