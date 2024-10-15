import 'package:driverchofer/app.dart';
import 'package:driverchofer/pages/login.dart';
import 'package:driverchofer/pages/register.dart';
import 'package:driverchofer/pages/tripslista.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/trips': (context) => TripsScreen(),


      },
    );
  }
}