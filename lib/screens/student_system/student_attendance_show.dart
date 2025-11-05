import 'dart:developer';

import 'package:attendance/screens/faculty_system/faculty_management_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentReport extends StatefulWidget {

  const StudentReport({super.key});

  @override
  State<StudentReport> createState() => _StudentReportState();
}

class _StudentReportState extends State<StudentReport> {
  bool _loading = false;
  Map<String, double> subjectPercentages = {};

  @override
  void initState() {
    super.initState();
    getStudentAttendancePercentage("8904274424741");
  }

  Future<void> getStudentAttendancePercentage(String enrollmentNumber) async {
    final firestore = FirebaseFirestore.instance;

    // Go to division "A"
    final divRef = firestore
        .collection('attendance');
        // .doc('sem 1')
        // .collection('A');

    // ✅ Get all subjects (they are documents like "c", "maths", etc.)
    final subjectDocs = await divRef.get();
    log(subjectDocs.docs.length.toString());
    for (final subject in subjectDocs.docs) {
      final subjectName = subject.id;



      // Inside each subject document, go to the "dates" collection
      final datesCollection =
      divRef.doc(subjectName).collection('dates');


      final datesSnapshot = await datesCollection.get();

      int totalClasses = 0;
      int presentCount = 0;

      for (final dateDoc in datesSnapshot.docs) {
        totalClasses++;

        final data = dateDoc.data();
        final students = List<Map<String, dynamic>>.from(data['students']);

        // Find student in list
        final student = students.firstWhere(
              (s) => s['enrollment_number'] == enrollmentNumber,
          orElse: () => {},
        );

        if (student.isNotEmpty && student['status'] == true) {
          presentCount++;
        }
      }

      final percentage =
      totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;

      print(
          'Subject: $subjectName | Present: $presentCount/$totalClasses | Attendance: ${percentage.toStringAsFixed(2)}%');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FacultyManagementDashboard(),));
        }, icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Center(child: Text("Hiiiii")),
    );
  }
}

