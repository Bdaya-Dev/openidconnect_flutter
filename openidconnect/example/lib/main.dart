import 'package:flutter/material.dart';
import 'package:openidconnect_example/choose.dart';

void main() {
  runApp(MyApp());
}

//Credentials gathered from the playground
//login: dull-moth@example.com
//password: Yawning-Octopus-58

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChoosePage(),
    );
  }
}
