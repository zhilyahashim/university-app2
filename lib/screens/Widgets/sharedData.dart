// shared_data_provider.dart
import 'package:flutter/material.dart';
import 'package:knu_app/Models/studentModel.dart';

import '../../Models/teacherModel.dart';



class SharedDataProvider extends ChangeNotifier {
  Teacher teacher = Teacher();


  void setMarks(String studentName, int marks) {
    teacher.selectedStudent = studentName;
    teacher.enteredMarks = marks;
    notifyListeners();
  }
}

