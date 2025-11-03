import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum UserRole { faculty, student }

class Controller extends GetxController {
  // ============================================================
  // SECTION 1️⃣: LOGIN FIELDS
  // ============================================================
  static final RxBool isPasswordVisible = false.obs;
  static final usernameController = TextEditingController();
  static final passwordController = TextEditingController();

  // ============================================================
  // SECTION 2️⃣: CLASS / DIV / SUBJECT MANAGEMENT
  // ============================================================
  static final RxList<String> classList = <String>[].obs;
  static final RxString selectedClass = "".obs;

  static final RxList<String> classroomList = <String>[].obs;
  static final RxString selectedClassroom = "".obs;

  static final RxList<String> divList = <String>[].obs;
  static final RxString selectedDiv = "".obs;

  static final RxList<String> subjectList = <String>[].obs;
  static final RxString selectedSubject = "".obs;

  // ======== FIRESTORE FETCHERS ========
  static Future<void> getClassList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("class")
          .orderBy("class")
          .get();

      classList.value =
          snapshot.docs.map((doc) => doc["class"].toString()).toList();
    } catch (e) {
      showCustomSnackbar("Error fetching class list: $e",
          type: SnackbarType.error);
    }
  }

  static Future<void> getClassroomList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("classroom")
          .orderBy("classroom")
          .get();
      classroomList.value =
          snapshot.docs.map((doc) => doc["classroom"].toString()).toList();
    } catch (e) {
      showCustomSnackbar("Error fetching classroom list: $e",
          type: SnackbarType.error);
    }
  }

  static Future<void> getDivList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("div")
          .orderBy("div")
          .get();
      divList.value =
          snapshot.docs.map((doc) => doc["div"].toString()).toList();
    } catch (e) {
      showCustomSnackbar("Error fetching div list: $e",
          type: SnackbarType.error);
    }
  }

  static Future<void> getSubjectList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("subjects")
          .doc(selectedClass.value)
          .collection("subjects")
          .get();
      subjectList.value =
          snapshot.docs.map((doc) => doc["subject"].toString()).toList();
    } catch (e) {
      showCustomSnackbar("Error fetching subject list: $e",
          type: SnackbarType.error);
    }
  }

  // ============================================================
  // SECTION 3️⃣: DATE UTILITIES
  // ============================================================
  static final RxString todayDate = "".obs;

  static RxString getTodayDate({DateTime? date}) {
    final now = date ?? DateTime.now();
    todayDate.value = "${now.year}-${now.month}-${now.day}";
    return todayDate;
  }

  static Future<DateTime> pickedDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    return picked ?? DateTime.now();
  }

  // ============================================================
  // SECTION 4️⃣: QR SCANNER & CAMERA CONTROL
  // ============================================================
  static final barcodeValue = ''.obs;
  static final isPaused = false.obs;
  static final MobileScannerController cameraController =
  MobileScannerController();

  static bool lastTorchState = false;

  static Future<void> toggleCameraOn() async {
    try {
      if (isPaused.value) {
        await cameraController.start();
        isPaused.value = false;
        if (lastTorchState) await cameraController.toggleTorch();
      } else {
        lastTorchState = true;
        await cameraController.stop();
        isPaused.value = true;
      }
    } catch (e) {
      showCustomSnackbar("Error toggling camera: $e",
          type: SnackbarType.error);
    }
  }

  // ============================================================
  // SECTION 5️⃣: EXCEL & FILE HANDLING
  // ============================================================
  static final fileUrl = ''.obs;
  static final columnList = <String>[].obs;
  static final matchedStudent = <String>[].obs;

  // === Fetch file URL from Firestore ===
  static Future<void> getFileUrl() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('file')
          .doc(selectedClass.value)
          .collection(selectedDiv.value)
          .doc('fileUrl')
          .get();

      if (snapshot.exists) {
        fileUrl.value = snapshot.data()?['url'] ?? '';
        await readExcelFile();
      } else {
        showCustomSnackbar("File not found", type: SnackbarType.error);
      }
    } catch (e) {
      showCustomSnackbar("Error fetching file URL: $e",
          type: SnackbarType.error);
    }
  }

  // === Read Excel File ===
  static Future<void> readExcelFile() async {
    try {
      if (fileUrl.value.isEmpty) {
        showCustomSnackbar('No file URL configured', type: SnackbarType.error);
        return;
      }

      final response = await http.get(Uri.parse(fileUrl.value));
      if (response.statusCode != 200) {
        showCustomSnackbar('Failed to download Excel', type: SnackbarType.error);
        return;
      }

      final excel = Excel.decodeBytes(response.bodyBytes);
      final table = excel.tables[excel.tables.keys.first];

      if (table == null || table.rows.isEmpty) {
        showCustomSnackbar('Excel sheet is empty', type: SnackbarType.error);
        return;
      }

      columnList.value =
          table.rows.first.map((c) => c?.value.toString() ?? '').toList();

      final scanned = barcodeValue.value.trim();
      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        final enrollment = row[1]?.value?.toString().trim() ?? '';
        if (enrollment == scanned) {
          matchedStudent.assignAll([
            ?row[1]?.value.toString(),
            ?row[2]?.value.toString(),
            ?row[3]?.value.toString(),
            ?row[4]?.value.toString(),
            ?row[5]?.value.toString(),
          ]);
          break;
        }
      }
    } catch (e) {
      showCustomSnackbar('Error reading excel file: $e',
          type: SnackbarType.error);
    }
  }

  // === Upload Excel to Cloudinary ===
  static const String cloudName = "drnky9swa";
  static const String uploadPreset = "attendance_test";

  static Future<String?> uploadFile(html.File file) async {
    try {
      final mimeTypeData = lookupMimeType(file.path)?.split('/');
      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudName/auto/upload";

      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl))
        ..fields["upload_preset"] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath(
          "file",
          file.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ));

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final url = jsonDecode(result.body)["secure_url"];
        showCustomSnackbar("✅ File uploaded successfully",
            type: SnackbarType.success);
        return url;
      } else {
        showCustomSnackbar(
            "Error uploading file (code ${response.statusCode})",
            type: SnackbarType.error);
        return null;
      }
    } catch (e) {
      showCustomSnackbar("Error uploading file: $e",
          type: SnackbarType.error);
      return null;
    }
  }

  // ============================================================
  // SECTION 6️⃣: ATTENDANCE MANAGEMENT
  // ============================================================
  static Future<void> saveAttendance() async {
    final docRef = FirebaseFirestore.instance
        .collection("attendance")
        .doc(selectedClass.value)
        .collection(selectedDiv.value)
        .doc(selectedSubject.value)
        .collection("dates")
        .doc(todayDate.value);

    await docRef.set({
      "date": todayDate.value,
      "classroom": selectedClassroom.value,
      "students": FieldValue.arrayUnion([
        {
          "enrollment_number": matchedStudent[0],
          "first_name": matchedStudent[1],
          "middle_name": matchedStudent[2],
          "last_name": matchedStudent[3],
          "div": matchedStudent[4],
          "status": true,
        }
      ])
    }, SetOptions(merge: true));

    showCustomSnackbar("Attendance marked successfully",
        type: SnackbarType.success);
  }

  static Future<List<String>> getAllDates(
      String selectedClass, String selectedDiv, String selectedSubject) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(selectedClass)
          .collection(selectedDiv)
          .doc(selectedSubject)
          .collection('dates')
          .get();

      final dates = snapshot.docs.map((doc) => doc.id).toList();
      dates.sort((a, b) => b.compareTo(a));
      return dates;
    } catch (e) {
      debugPrint("Error fetching dates: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceList(String date) async {
    final doc = await FirebaseFirestore.instance
        .collection("attendance")
        .doc(selectedClass.value)
        .collection(selectedDiv.value)
        .doc(selectedSubject.value)
        .collection("dates")
        .doc(date)
        .get();

    final data = doc.data();
    if (data != null && data["students"] != null) {
      return List<Map<String, dynamic>>.from(data["students"]);
    }
    return [];
  }

  static Future<void> updateAttendanceStatus({
    required String date,
    required int index,
    required bool status,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(selectedClass.value)
        .collection(selectedDiv.value)
        .doc(selectedSubject.value)
        .collection('dates')
        .doc(date);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || data['students'] == null) return;

    final students = List.from(data['students']);
    if (index < 0 || index >= students.length) return;

    students[index]['status'] = status;
    await docRef.update({'students': students});
  }





}
