import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PutMarks extends StatefulWidget {
  final String token;

  PutMarks(this.token);

  @override
  State<PutMarks> createState() => _PutMarksState();
}

class _PutMarksState extends State<PutMarks> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? studentId;
  String studentName = '';
  String subjectName = '';

  late Future<List<Map<String, dynamic>>> _students;
  TextEditingController _midtermTheoryController = TextEditingController();
  TextEditingController _midtermPracticeController = TextEditingController();
  TextEditingController _dailyController = TextEditingController();
  TextEditingController _finalTheoryController = TextEditingController();
  TextEditingController _finalPracticeController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _subjects;
  List<dynamic> _subjectName = [];
  List<dynamic> _departmentName = [];
  dynamic _selectedSubject;
  dynamic _selectedDepartment;
  String? selectedDepartment;
  List<String>? departmentNames;


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

  Future<void> fetchSubjects() async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/subjects'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _subjectName = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch subjects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _students = fetchStudents();
    fetchSubjects();
    fetchDepartmentNames();
  }

  void dispose() {
    _midtermTheoryController.dispose();
    _midtermPracticeController.dispose();
    _dailyController.dispose();
    _finalTheoryController.dispose();
    _finalPracticeController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/students'),
        headers: <String, String>{},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((student) => student as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'Putting Marks',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _students,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final students = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(40),
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {
                        _showMarkDialog(student);
                      },
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
                        child: ListTile(
                          title: Text(student['name']),
                          subtitle: Text(student['role']),
                          trailing: Text('Click to put the marks'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _showMarkDialog(Map<String, dynamic> student) {
    studentId = student['id'];
    studentName = student['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Marks for ${student['name']}'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
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
                  DropdownButtonFormField<String>(
                    value: _selectedSubject != null ? _selectedSubject['subject_name'] : null,
                    onChanged: (String? subjectName) {
                      setState(() {
                        _selectedSubject = _subjectName.firstWhere(
                              (subject) => subject['subject_name'] == subjectName,
                          orElse: () => null,
                        );
                      });
                    },
                    items: _subjectName.map<DropdownMenuItem<String>>(
                          (dynamic subjectData) {
                        String subjectName = subjectData['subject_name'];
                        return DropdownMenuItem<String>(
                          value: subjectName,
                          child: Text(subjectName),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Subject',
                      contentPadding: const EdgeInsets.all(8),
                    ),
                  ),
                  TextFormField(
                    controller: _midtermTheoryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Midterm Theory Mark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter midterm theory mark';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _midtermPracticeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Midterm Practice Mark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter midterm practice mark';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dailyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Daily Mark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter daily mark';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _finalTheoryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Final Theory Mark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter final theory mark';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _finalPracticeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Final Practice Mark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter final practice mark';
                      }
                      return null;
                    },
                  ),

                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _submitMarks(studentId, studentName);

              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getLoggedInUserName() async {

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('name') ?? '';
  }

  Future<Map<String, dynamic>?> _submitMarks(int? studentId, String studentName) async {
    if (studentId == null) {
      print('Error: Student ID is null');
      return null;
    }

    final String loggedInUserName = await getLoggedInUserName();

    if (loggedInUserName != _selectedSubject['lecturer_name']) {
      print('Error: You are not authorized to put marks for this subject');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to put marks for this subject'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    final data = {
      'student_id': studentId.toString(),
      'subject_id': _selectedSubject != null ? _selectedSubject['id'] : null,
      'subject_name': _selectedSubject != null ? _selectedSubject['subject_name'] : null,
      'department_name': _selectedDepartment != null ? _selectedDepartment['department_name'] : null,
      'student_name': studentName,
      'midterm_theory': _midtermTheoryController.text,
      'midterm_practice': _midtermPracticeController.text,
      'daily': _dailyController.text,
      'final_theory': _finalTheoryController.text,
      'final_practice': _finalPracticeController.text,
    };

    print('Sending data to server: $data');

    try {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/save-marks'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        print('Stored Marks are successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stored Marks are successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedSubject = null;
          _selectedDepartment=null;
          _midtermTheoryController.clear();
          _midtermPracticeController.clear();
          _dailyController.clear();
          _finalTheoryController.clear();
          _finalPracticeController.clear();
        });
      } else {
        print('Failed to store marks: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to store marks'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}
