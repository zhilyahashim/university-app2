import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knu_app/screens/auth/register.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Methods/api.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

final _formkey=GlobalKey<FormState>();
final _emailController=TextEditingController();
final _passwordController=TextEditingController();
String _selectedRole = 'user';
bool obscurePass=true;




 //function for userlogin
 void UserLogin() async {
       var data = {
         'email': _emailController.text,
         'password': _passwordController.text,
         'role': _selectedRole,
       };

       try {
         var response = await API().postData(data, 'login');
         var body = json.decode(response.body);
         print('Response body: $body');
         if (body['success'] != null && body['success'] is bool &&
             body['success']) {
           // Login successful
           switch (_selectedRole) {
             case 'student':
               Navigator.pushReplacementNamed(context, '/studentInfo');
               break;
             case 'staff':
               Navigator.pushReplacementNamed(context, '/TeacherPage');
               break;
             case 'headofdepartment':
               Navigator.pushReplacementNamed(context, '/headInfo');
               break;
             case 'user':
               Navigator.pushReplacementNamed(context, '/adminInfo');
               break;
             default:
             // Handle unknown role
               break;
           }

         }

         SharedPreferences preferences = await SharedPreferences.getInstance();

         var user = body['user'];

         if (user != null && user is Map<String, dynamic>) {
           var name = user['name'];
           var email = user['email'];
           var phone = user['phone'];
           var role = user['role'];
           if (name != null && email != null) {
             await preferences.setString('name', name);
             await preferences.setString('email', email);
             await preferences.setString('phone', phone ?? ''); //this mean bring the phone value if before it have null value or not
             await preferences.setString('role', role ?? '');
           } else {
             print('Name or email is null');
           }
         } else {
           print('User object not found or is not a map');
         }


       } catch (e) {
         print('Error: $e');
       }

     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ Stack(
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
            const SizedBox(height: 20,),

            Center(
                child:
            Container(
              width: 350,
              height: 600,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(13)
              ),
              child:
              Column(
                children: [
                  const SizedBox(height: 50,),
                  Text("Login", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),),
                  const SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: _emailController,
                      style:
                      TextStyle(fontSize: 18, color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        icon: Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        labelText: 'Insert your email..',
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
                          return 'Please enter your email';
                        }
                        return null;
                      },


                      cursorColor: Colors.white,
                    ),

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
                        labelText: 'Insert your password',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },

                      cursorColor: Colors.white,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 20,left: 20),
                  child:Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(30)),

                 child: DropdownButtonFormField<String>(

                    value: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    items: ['user', 'student', 'headofdepartment', 'staff']
                        .map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role.toUpperCase()),
                      );

                    })
                        .toList(),
                    decoration: InputDecoration(labelText: 'Choose your Role'),
                  ),
              ),
            ),

                  const SizedBox(height: 60,),
                    ElevatedButton(onPressed: ()  {
                      setState(() {
                        UserLogin();
                      });

                    }, child: Text('Login',
                      style: TextStyle(color: Colors.black),)),
                  Padding(
              padding: EdgeInsets.only(left: 180),
              child: InkWell(
                  onTap: () {
                    print('Registerbutton');
                    Navigator.push(context,
                        MaterialPageRoute(builder:
                            (BuildContext context) => Register()));
                  }, child: Text('Register',style: TextStyle(color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.cyanAccent, // optional
                          decorationThickness: 2, // optional
                          decorationStyle: TextDecorationStyle.solid,

              ),
              ),
              ),
              ),

                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            InkWell(
                              onTap: () => launchUrl(Uri.parse(
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
                              onTap: () => launchUrl(Uri.parse(
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
                                onTap: () => launchUrl(
                                    Uri.parse('https://knu.edu.iq/')),
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
            )
            )
          ],
        ),
      ),

    );
  }


}


