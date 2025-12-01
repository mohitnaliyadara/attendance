import 'package:attendance/screens/admin_system/admin_dashboard.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController newClassController = TextEditingController();
  bool isLoading = false;

  /// ADD CLASS FUNCTION
  Future<void> addClass() async {
    final className = newClassController.text.trim().toLowerCase();

    if (className.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter class name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection("class").doc(className).set({
      "name": className,
    });

    setState(() => isLoading = false);
    newClassController.clear();

    Get.snackbar(
      "Success",
      "Class added successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
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
        title: Text("Add Class", style: AppTextStyle.semiBold22()),
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
              Text("Create a New Class", style: AppTextStyle.semiBold18()),

              const SizedBox(height: 16),

              customTextField(
                "Enter Class Name",
                controller: newClassController,
              ),

              const SizedBox(height: 24),

              isLoading
                  ? const CircularProgressIndicator()
                  : customButton(buttonText: "Add Class", onPressed: addClass),
            ],
          ),
        ),
      ),
    );
  }
}
