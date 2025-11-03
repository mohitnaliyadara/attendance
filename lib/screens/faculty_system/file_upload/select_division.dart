import 'package:attendance/screens/faculty_system/faculty_management_dashboard.dart';
import 'package:attendance/screens/faculty_system/file_upload/upload_file.dart';
import 'package:attendance/utils/app_colors.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_drop_down.dart';
import '../../../widgets/custom_snackbar.dart';

class SelectDivision extends StatefulWidget {
  const SelectDivision({super.key});

  @override
  State<SelectDivision> createState() => _SelectDivisionState();
}

class _SelectDivisionState extends State<SelectDivision> {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Controller.selectedClass.value = '';
          Controller.selectedDiv.value = '';
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FacultyManagementDashboard(),));
        }, icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Select Division",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() => isLoading.value
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 120, bottom: 40),
            child: Container(
              width: fieldWidth + 40,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Class Details",
                    style: AppTextStyle.bold18(
                        color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 25),

                  // --- Class Dropdown ---
                  customDropDown(
                    label: "Class",
                    items: Controller.classList,
                    selectedValue: Controller.selectedClass,
                    width: fieldWidth,
                    onChanged: (val) async {
                      Controller.selectedClass.value = val ?? '';
                      await Controller.getSubjectList();
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Division Dropdown ---
                  customDropDown(
                    label: "Division",
                    items: Controller.divList,
                    selectedValue: Controller.selectedDiv,
                    width: fieldWidth,
                    onChanged: (val) async {
                      Controller.selectedDiv.value = val ?? '';
                      await Controller.getSubjectList();
                    },
                  ),
                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  customButton(
                    buttonText: "Continue",
                    width: fieldWidth,
                    onPressed: () {
                      if (Controller.selectedClass.value.isEmpty ||
                          Controller.selectedDiv.value.isEmpty) {
                        showCustomSnackbar(
                          "Please fill all the fields",
                          type: SnackbarType.error,
                        );
                      } else {
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UploadFile(),));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
