import 'package:attendance/screens/admin_system/admin_dashboard.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_drop_down.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';

class AddSubjectsScreen extends StatefulWidget {
  const AddSubjectsScreen({super.key});

  @override
  State<AddSubjectsScreen> createState() => _AddSubjectsScreenState();
}

class _AddSubjectsScreenState extends State<AddSubjectsScreen> {
  final TextEditingController newSubjectController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Controller.getClassList();
  }

  /// ADD SUBJECTS FUNCTION
  Future<void> addClass() async {
    final subjectName = newSubjectController.text.trim();
    final selectedClass = Controller.selectedClass.value;

    if (subjectName.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter Subject name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance
        .collection("subjects")
        .doc(selectedClass)
        .collection("subjects")
        .doc(subjectName)
        .set({"subject": subjectName});

    setState(() => isLoading = false);
    newSubjectController.clear();

    Get.snackbar(
      "Success",
      "Subject added successfully",
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
        title: Text("Add Subject", style: AppTextStyle.semiBold22()),
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
              Text("Create a New Subject", style: AppTextStyle.semiBold18()),

              customDropDown(
                label: "Class",
                items: Controller.classList,
                selectedValue: Controller.selectedClass,
                onChanged: (val) async {
                  Controller.selectedClass.value = val ?? '';
                  await Controller.getSubjectList();
                },
              ),

              const SizedBox(height: 16),

              customTextField(
                "Enter Subject Name",
                controller: newSubjectController,
              ),

              const SizedBox(height: 24),

              isLoading
                  ? const CircularProgressIndicator()
                  : customButton(
                      buttonText: "Add Subject",
                      onPressed: addClass,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
