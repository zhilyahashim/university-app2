import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:knu_app/Methods/api.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login.dart';

class Register extends StatefulWidget {
 const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _formkey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String _selectedRole = 'user';
  String _studentName = '';


  bool obscurePass = true;

  //function for userregister
  void UserRegister() async {
    var data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'phone': _phoneController.text,
      'role': _selectedRole,
      'student_name':_studentName,

    };

    try {
      var response = await API().postData(data, 'register');
      var body = json.decode(response.body);
      if (body['success'] != null && body['success'] is bool &&
          body['success']) {
        print("Rgisteration succssesful.");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print('Registration failed. Server response: $body');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/loginback.jpeg'),
                  fit: BoxFit.cover,
                  opacity: 0.7
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Stack(
                    children: <Widget>[
                      // text as border.
                      Text(
                        'Knowledge University',
                        style: TextStyle(
                          fontSize: 30,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = Colors.black38!,
                        ),
                      ),
                      // text as fill.
                      Text(
                        'Knowledge University',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 350,
                    height: 650,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _nameController,
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.white),
                                suffixStyle: TextStyle(color: Colors.white),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the name';
                                }
                                return null;
                              },

                              cursorColor: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _emailController,
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the email';
                                }
                                return null;
                              },

                              cursorColor: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _passwordController,
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                              obscureText: true,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.white),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the password';
                                }
                                return null;
                              },

                              cursorColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),


                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IntlPhoneField(

                              controller: _phoneController,
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                              decoration: InputDecoration(

                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                labelText: 'Phone',
                                labelStyle: TextStyle(color: Colors.white),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ) {
                                  return 'Please enter the phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,


                              cursorColor: Colors.white,
                            ),

                          ),
                          Padding(padding: EdgeInsets.only(right: 20, left: 20),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white54,
                                  borderRadius: BorderRadius.circular(30)),

                              child:DropdownButtonFormField<String>(
                                value: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                                items: [
                                  'user',
                                  'student',
                                  'headofdepartment',
                                  'staff'
                                ].map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role.toUpperCase()),
                                  );
                                }).toList(),
                                onSaved: (String? value) {
                                  setState(() {
                                    _selectedRole = value!;
                                    // Fetch student name if role is 'student'
                                    if (_selectedRole == 'student') {
                                      _fetchStudentName();
                                    } else {
                                      _studentName = '';
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                    labelText: 'Choose your Role'),
                              ),



                            ),
                          ),


                          const SizedBox(height: 5,),


                          ElevatedButton(onPressed: () {
                            setState(() {
                              UserRegister();
                            });
                          },
                              child: Text('Register',
                                style: TextStyle(color: Colors.black,),)),
                          const SizedBox(height: 10,),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: InkWell(
                                onTap: () {
                                  print('Loginbutton');
                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) =>
                                          LoginPage()));
                                },
                                child: Text('already have an account',
                                  style: TextStyle(color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.cyanAccent,
                                    // optional
                                    decorationThickness: 2,
                                    // optional
                                    decorationStyle: TextDecorationStyle.solid,

                                  ),
                                )),),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [

                                    InkWell(
                                      onTap: () =>
                                          launchUrl(Uri.parse(
                                              'https://www.instagram.com/knowledge_.university?igsh=NTc4MTIwNjQ2YQ==')),
                                      child: Icon(
                                        FontAwesomeIcons.instagram,
                                        size: 20,
                                        color: Colors.pink[600],
                                        semanticLabel: 'Instagram',
                                      ),
                                    ),
                                    Text(
                                      "Instagram",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          launchUrl(Uri.parse(
                                              'https://www.facebook.com/KnowledgeUniv')),
                                      child: Icon(
                                        FontAwesomeIcons.facebook,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      'Facebook',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            launchUrl(
                                                Uri.parse(
                                                    'https://knu.edu.iq/')),
                                        child: Icon(
                                          FontAwesomeIcons.weebly,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Website',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 115),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '0750 300 0800',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
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
      ),
    );
  }

  void _fetchStudentName() async {
    try {
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/student_name'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _studentName = data['student_name'];
        });
      } else {
        print('Failed to fetch student name');
      }
    } catch (e) {
      print('Error fetching student name: $e');
    }
  }

}
