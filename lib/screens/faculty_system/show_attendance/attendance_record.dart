import 'package:attendance/screens/faculty_system/show_attendance/attendance_list.dart';
import 'package:attendance/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/controller.dart';
import '../../../utils/app_text_style.dart';
import '../../../widgets/custom_drop_down.dart';
import '../../../widgets/custom_snackbar.dart';
import '../faculty_management_dashboard.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({super.key});

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  final RxBool isLoading = false.obs;
  final RxList<String> dates = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadDates();

  }

  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
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

  Future<void> _loadDates() async {
    if (Controller.selectedClass.isEmpty ||
        Controller.selectedDiv.isEmpty ||
        Controller.selectedSubject.isEmpty) {
      showCustomSnackbar("Please select all filters", type: SnackbarType.info);
      return;
    }

    try {
      isLoading.value = true;
      final fetchedDates = await Controller.getAllDates(
        Controller.selectedClass.value,
        Controller.selectedDiv.value,
        Controller.selectedSubject.value,
      );

      dates.assignAll(fetchedDates);
      if (dates.isEmpty) {
        showCustomSnackbar(
          "No attendance dates found.",
          type: SnackbarType.info,
        );
      }
    } catch (e) {
      showCustomSnackbar("Error fetching dates: $e", type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Attendance Records"),
        centerTitle: true,
        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: ()  {
            Controller.selectedClass.value = '';
            Controller.selectedDiv.value = '';
            Controller.selectedSubject.value = '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const FacultyManagementDashboard(),
              ),
            );
          }
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 Filter Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Attendance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 12),

                    customDropDown(
                      label: "Division",
                      items: Controller.divList,
                      selectedValue: Controller.selectedDiv,
                      onChanged: (val) async {
                        Controller.selectedDiv.value = val ?? '';
                        await Controller.getSubjectList();
                      },
                      width: fieldWidth,
                    ),
                    const SizedBox(height: 12),

                    customDropDown(
                      label: "Subject",
                      items: Controller.subjectList,
                      selectedValue: Controller.selectedSubject,
                      onChanged: (val) async {
                        Controller.selectedSubject.value = val ?? '';
                      },
                      width: fieldWidth,
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadDates,
                        icon: Icon(Icons.search, color: AppColors.whiteColor),
                        label: Text(
                          "Show Dates",
                          style: AppTextStyle.semiBold16(
                            color: AppColors.whiteColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Dates List Section
              if (dates.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No attendance dates found.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Colors.indigo,
                        ),
                        title: Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceList(date: date),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
