import 'package:attendance/controller/controller.dart';
import 'package:attendance/screens/faculty_system/take_attendance/select_class_screen.dart';
import 'package:attendance/widgets/alert_dialog.dart';
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../utils/app_colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    Controller.getFileUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Controller.barcodeValue.value = "";
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SelectClassScreen(),));
        }, icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor,)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "QR / Barcode Scanner",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () async {
              await Controller.cameraController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
          Obx(
                () => IconButton(
              icon: Icon(
                Controller.isPaused.value
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () async {
                await Controller.toggleCameraOn();
              },
            ),
          ),
        ],
      ),
      body: Obx(
            () => Stack(
          children: [
            // --- Camera Preview ---
            MobileScanner(
              controller: Controller.cameraController,
              onDetect: (capture) async {
                await Controller.toggleCameraOn();
                final barcode = capture.barcodes.first;
                Controller.barcodeValue.value = barcode.rawValue ?? '';
                await Controller.readExcelFile();
                showAlertDialog(context);
              },
            ),

            // --- Scanning Overlay ---
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                ),
                child: Stack(
                  children: [
                    // animated scanning line
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 240 * value),
                            child: Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.greenAccent.withOpacity(0.8),
                            ),
                          );
                        },
                        onEnd: () => setState(() {}), // repeat animation
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Result Display ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.black54],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      Controller.barcodeValue.value.isEmpty
                          ? "Align the QR code within the frame"
                          : "Scanned: ${Controller.barcodeValue.value}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

