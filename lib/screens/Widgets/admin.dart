import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentForm extends StatefulWidget {
  @override
  _DepartmentFormState createState() => _DepartmentFormState();
}

class _DepartmentFormState extends State<DepartmentForm> {
  List<dynamic> _headUsers = [];
  dynamic _selectedHead;
  TextEditingController _departmentnameController = TextEditingController();
  TextEditingController _stagesController = TextEditingController();
  List<Map<String, dynamic>> departmentData = [];

  Future<String?> getToken() async {
    return 'your_authentication_token_here';
  }

  Future<void> _fetchStaffUsers() async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/head-users'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _headUsers = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch staff users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff users: $e');
    }
  }

  Future<void> _createDepartment() async {
    var departmentName = _departmentnameController.text.trim();
    var selectedHead = _selectedHead;

    if (departmentName.isEmpty ||
        selectedHead == null ||
        selectedHead['id'] == null ||
        selectedHead['name'] == null) {
      print('Department name, head ID, or head name cannot be empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Department name, head ID, or head name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    var data = {
      'department_name': departmentName,
      'headOfDepartment_id': selectedHead['id'],
      'head_name': selectedHead['name'],
      'numberofstage': _stagesController.text.split(','),
    };

    try {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/departments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        print('Department created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The Department Creation is successful'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedHead = null;
          _stagesController.clear();
          _departmentnameController.clear();
        });
      } else {
        print('Failed to create department: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create department'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStaffUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'Create Department',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _departmentnameController,
                  decoration: InputDecoration(
                    labelText: 'Department Name',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedHead != null ? _selectedHead['name'] : null,
                  onChanged: (String? staffName) {
                    setState(() {
                      _selectedHead = _headUsers.firstWhere(
                            (staff) => staff['name'] == staffName,
                        orElse: () => null,
                      );
                    });
                  },
                  items: _headUsers.map<DropdownMenuItem<String>>(
                        (dynamic staffData) {
                      String staffName = staffData['name'];
                      return DropdownMenuItem<String>(
                        value: staffName,
                        child: Text(staffName),
                      );
                    },
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Head',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Head';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _stagesController,
                  decoration: InputDecoration(
                    labelText: 'Stages (comma-separated)',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _createDepartment,
              child: Padding(
                padding: EdgeInsets.only(left: 200),
                child: Container(
                  width: 200,
                  height: 40,
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
                    padding: EdgeInsets.only(top: 6, left: 10),
                    child: Text(
                      'Create Department',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
