import 'package:attendance/screens/admin_system/admin_dashboard.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDivisionScreen extends StatefulWidget {
  const AddDivisionScreen({super.key});

  @override
  State<AddDivisionScreen> createState() => _AddDivisionScreenState();
}

class _AddDivisionScreenState extends State<AddDivisionScreen> {
  final TextEditingController newDivisionController = TextEditingController();
  bool isLoading = false;

  /// ADD CLASS FUNCTION
  Future<void> addClass() async {
    final className = newDivisionController.text.trim().toUpperCase();

    if (className.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter division name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection("div").doc(className).set({
      "name": className,
    });

    setState(() => isLoading = false);
    newDivisionController.clear();

    Get.snackbar(
      "Success",
      "Class added successfully",
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
        title: Text("Add Division", style: AppTextStyle.semiBold22()),
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
              Text("Create a New Division", style: AppTextStyle.semiBold18()),

              const SizedBox(height: 16),

              customTextField(
                "Enter Division Name",
                controller: newDivisionController,
              ),

              const SizedBox(height: 24),

              isLoading
                  ? const CircularProgressIndicator()
                  : customButton(
                      buttonText: "Add Division",
                      onPressed: addClass,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
