import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knu_app/screens/Widgets/personal_page.dart';
import 'package:knu_app/screens/Widgets/student.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  int index=0;
  List<Widget> Widgets=[StudentPage('_userData'),UserProfilePage('userData')];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Widgets[index],
        bottomNavigationBar: NavigationBarTheme(

          data: NavigationBarThemeData(
              backgroundColor: Colors.white30,
              indicatorColor: Colors.blueGrey,
              labelTextStyle: MaterialStateProperty.all(
                  TextStyle(fontWeight: FontWeight.w400))),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              setState(() {
                index = i;
              });
            },
            destinations: [
              NavigationDestination(
                  icon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],

          ),
        )
    );
  }
}
