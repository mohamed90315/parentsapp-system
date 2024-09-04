import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:parentsapp/main.dart';
import 'package:parentsapp/screens/notification_screen.dart';

class FirebaseNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNoifications() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print("Token: $token");
    handleBackgroundNotification();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState
        ?.pushNamed(NotificationScreen.routeName, arguments: message);
  }

  void handleBackgroundNotification() {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
