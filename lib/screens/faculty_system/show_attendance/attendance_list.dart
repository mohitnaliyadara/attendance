  import 'package:attendance/controller/controller.dart';
  import 'package:attendance/screens/faculty_system/show_attendance/attendance_record.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  class AttendanceList extends StatefulWidget {
    final String date;
    const AttendanceList({super.key, required this.date});

    @override
    State<AttendanceList> createState() => _AttendanceListState();
  }

  class _AttendanceListState extends State<AttendanceList> {
    final RxBool isLoading = true.obs;
    final RxList<Map<String, dynamic>> attendanceList = <Map<String, dynamic>>[].obs;

    @override
    void initState() {
      super.initState();
      _loadAttendance();
    }

    Future<void> _loadAttendance() async {
      try {
        isLoading.value = true;
        final data = await Controller.getAttendanceList(widget.date);
        attendanceList.assignAll(data);
      } catch (e) {
        Get.snackbar("Error", "Failed to fetch attendance: $e",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> _toggleAttendance(int index) async {
      final record = attendanceList[index];
      final newStatus = !(record['status'] ?? false);

      // Update locally (for instant animation)
      attendanceList[index]['status'] = newStatus;
      attendanceList.refresh();

      try {
        // Update in Firestore (optional but recommended)
        await Controller.updateAttendanceStatus(
          date: widget.date,
          index: index,   // we're updating by index
          status: newStatus,
        );
      } catch (e) {
        // Rollback UI if update fails
        attendanceList[index]['status'] = !newStatus;
        attendanceList.refresh();

        Get.snackbar(
          "Error",
          "Failed to update status: $e",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceRecordScreen()),
              );
            },
          ),
          title: Text(
            "Attendance (${widget.date})",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceList.isEmpty) {
            return const Center(
              child: Text(
                "No attendance records found.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final record = attendanceList[index];
              final studentName =
                  "${record['first_name']} ${record["last_name"]}" ?? 'Unknown';
              final isPresent = record['status'] ?? false;

              return GestureDetector(
                onTap: () => _toggleAttendance(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
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
                    border: Border.all(
                      color: isPresent ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPresent ? Colors.green : Colors.red,
                      child: Icon(
                        isPresent ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isPresent ? "Present" : "Absent",
                      style: TextStyle(
                        color: isPresent ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: const Icon(Icons.swap_horiz, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        }),
      );
    }
  }
