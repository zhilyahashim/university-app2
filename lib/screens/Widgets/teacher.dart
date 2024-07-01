import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:knu_app/screens/Widgets/personal_page.dart';
import 'package:knu_app/screens/Widgets/putMarks.dart';
import 'package:http/http.dart' as http;
import 'package:knu_app/screens/Widgets/studentMarks.dart';
import 'package:knu_app/screens/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'getTimetable.dart';

class TeacherPage extends StatefulWidget {
  final String token;

  TeacherPage(this.token);
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage>     with SingleTickerProviderStateMixin{
  late final AnimationController _controller= AnimationController(
    duration:const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<Offset> _offsetAnimation =Tween<Offset>(
    begin: Offset.zero,
    end:const Offset(0,1.5),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  Future<void> _logout(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  }
  late SharedPreferences prefrences;
  bool isLoad=false;
  Future<void> _fetchUserData() async {
    setState(() {
      isLoad = true;
    });
    prefrences = await SharedPreferences.getInstance();
    setState(() {
      isLoad = false;
    });
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user/profile'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _userData = json.decode(response.body);

      });
    } else {
      // Handle error
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black12,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/dashboard.jpeg'),
                        fit: BoxFit.cover,
                        opacity: 0.7
                    ),
                    color: Colors.blueGrey),
                height: height * 0.25,
                width: width,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, right: 200),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Padding(padding: EdgeInsets.only(top: 40,left: 5),
                           child: InkWell(
                              onTap: () {
                                _scaffoldKey.currentState!.openDrawer();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 6,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.sort_rounded,
                                  size: 28,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),),
                            const SizedBox(width: 20,),
                            Padding(
                              padding: EdgeInsets.only(top: 40, left: 6),
                              child: Text(
                                'Teacher\n Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 80),
                        child: SlideTransition(position: _offsetAnimation,
                          child:Text(
                            'Welcome to the page',
                            style: TextStyle(color: Colors.white70,fontSize:10),
                          ),),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                height: height * 0.75,
                width: width,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30, right: 50),
                      child: Text(
                        'Here your dashboard',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage('userData'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20, left: 20, top: 30),
                        child: Container(
                          width: 450,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[200],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 8, left: 100),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_pin_rounded,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  'Personal Data',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  GetTimetable('timetable'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20, left: 20, top: 30),
                        child: Container(
                          width: 450,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 18, left: 100),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.table_chart,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  'Timetable',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PutMarks ('token'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20, left: 20, top: 30),
                        child: Container(
                          width: 450,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[200],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 18, left: 100),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.question_mark_rounded,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  'Put The Marks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer:Drawer(
        backgroundColor: Colors.blueGrey[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: _userData == null
                  ? Center(
                  child: CircularProgressIndicator())
                  :Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${prefrences.getString('name').toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    ListTile(
                      title: Text(prefrences.getString('email').toString()),
                    ),
      ],
    )
            ),

            ListTile(
              title: const Text('Dashboard'),
              leading: IconButton(
                icon: Icon(Icons.dashboard),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Personal Data'),
              leading: IconButton(
                icon: Icon(Icons.person_pin_rounded),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage('userData'),
                ),
              ),
            ),
            ListTile(
              title: const Text('Timetable'),
              leading: IconButton(
                icon: Icon(Icons.table_chart),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage('userData'),
                ),
              ),
            ),
            ListTile(
              title: const Text('Put The Mark'),
              leading: IconButton(
                icon: Icon(Icons.question_mark_rounded),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PutMarks('token'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 200),
              child: InkWell(
                onTap:()=>  _logout(context),
                child: Padding(
                  padding: EdgeInsets.only(top: 10, left: 40),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10,),
                      Text(
                        'LogOut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )

    );
  }
}
