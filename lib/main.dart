import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knu_app/screens/Widgets/admin.dart';
import 'package:knu_app/screens/Widgets/adminInfo.dart';
import 'package:knu_app/screens/Widgets/headInfo.dart';
import 'package:knu_app/screens/Widgets/headOfDep.dart';
import 'package:knu_app/screens/Widgets/sharedData.dart';
import 'package:knu_app/screens/Widgets/student.dart';
import 'package:knu_app/screens/Widgets/studentInfo.dart';
import 'package:knu_app/screens/Widgets/teacher.dart';
import 'package:knu_app/screens/Widgets/teacherInfo.dart';
import 'package:knu_app/screens/auth/login.dart';
import 'package:knu_app/screens/auth/register.dart';
import 'package:pod/pod.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SharedDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      title: 'KNU_APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
      routes: {
        '/login':(context)=>LoginPage(),
        '/studentInfo': (context) => StudentInfo(),
        '/TeacherPage': (context) => TeachearInfo(),
        '/headInfo': (context) => HeadInfo(),
        '/DepartmentForm': (context) => DepartmentForm(),
        '/adminInfo':(context)=>AdminInfo('_userData'),
      },
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }

}
