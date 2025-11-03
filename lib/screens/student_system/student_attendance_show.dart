import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentReport extends StatefulWidget {
  final String enrollmentNumber;
  const StudentReport({super.key, required this.enrollmentNumber});

  @override
  State<StudentReport> createState() => _StudentReportState();
}

class _StudentReportState extends State<StudentReport> {
  bool _loading = false;
  Map<String, double> subjectPercentages = {};

  @override
  void initState() {
    super.initState();
    fetchStudentReport();
  }

  Future<void> fetchStudentReport() async {
    setState(() => _loading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // Path up to division (A)
      final divRef = firestore
          .collection('attendance')
          .doc('sem 1')
          .collection('A');

      // Get all subjects (e.g. "c", "maths", etc.)
      final subjectsSnapshot = await divRef.get();

      Map<String, double> tempResults = {};

      for (var subjectDoc in subjectsSnapshot.docs) {
        final subjectName = subjectDoc.id;
        final datesRef = divRef.doc(subjectName).collection('dates');
        final datesSnapshot = await datesRef.get();

        int totalDays = 0;
        int presentDays = 0;

        for (var dateDoc in datesSnapshot.docs) {
          final data = dateDoc.data();
          final students = List.from(data['students'] ?? []);

          for (var student in students) {
            if (student['enrollment_number'] == widget.enrollmentNumber) {
              totalDays++;
              if (student['status'] == true) presentDays++;
            }
          }
        }

        if (totalDays > 0) {
          final percentage = (presentDays / totalDays) * 100;
          tempResults[subjectName] = percentage;
        }
      }

      setState(() {
        subjectPercentages = tempResults;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance Report"),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : subjectPercentages.isEmpty
          ? const Center(
        child: Text(
          "No attendance found for this student.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: subjectPercentages.length,
        itemBuilder: (context, index) {
          final subject = subjectPercentages.keys.elementAt(index);
          final percentage = subjectPercentages[subject]!;

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                subject.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                  color: percentage >= 75
                      ? Colors.green
                      : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
