import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }
  //function for delete users
  Future<void> deleteUser(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('User deleted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The User  is Deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        fetchUsers();
      } else {
        print('Failed to delete user: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The User  is Deleted Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> userData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
        // After update, fetch users again to update the user list
        fetchUsers();
      } else {
        print('Failed to update user: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/all_users'));

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        title: Text(
          'User Table',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: DataTable(
            columns: <DataColumn>[
              // DataColumn(
              //   label: Text(
              //     'Name',
              //     style: TextStyle(
              //       color: Colors.blueGrey,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 20,
              //     ),
              //   ),
              // ),
              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Role',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              users.length,
                  (index) => DataRow(
                cells: <DataCell>[
                  //DataCell(Text(users[index]['name'])),
                  DataCell(Text(users[index]['email'])),
                  DataCell(Text(users[index]['role'])),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteUser(users[index]['id'], 'your-token-here');
                          },
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserListScreen(),
  ));
}
