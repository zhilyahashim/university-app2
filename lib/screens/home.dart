import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knu_app/screens/Widgets/profile.dart';

import 'auth/login.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override

  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:LoginPage(),

    );
  }
}

void main() {
  runApp(const HomePage());
}
