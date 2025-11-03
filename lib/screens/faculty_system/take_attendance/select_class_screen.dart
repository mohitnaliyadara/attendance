import 'package:attendance/controller/controller.dart';
import 'package:attendance/screens/faculty_system/faculty_management_dashboard.dart';
import 'package:attendance/screens/faculty_system/take_attendance/attendance_screen.dart';
import 'package:attendance/utils/app_colors.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_drop_down.dart';
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectClassScreen extends StatefulWidget {
  const SelectClassScreen({super.key});

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        Controller.getClassList(),
        Controller.getDivList(),
        Controller.getClassroomList(),
      ]);
    } catch (e) {
      showCustomSnackbar("Error loading data: $e", type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Controller.selectedClass.value = '';
            Controller.selectedDiv.value = '';
            Controller.selectedClassroom.value = '';
            Controller.selectedSubject.value = '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FacultyManagementDashboard(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(
        () => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 50,
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      customDropDown(
                        label: "Class",
                        items: Controller.classList,
                        selectedValue: Controller.selectedClass,
                        onChanged: (val) async {
                          Controller.selectedClass.value = val ?? '';
                          await Controller.getSubjectList();
                        },
                        width: fieldWidth,
                      ),

                      const SizedBox(height: 20),

                      customDropDown(
                        label: "Div",
                        items: Controller.divList,
                        selectedValue: Controller.selectedDiv,
                        onChanged: (val) async {
                          Controller.selectedDiv.value = val ?? '';
                          await Controller.getSubjectList();
                        },
                        width: fieldWidth,
                      ),

                      const SizedBox(height: 20),

                      customDropDown(
                        label: "Classroom",
                        items: Controller.classroomList,
                        selectedValue: Controller.selectedClassroom,
                        onChanged: (val) async =>
                            Controller.selectedClassroom.value = val ?? '',
                        width: fieldWidth,
                      ),

                      const SizedBox(height: 20),

                      customDropDown(
                        label: "Subject",
                        items: Controller.subjectList,
                        selectedValue: Controller.selectedSubject,
                        onChanged: (val) async {
                          Controller.selectedSubject.value = val ?? '';
                        },
                        width: fieldWidth,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: fieldWidth,
                        child: customTextField(
                          "Date: ${Controller.getTodayDate()}",
                          readOnly: true,
                          validator: null,
                        ),
                      ),

                      const SizedBox(height: 40),

                      customButton(
                        buttonText: "Submit",
                        width: fieldWidth,
                        onPressed: () {
                          if (Controller.selectedClass.value.isEmpty ||
                              Controller.selectedDiv.value.isEmpty ||
                              Controller.selectedClassroom.value.isEmpty ||
                              Controller.selectedSubject.value.isEmpty) {
                            showCustomSnackbar(
                              "Please fill all the fields",
                              type: SnackbarType.error,
                            );
                          } else {
                            Get.to(() => const QRScannerScreen());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
