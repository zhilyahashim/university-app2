import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SeeMarks extends StatefulWidget {
  @override
  State<SeeMarks> createState() => _SeeMarksState();
}

class _SeeMarksState extends State<SeeMarks> {
  List<Map<String, dynamic>>? marks;

  @override
  void initState() {
    super.initState();
    fetchMarks();
  }

  late SharedPreferences prefrences;
  bool isLoad = false;

  Future<void> fetchMarks() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/user/marks'));

    if (response.statusCode == 200) {
      setState(() {
        marks = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Marks', style: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: marks == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:Column(children: [
          const SizedBox(height: 50,),
        DataTable(
          columnSpacing: 30.0,
          columns: [
            DataColumn(
              label: Text(
                'Student Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Subject Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Midterm Theory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Midterm Practice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Daily',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Final Theory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Final Practice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
          rows: marks!.map((mark) {
            return DataRow(
              cells: [
                DataCell(Text(mark['student_name'] ?? '-')),
                DataCell(Text(mark['subject_name'] ?? '-')),
                DataCell(Text(mark['midterm_theory'] != null ? mark['midterm_theory'].toString() : '-')),
                DataCell(Text(mark['midterm_practice'] != null ? mark['midterm_practice'].toString() : '-')),
                DataCell(Text(mark['daily'] != null ? mark['daily'].toString() : '-')),
                DataCell(Text(mark['final_theory'] != null ? mark['final_theory'].toString() : '-')),
                DataCell(Text(mark['final_practice'] != null ? mark['final_practice'].toString() : '-')),
              ],
            );
          }).toList(),
        ),
        ],)
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SeeMarks(),
  ));
}
