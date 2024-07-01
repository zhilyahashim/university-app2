import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetTimetable extends StatefulWidget {
  final String token;

  GetTimetable(this.token);

  @override
  State<GetTimetable> createState() => _GetTimetableState();
}

class _GetTimetableState extends State<GetTimetable> {
  Map<String, Map<String, dynamic>> timetables = {};
  List<String>? departmentNames;
  String? selectedDepartment;
  List<dynamic>? timetable;

  @override
  void initState() {
    super.initState();
    fetchDepartmentNames();
  }

  Future<void> fetchTimetable(String departmentName) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/get/timetable'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> timetableData = json.decode(response.body);

        // Debugging: Print the timetableData
        print('Fetched timetable data: $timetableData');

        setState(() {
          timetables = Map.fromIterable(
            timetableData,
            key: (timetable) {
              final departmentName = timetable['department_name'];
              if (departmentName == null) {
                print('Error: department_name is null in timetable data');
                return '';  // Use a default value or handle appropriately
              }
              return departmentName;
            },
            value: (timetable) => timetable,
          );
        });
      } else {
        print('Failed to fetch timetable: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch timetable: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching timetable: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching timetable: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> fetchDepartmentNames() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/department_name'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched department names: $data'); // Debugging line
        final List<String> departments = data.map<String>((department) => department.toString()).toList();
        setState(() {
          departmentNames = departments;
        });
      } else {
        print('Failed to fetch department names: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch department names: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching department names: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching department names: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'Timetables',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: departmentNames == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                'Select a Department To See The Timetable:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: Container(
                width: 400,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: [
                      DataColumn(label: Text('Department Name')),
                      DataColumn(label: Text('Select')),
                    ],
                    rows: departmentNames!.map<DataRow>((departmentName) {
                      return DataRow(
                        cells: [
                          DataCell(Text(departmentName)),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  selectedDepartment = departmentName;
                                });
                                fetchTimetable(selectedDepartment!);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (selectedDepartment != null && timetables.containsKey(selectedDepartment))
              Table(
                border: TableBorder.all(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey,
                ),
                children: [
                  _buildTableRow('Department Name', timetables[selectedDepartment]!['department_name']),
                  _buildTableRow('Day Of The Week', timetables[selectedDepartment]!['day']),
                  _buildTableRow('Level Of Lectures', timetables[selectedDepartment]!['firstlecture']),
                  _buildTableRow('Time Of Starting Lecture', timetables[selectedDepartment]!['start_time']),
                  _buildTableRow('Time Of Ending Lecture', timetables[selectedDepartment]!['end_time']),
                  _buildTableRow('Activity', timetables[selectedDepartment]!['activity']),
                  _buildTableRow('Level Of Lectures', timetables[selectedDepartment]!['secondlecture']),
                  _buildTableRow('Time Of Starting Lecture', timetables[selectedDepartment]!['starts_time']),
                  _buildTableRow('Time Of Ending Lecture', timetables[selectedDepartment]!['ends_time']),
                  _buildTableRow('Activity', timetables[selectedDepartment]!['activitys']),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
