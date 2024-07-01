import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentMarksPage extends StatefulWidget {
  final String token;

  StudentMarksPage(this.token);

  @override
  _StudentMarksPageState createState() => _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  Map<String, dynamic>? marks;
  List<String>? subjectNames;
  String? selectedSubject;
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    fetchSubjectNames();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> fetchSubjectNames() async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/subject_name'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<String> subjects = data.map((subject) => subject.toString()).toList();
        setState(() {
          subjectNames = subjects;
        });
      } else {
        print('Failed to fetch subject names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subject names: $e');
    }
  }

  Future<void> fetchMarks(String subjectName) async {
    try {
      final loggedUserName = preferences.getString('name');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/marks'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);

        final filteredData = responseBody.firstWhere(
              (data) =>
          data['student_name'] == loggedUserName &&
              data['subject_name'] == subjectName,
          orElse: () => null,
        );

        setState(() {
          marks = filteredData;
        });

        if (marks == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You don't have marks for this subject."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Failed to fetch marks: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are not available for result marks.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching marks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Marks',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: subjectNames == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 90),
              child: Text(
                'Select a Subject:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 70),
              child: Container(
                width: 300,
                child: DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(
                      label: Text('Subject Name'),
                    ),
                    DataColumn(
                      label: Text('Select'),
                    ),
                  ],
                  rows: subjectNames!.map<DataRow>((subjectName) {
                    return DataRow(
                      cells: [
                        DataCell(Text(subjectName)),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                selectedSubject = subjectName;
                              });
                              fetchMarks(selectedSubject!); // Pass the selected subject to fetchMarks
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (marks != null)
              Table(
                border: TableBorder.all(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey,
                ),
                children: [
                  _buildTableRow('Student Name', marks?['student_name']),
                  _buildTableRow('Subject Name', marks?['subject_name']),
                  _buildTableRow('Midterm Theory', marks?['midterm_theory']),
                  _buildTableRow('Midterm Practice', marks?['midterm_practice']),
                  _buildTableRow('Daily', marks?['daily']),
                  _buildTableRow('Final Theory', marks?['final_theory']),
                  _buildTableRow('Final Practice', marks?['final_practice']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(value != null ? value.toString() : ''),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StudentMarksPage('your_token_here'),
  ));
}
