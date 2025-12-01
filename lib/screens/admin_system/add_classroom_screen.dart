import 'package:attendance/screens/admin_system/admin_dashboard.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClassroomScreen extends StatefulWidget {
  const AddClassroomScreen({super.key});

  @override
  State<AddClassroomScreen> createState() => _AddClassroomScreenState();
}

class _AddClassroomScreenState extends State<AddClassroomScreen> {
  final TextEditingController newClassroomController = TextEditingController();
  bool isLoading = false;

  /// ADD CLASSROOM FUNCTION
  Future<void> addClass() async {
    final classroomName = newClassroomController.text.trim().toLowerCase();

    if (classroomName.isEmpty) {
      Get.snackbar(
          "Error",
          "Please enter classroom name",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection("classroom").doc(classroomName).set({
      "name": classroomName,
    });

    setState(() => isLoading = false);
    newClassroomController.clear();

    Get.snackbar(
        "Success",
        "classroom added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.off(() => AdminDashboard()),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: Text("Add Classroom", style: AppTextStyle.semiBold22()),
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black12,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Create a New Classroom", style: AppTextStyle.semiBold18()),

              const SizedBox(height: 16),

              customTextField(
                "Enter Classroom Name",
                controller: newClassroomController,
              ),

              const SizedBox(height: 24),

              isLoading
                  ? const CircularProgressIndicator()
                  : customButton(
                buttonText: "Add Classroom",
                onPressed: addClass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
