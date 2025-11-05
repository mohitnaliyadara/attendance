import 'dart:developer';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance/screens/faculty_system/faculty_management_dashboard.dart';
import 'package:get_storage/get_storage.dart';

class StudentReport extends StatefulWidget {
  const StudentReport({super.key});

  @override
  State<StudentReport> createState() => _StudentReportState();
}

class _StudentReportState extends State<StudentReport> {
  bool _loading = true;
  late final String enrollmentNumber = GetStorage().read("enrollment number") ;
  late final String studentName = GetStorage().read("username");

  Map<String, Map<String, dynamic>> subjectAttendance = {};

  @override
  void initState() {
    super.initState();
    getStudentAttendanceDetails(enrollmentNumber);
  }

  Future<void> getStudentAttendanceDetails(String enrollmentNumber) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final divRef =
      firestore.collection('attendance').doc('sem 1').collection('A');
      final subjectDocs = await divRef.get();

      Map<String, Map<String, dynamic>> tempData = {};

      for (final subject in subjectDocs.docs) {
        final subjectName = subject.id;
        final datesCollection = divRef.doc(subjectName).collection('dates');
        final datesSnapshot = await datesCollection.get();

        int totalClasses = 0;
        int presentCount = 0;

        for (final dateDoc in datesSnapshot.docs) {
          final data = dateDoc.data();
          final students = (data['students'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
              [];

          final student = students.firstWhere(
                (s) => s['enrollment_number'] == enrollmentNumber,
            orElse: () => {},
          );

          bool isPresent = student.isNotEmpty && student['status'] == true;

          totalClasses++;
          if (isPresent) presentCount++;
        }

        final absentCount = totalClasses - presentCount;
        final percentage =
        totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;

        tempData[subjectName] = {
          'total': totalClasses,
          'present': presentCount,
          'absent': absentCount,
          'percentage': percentage,
        };
      }

      setState(() {
        subjectAttendance = tempData;
        _loading = false;
      });
    } catch (e, st) {
      log('Error fetching attendance: $e\n$st');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(

        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              getStudentAttendanceDetails(enrollmentNumber);
            },
          ),
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
            GetStorage().remove("enrollment number");
            GetStorage().remove("username");
            showCustomSnackbar("Student Logging out...", type: SnackbarType.info);

          }, icon: Icon(Icons.logout))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 👤 Student Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.shade100,
                  radius: 30,
                  child: const Icon(Icons.person, size: 32),
                ),
                title: Text(
                  studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text("Enrollment: $enrollmentNumber"),
              ),
            ),
            const SizedBox(height: 16),

            // 📘 Subject summary list
            ...subjectAttendance.entries.map((entry) {
              final subject = entry.key;
              final data = entry.value;
              final total = data['total'] as int;
              final present = data['present'] as int;
              final absent = data['absent'] as int;
              final percentage = data['percentage'] as double;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject name + percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subject.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "${percentage.toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: percentage >= 75
                                  ? Colors.green
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Totals info
                      Text(
                        "Total Classes: $total",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Present: $present | Absent: $absent",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Progress bar
                      LinearProgressIndicator(
                        value: total > 0 ? (present / total) : 0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.grey.shade300,
                        color: percentage >= 75
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
