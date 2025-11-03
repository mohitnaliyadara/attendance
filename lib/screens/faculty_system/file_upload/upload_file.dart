import 'dart:io';
import 'package:attendance/screens/faculty_system/file_upload/select_division.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance/controller/controller.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadedUrl;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _uploadedUrl = null;
        });
        showCustomSnackbar(
          "File selected: ${result.files.single.name}",
          type: SnackbarType.success,
        );
      } else {
        showCustomSnackbar("File selection canceled");
      }
    } catch (e) {
      showCustomSnackbar("Error picking file: $e", type: SnackbarType.error);
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) {
      showCustomSnackbar("Please select a file first", type: SnackbarType.info);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final url = await Controller.uploadFile(_selectedFile!);

    setState(() {
      _isUploading = false;
      _uploadedUrl = url;
    });

    if (url != null) {
await FirebaseFirestore.instance.collection("file").doc(Controller.selectedClass.value).collection(Controller.selectedDiv.value).doc("fileUrl").set({
  "url": url
},SetOptions(merge: true));
      showCustomSnackbar(
        "File uploaded successfully!",
        type: SnackbarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Upload Excel File",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectDivision(),));
        }, icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFCE93D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_outlined,
                      size: 70, color: Color(0xFF6A1B9A)),
                  const SizedBox(height: 10),
                  Text(
                    "Upload Attendance File",
                    style: AppTextStyle.semiBold18()
                        .copyWith(color: const Color(0xFF4A148C)),
                  ),
                  const SizedBox(height: 30),

                  // Select File Button
                  customButton(
                    buttonText: _selectedFile == null
                        ? "Select File"
                        : "Change File (${_selectedFile!.path.split('/').last})",
                    onPressed: pickFile,
                    width: double.infinity,
                  ),

                  const SizedBox(height: 20),

                  // Upload Progress / Button
                  _isUploading
                      ? Column(
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF6A1B9A),
                      ),
                      const SizedBox(height: 12),
                      Text("Uploading... Please wait",
                          style: AppTextStyle.medium16()),
                    ],
                  )
                      : customButton(
                    buttonText: "Upload to Cloudinary",
                    onPressed: uploadFile,
                    width: double.infinity,
                  ),

                  const SizedBox(height: 30),

                  // Uploaded file info
                  if (_uploadedUrl != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            "File Uploaded Successfully!",
                            style: AppTextStyle.semiBold16()
                                .copyWith(color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            _uploadedUrl!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text("Copy Link"),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _uploadedUrl!));
                              showCustomSnackbar("Link copied to clipboard",
                                  type: SnackbarType.success);
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
