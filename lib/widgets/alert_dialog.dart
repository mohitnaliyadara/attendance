import 'package:attendance/controller/controller.dart';
import 'package:attendance/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';

Future<dynamic> showAlertDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // smooth rounded corners
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.person_pin_circle_rounded,
              color: Colors.blueAccent,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              Controller.matchedStudent[0],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "${Controller.matchedStudent[1]} ${Controller.matchedStudent[2]}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

        actions: [
          customTextButton(
            buttonText: "Cancel",
            textColor: Colors.redAccent,
            onPressed: () {
              Navigator.of(context).pop();
              Controller.matchedStudent.clear();
              Controller.toggleCameraOn();
            },
            // color: Colors.redAccent,
          ),
          customTextButton(
              buttonText: "Ok",
              onPressed: () async {
                await Controller.saveAttendance();
                Controller.matchedStudent.clear();
                Controller.toggleCameraOn();
                Navigator.of(context).pop();
              },
              textColor: Colors.green
            // color: Colors.green,
          ),
        ],
      );
    },
  );
}

