import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HeadOfDep extends StatefulWidget {
  const HeadOfDep({Key? key}) : super(key: key);

  @override
  State<HeadOfDep> createState() => _HeadOfDepState();
}

class _HeadOfDepState extends State<HeadOfDep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<dynamic> _staffUsers = [];
  dynamic _selectedStaff;
  TextEditingController _stageController = TextEditingController();
  TextEditingController _subjectNameController = TextEditingController();
  TextEditingController _semesterController = TextEditingController();
  bool _isPractical = false;
  List<Map<String, dynamic>> subjectData = [];
  String? selectedDepartment;
  List<String>? departmentNames;
  List<dynamic> _departmentName = [];
  dynamic _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _fetchStaffUsers();
    fetchDepartmentNames();
  }

  Future<void> fetchDepartmentNames() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/departmentsName'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> departments = data.map<String>((department) => department.toString()).toList();
        setState(() {
          departmentNames = departments;
          _departmentName = data; // Update _departmentName
          _selectedDepartment = _departmentName.isNotEmpty ? _departmentName[0] : null; // Initialize _selectedDepartment
        });
      } else {
        print('Failed to fetch department names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching department names: $e');
    }
  }

  Future<String> getLoggedInUserName() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('name') ?? '';
  }

  Future<void> _fetchStaffUsers() async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/staff-users'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _staffUsers = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch staff users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff users: $e');
    }
  }

  Future<void> _createSubject() async {
    final String loggedInUserName = await getLoggedInUserName();

    if (_selectedDepartment != null && _selectedDepartment['head_name'] != loggedInUserName) {
      print('Error: You are not authorized to create a subject for this department');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to create this subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      var data = {
        'stage': _stageController.text,
        'subject_name': _subjectNameController.text,
        'lecturer_id': _selectedStaff != null ? _selectedStaff['id'] : null,
        'lecturer_name': _selectedStaff != null ? _selectedStaff['name'] : null,
        'semester': _semesterController.text,
        'practice': _isPractical,
      };

      try {
        var response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/subject'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        if (response.statusCode == 201) {
          print('Subject created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subject created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            subjectData.add(data);
            _stageController.clear();
            _subjectNameController.clear();
            _selectedStaff = null;
            _semesterController.clear();
            _isPractical = false;
          });
        } else {
          print('Failed to create subject: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subject creation failed'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'Add Subject',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartment != null ? _selectedDepartment['department_name'] : null,
                    onChanged: (String? departmentName) {
                      setState(() {
                        _selectedDepartment = _departmentName.firstWhere(
                              (department) => department['department_name'] == departmentName,
                          orElse: () => null,
                        );
                      });
                    },
                    items: _departmentName.map<DropdownMenuItem<String>>(
                          (dynamic departmentData) {
                        String departmentName = departmentData['department_name'];
                        return DropdownMenuItem<String>(
                          value: departmentName,
                          child: Text(departmentName),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Department',
                      contentPadding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12),
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
                    controller: _stageController,
                    decoration: InputDecoration(
                      labelText: 'Stage',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter stage';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12),
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
                    controller: _subjectNameController,
                    decoration: InputDecoration(
                      labelText: 'Subject Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12),
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
                    value: _selectedStaff != null ? _selectedStaff['name'] : null,
                    onChanged: (String? staffName) {
                      setState(() {
                        _selectedStaff = _staffUsers.firstWhere(
                              (staff) => staff['name'] == staffName,
                          orElse: () => null,
                        );
                      });
                    },
                    items: _staffUsers.map<DropdownMenuItem<String>>(
                          (dynamic staffData) {
                        String staffName = staffData['name'];
                        return DropdownMenuItem<String>(
                          value: staffName,
                          child: Text(staffName),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Lecturer',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a lecturer';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12),
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
                    controller: _semesterController,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter semester';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
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
                      child: Checkbox(
                        value: _isPractical,
                        onChanged: (value) {
                          setState(() {
                            _isPractical = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
                  Text('Is Practical', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  _createSubject();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 150,),
                  child: Container(
                    width: 200,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[200],
                      image: DecorationImage(
                        image: NetworkImage(''),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 6, left: 35),
                      child: Text('Create Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              if (subjectData.isNotEmpty) ...[
                Text('Last submitted values:', style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),),
                for (var entry in subjectData.last.entries)
                  Text('${entry.key}: ${entry.value}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
