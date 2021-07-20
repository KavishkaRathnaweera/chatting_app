import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.screenId,
      routes: {
        WelcomeScreen.screenId: (context) => WelcomeScreen(),
        LoginScreen.screenId: (context) => LoginScreen(),
        RegistrationScreen.screenId: (context) => RegistrationScreen(),
        ChatScreen.screenId: (context) => ChatScreen(),
      },
    );
  }
}
