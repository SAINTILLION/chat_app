import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  //Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

runApp(
  ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  )
);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme myCustomTextTheme = Theme.of(context).textTheme.copyWith(
  // Define customizations for specific text styles
    displayMedium: const TextStyle(
      fontSize: 8.0,
      fontWeight: FontWeight.bold,
      color: Colors.black, // Example customization
    ),
    displaySmall: const TextStyle(
      fontSize: 8.0,
      fontWeight: FontWeight.w500,
      color: Colors.white,
));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: myCustomTextTheme
      ),
      home: const AuthGate(),
    );
  }
}
