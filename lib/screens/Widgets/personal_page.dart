import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProfilePage extends StatefulWidget {
  final String token;

  UserProfilePage(this.token);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  late SharedPreferences prefrences;
  bool isLoad = false;

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
        userData = json.decode(response.body);
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'Personal Data',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 20, left: 20, top: 40),
          child: Column(
            children: [
              Text(
                'All of your information is here',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Table(
                  border: TableBorder.all(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueGrey,
                  ),
                  children: [
                    _buildTableRow('Name', prefrences.getString('name')),
                    _buildTableRow('Email', prefrences.getString('email')),
                    _buildTableRow('Phone', prefrences.getString('phone')),
                    _buildTableRow('Role', prefrences.getString('role')),
                    // Add more user data fields here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.only(left: 20,top: 15,right: 40),
              child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(value ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}
