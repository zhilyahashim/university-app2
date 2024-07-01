import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> timetableData = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController departmentNameController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController firstlectureController = TextEditingController();
  final TextEditingController starttimeController = TextEditingController();
  final TextEditingController endtimeController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController secondlectureController = TextEditingController();
  final TextEditingController startstimeController = TextEditingController();
  final TextEditingController endstimeController = TextEditingController();
  final TextEditingController activitysController = TextEditingController();
  TimeOfDay? _selectedstartTime;
  TimeOfDay? _selectedendTime;
  TimeOfDay? _selectedstartsTime;
  TimeOfDay? _selectedendsTime;
  dynamic _selectedDepartment;
  String? selectedDepartment;
  List<String>? departmentNames;
  List<dynamic> _departmentName = [];

  void initState() {
    super.initState();
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
          _departmentName = data;
          _selectedDepartment = _departmentName.isNotEmpty ? _departmentName[0] : null;
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
  @override
  Future<void> _createTimetable() async {
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

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      var data = {
        'department_name': _selectedDepartment != null ? _selectedDepartment['department_name'] : null,
        'day': dayController.text,
        'firstlecture': firstlectureController.text,
        'start_time': _formatTimeOfDay(_selectedstartTime!),
        'end_time': _formatTimeOfDay(_selectedendTime!),
        'activity': activityController.text,
        'secondlecture': secondlectureController.text,
        'starts_time': _formatTimeOfDay(_selectedstartsTime!),
        'ends_time': _formatTimeOfDay(_selectedendsTime!),
        'activitys': activitysController.text,
      };

      try {
        var response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/timetable/bulk-update'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        if (response.statusCode == 201) {
          print('Timetable entry created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The Timetable Creation is successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            timetableData.add(json.decode(response.body)); // Update here
            departmentNameController.clear();
            dayController.clear();
            firstlectureController.clear();
            starttimeController.clear();
            endtimeController.clear();
            activityController.clear();
            secondlectureController.clear();
            startstimeController.clear();
            endstimeController.clear();
            activitysController.clear();
            _selectedstartTime = null;
            _selectedendTime = null;
            _selectedstartsTime = null;
            _selectedendsTime = null;
          });
        } else {
          print('Failed to create timetable entry: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The Timetable Creation is Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while creating the timetable'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Form validation failed or currentState is null');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text('Timetable',  style: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Text(
              'Create Timetable Entry',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(padding: EdgeInsets.only(left: 20),
            child:Row(children: [
              Padding(
                  padding: const EdgeInsets.all(12),
                  child:
                  Container(
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
                    child:   DropdownButtonFormField<String>(
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
                  )),
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 100,
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
                    child:  TextFormField(
                      controller: dayController,
                      decoration: InputDecoration(labelText: 'Day'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a day';
                        }
                        return null;
                      },
                    ),)),
            ],),),
            const SizedBox(height: 10,),
            Divider(),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
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
                  child:  TextFormField(
              controller: firstlectureController,
              decoration: InputDecoration(labelText: 'Lecture_part'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a day';
                }
                return null;
              },
            ),)),
            Padding(padding: EdgeInsets.only(left: 90),
           child:  Row(children: [
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedstartTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedstartTime = pickedTime;
                      starttimeController.text = _formatTimeOfDay(pickedTime);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedstartTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedstartTime = pickedTime;
                          starttimeController.text = _formatTimeOfDay(pickedTime);
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          starttimeController.text.isEmpty ? 'Start Time' : starttimeController.text,
                          style: TextStyle(color: starttimeController.text.isEmpty ? Colors.grey : Colors.black),
                        ),
                        Icon(Icons.access_time),
                      ],
                    ),
                  ),

                ),
              ),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedendTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedendTime = pickedTime;
                      endtimeController.text = _formatTimeOfDay(pickedTime);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedendTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedendTime = pickedTime;
                          endtimeController.text = _formatTimeOfDay(pickedTime);
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          endtimeController.text.isEmpty ? 'End Time' : endtimeController.text,
                          style: TextStyle(color: endtimeController.text.isEmpty ? Colors.grey : Colors.black),
                        ),
                        Icon(Icons.access_time),
                      ],
                    ),
                  ),

                ),
              ),
            ],),),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
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
                    child:  TextFormField(
              controller: activityController,
              decoration: InputDecoration(labelText: 'Activity'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity';
                }
                return null;
              },
            ),)),
            const SizedBox(height: 10,),
            Divider(),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
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
                    child:  TextFormField(
              controller: secondlectureController,
              decoration: InputDecoration(labelText: 'Lecture_Part'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a day';
                }
                return null;
              },
            ),)),
            Padding(padding: EdgeInsets.only(left: 90),
              child:  Row(children: [
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedstartsTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedstartsTime = pickedTime;
                        startstimeController.text = _formatTimeOfDay(pickedTime);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedstartsTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedstartsTime = pickedTime;
                            startstimeController.text = _formatTimeOfDay(pickedTime);
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            startstimeController.text.isEmpty ? 'Start Time' : startstimeController.text,
                            style: TextStyle(color: startstimeController.text.isEmpty ? Colors.grey : Colors.black),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),

                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedendsTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedendsTime = pickedTime;
                        endstimeController.text = _formatTimeOfDay(pickedTime);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedendsTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedendsTime = pickedTime;
                            endstimeController.text = _formatTimeOfDay(pickedTime);
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            endstimeController.text.isEmpty ? 'End Time' : endstimeController.text,
                            style: TextStyle(color: endstimeController.text.isEmpty ? Colors.grey : Colors.black),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),

                  ),
                ),
              ],),),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
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
                 child:  TextFormField(
              controller: activitysController,
              decoration: InputDecoration(labelText: 'Activity'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity';
                }
                return null;
              },
            ),)),
            InkWell(
              onTap: (){
                _createTimetable();
              },
              child: Padding(padding: EdgeInsets.only(left: 200,),
                child:Container(
                  width:90,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                    image: DecorationImage(
                      image: NetworkImage(''),
                      fit: BoxFit.cover,

                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow:[BoxShadow(
                      color: Colors.black,
                      blurRadius: 3,
                    ),

                    ],
                  ),
                  child:Padding(padding: EdgeInsets.only(top: 6,left: 10),
                    child: Text('Submit',style: TextStyle(fontWeight: FontWeight
                        .bold,
                        fontSize: 20,color: Colors.white),
                    ),),),

              ),),
            // if (timetableData.isNotEmpty) ...[
            //   Text('Last submitted values:', style: TextStyle(
            //     color: Colors.blueGrey,
            //     fontWeight: FontWeight.bold,
            //   ),),
            //   for (var entry in timetableData.last.entries)
            //     Text('${entry.key}: ${entry.value}'),
            // ],
            // const SizedBox(height: 30,),

          ],
        ),
      ),
    );
  }
  String formattedStartTime = DateFormat('H:i:s').format(DateTime.now());

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

}
