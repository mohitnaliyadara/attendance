import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_drop_down.dart';
import '../faculty_management_dashboard.dart';

class GetReports extends StatefulWidget {
  const GetReports({super.key});

  @override
  State<GetReports> createState() => _GetReportsState();
}

class _GetReportsState extends State<GetReports> {
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      Controller.getClassList(),
      Controller.getDivList(),
      Controller.getClassroomList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Subject-Wise Report"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Controller.selectedClass.value = '';
            Controller.selectedDiv.value = '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FacultyManagementDashboard(),
              ),
            );
          },
        ),
      ),
      body: Obx(
            () => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Select Class and Division to Generate Excel Report",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),

              customDropDown(
                label: "Class",
                items: Controller.classList,
                selectedValue: Controller.selectedClass,
                onChanged: (val) async {
                  Controller.selectedClass.value = val ?? '';
                },
                width: fieldWidth,
              ),
              const SizedBox(height: 20),

              customDropDown(
                label: "Division",
                items: Controller.divList,
                selectedValue: Controller.selectedDiv,
                onChanged: (val) async {
                  Controller.selectedDiv.value = val ?? '';
                },
                width: fieldWidth,
              ),
              const SizedBox(height: 40),

              customButton(
                buttonText: "Generate Subject-Wise Report",
                onPressed: () async {
                  isLoading.value = true;
                  await Controller.generateSubjectWiseReport(
                    Controller.selectedClass.value,
                    Controller.selectedDiv.value,
                  );
                  isLoading.value = false;
                },
                width: fieldWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
