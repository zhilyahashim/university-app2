import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knu_app/screens/Widgets/head.dart';
import 'package:knu_app/screens/Widgets/headInfo.dart';
import 'package:knu_app/screens/Widgets/personal_page.dart';
import 'package:knu_app/screens/Widgets/studentInfo.dart';
import 'package:knu_app/screens/Widgets/teacher.dart';
import 'package:knu_app/screens/Widgets/teacherInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin.dart';
import 'alluser.dart';
import 'package:http/http.dart' as http;

class AdminInfo extends StatefulWidget {
  final String token;

  AdminInfo(this.token);
  @override
  State<AdminInfo> createState() => _AdminInfoState();

}

 class _AdminInfoState extends State<AdminInfo>
    with SingleTickerProviderStateMixin{
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
  Future<void> _logout(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear(); // Clear user session data
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  }

  var height,width;
  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return
      Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white70,
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
                              children: [
                                Padding(padding: EdgeInsets.only(top: 40,left: 5),
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
                                const SizedBox(width: 15,),
                                Padding(
                                  padding: EdgeInsets.only(top: 40, ),
                                  child: Text(
                                    'Admin \n Dashboard',
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
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50),
                            topRight: Radius.circular(50))
                    ),
                    height:height*0.85,
                    width: width,
                    child:Column(
                      children: [
                        Padding(padding: EdgeInsets.only(top: 30,right: 20),
                          child:  Text('Here All The Dashboardes Of The System',style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),),),
                        Padding(padding: EdgeInsets.only(left: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:[
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder:
                                        (context) =>StudentInfo(),

                                    ));
                                  },
                                  child: Padding(padding: EdgeInsets.only(right: 20,top:
                                  60),
                                    child:Container(
                                        width:170,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: NetworkImage(''),
                                            fit: BoxFit.cover,

                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow:[BoxShadow(
                                            color: Colors.blueGrey,
                                            blurRadius: 3,
                                          ),

                                          ],
                                        ),  child:Padding(padding: EdgeInsets.only(top: 6,left: 4),
                                        child:Row(
                                            children: [
                                              Icon(
                                                Icons.library_books_outlined,
                                                color: Colors.blueGrey,),
                                              const SizedBox(width: 10,),
                                              Text('Student Page',style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,color: Colors.blueGrey),
                                              ),]))

                                    ),

                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder:
                                        (context) =>TeachearInfo(),

                                    ));
                                  },
                                  child: Padding(padding: EdgeInsets.only(right: 20,top:
                                  60),
                                      child:Container(
                                        width:170,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: NetworkImage(''),
                                            fit: BoxFit.cover,

                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow:[BoxShadow(
                                            color: Colors.blueGrey,
                                            blurRadius: 3,
                                          ),

                                          ],
                                        ),
                                        child:Padding(padding: EdgeInsets.only(top: 6,left: 4),
                                            child:Row(
                                                children: [
                                                  Icon(
                                                    Icons.perm_contact_cal,
                                                    color: Colors.blueGrey,),
                                                  const SizedBox(width: 10,),
                                                  Text('Teacher Page',style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,color: Colors.blueGrey),
                                                  ),])

                                        ),
                                      )
                                  ),
                                ),
                              ]),),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) =>HeadInfo(),

                            ));
                          },
                          child: Padding(padding: EdgeInsets.only(right: 20,top:
                          40),
                              child:Container(
                                width:170,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[200],
                                  image: DecorationImage(
                                    image: NetworkImage(''),
                                    fit: BoxFit.cover,

                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow:[BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 3,
                                  ),

                                  ],
                                ),child:
                              Padding(padding: EdgeInsets.only(top: 6,left: 10),
                                  child:Row(
                                      children: [
                                        Icon(
                                          Icons.perm_contact_calendar,
                                          color: Colors.black,),
                                        const SizedBox(width: 10,),
                                        Text('Head Page',style: TextStyle(fontWeight: FontWeight
                                            .bold,
                                            fontSize: 15,color: Colors.black),
                                        ),])

                              ),

                              )
                          ),
                        ),

                        const SizedBox(height: 20,),
                        Divider(),
                        InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder:
                                  (context) =>UserProfilePage('userData'),

                              ));
                            },
                            child: Padding(padding: EdgeInsets.only(right: 20,left: 20,top:
                            30),
                              child:Container(
                                width:450,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: NetworkImage(''),
                                    fit: BoxFit.cover,

                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow:[BoxShadow(
                                    color: Colors.blueGrey,
                                    blurRadius: 3,
                                  ),
                                  ],
                                ),child: Padding(padding: EdgeInsets.only(top: 18,left: 90),
                                child:Row(
                                    children: [
                                      Icon(
                                        Icons.person_pin_rounded,
                                        color: Colors.blueGrey,),
                                      const SizedBox(width: 10,),
                                      Text('Personal Data',style: TextStyle(fontWeight: FontWeight
                                          .bold,
                                          fontSize: 20,color: Colors.blueGrey),
                                      ),]),
                              ),
                              ),
                            )
                        ),
                        InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder:
                                  (context) =>DepartmentForm(),

                              ));
                            },
                            child: Padding(padding: EdgeInsets.only(right: 20,left: 20,top:
                            30),
                              child:Container(
                                  width:450,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    image: DecorationImage(
                                      image: NetworkImage(''),
                                      fit: BoxFit.cover,

                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow:[BoxShadow(

                                      color: Colors.black,
                                      blurRadius: 3,
                                    ),

                                    ],
                                  ),child: Padding(padding: EdgeInsets.only(top: 18,left: 80),
                                child:Row(
                                    children: [
                                      Icon(
                                        Icons.create,
                                        color: Colors.black,),
                                      const SizedBox(width: 10,),
                                      Text('Create The Departments',style: TextStyle(fontWeight: FontWeight
                                          .bold,
                                          fontSize: 15,color: Colors.black),
                                      ),]),
                              )

                              ),

                            )
                        ),
                        InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder:
                                  (context) =>UserListScreen(),

                              ));
                            },
                            child: Padding(padding: EdgeInsets.only(right: 20,left: 20,top:
                            30),
                              child:Container(
                                  width:450,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(''),
                                      fit: BoxFit.cover,

                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow:[BoxShadow(

                                      color: Colors.blueGrey,
                                      blurRadius: 3,
                                    ),

                                    ],
                                  ),child: Padding(padding: EdgeInsets.only(top: 15,left: 90),
                                  child:Row(
                                      children: [
                                        Icon(
                                          Icons.people_alt_outlined,
                                          color: Colors.blueGrey,),
                                        const SizedBox(width: 10,),
                                        Text('See the Users',style: TextStyle(fontWeight: FontWeight
                                            .bold,
                                            fontSize: 20,color: Colors.blueGrey),
                                        ),]))

                              ),

                            )
                        ),
                      ],),),
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
                  title: const Text('Student Page'),
                  leading: IconButton(
                    icon: Icon(Icons.library_books_outlined),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>StudentInfo(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Teacher Page'),
                  leading: IconButton(
                    icon: Icon(Icons.perm_contact_calendar),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>TeachearInfo(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Head Page'),
                  leading: IconButton(
                    icon: Icon(Icons.perm_contact_calendar),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>HeadInfo(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Create Department'),
                  leading: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>DepartmentForm(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('See The Users'),
                  leading: IconButton(
                    icon: Icon(Icons.people_alt_outlined),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>TeachearInfo(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 130),
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
