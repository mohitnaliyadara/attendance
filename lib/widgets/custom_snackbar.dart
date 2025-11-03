import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';

enum SnackbarType { success, error, info }
void showCustomSnackbar(
    String message, {
      SnackbarType type = SnackbarType.info,
    }) {
  // Determine color, icon color, and icon based on type
  Color backgroundColor;
  Color iconColor = Colors.white;
  IconData iconData;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green.shade700;
      iconData = Icons.check_circle_outline;
      break;
    case SnackbarType.error:
      backgroundColor = AppColors.redColor;
      iconData = Icons.error_outline;
      break;
    case SnackbarType.info:
    default:
      backgroundColor = AppColors.primaryColor;
      iconData = Icons.info_outline;
      break;
  }

  Get.snackbar(
    "", // keep title empty
    "",
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(10),
    backgroundColor: backgroundColor,
    borderRadius: 8,
    duration: const Duration(seconds: 3),
    // 👇 Custom layout for icon + message
    messageText: Row(
      children: [
        Icon(iconData, color: iconColor),
        const SizedBox(width: 8),
        Text(
          message,
          style: AppTextStyle.medium16(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
