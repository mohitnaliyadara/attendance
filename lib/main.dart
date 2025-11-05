import 'package:attendance/screens/faculty_system/faculty_management_dashboard.dart';
import 'package:attendance/screens/faculty_system/get_reports/get_reposts.dart';
import 'package:attendance/screens/faculty_system/show_attendance/attendance_record.dart';
import 'package:attendance/screens/faculty_system/take_attendance/select_class_screen.dart';
import 'package:attendance/screens/student_system/student_attendance_show.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:
        StudentReport(),
    );
  }
}
