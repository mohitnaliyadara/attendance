import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';

Widget customButton({
  required String buttonText,
  required void Function()? onPressed,
  double? width,
  double? height,
  Color? buttonBackColor,
  Color? textColor,
  double? textSize,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
}) {
  const double defaultHeight = 54.0;
  const double defaultBorderRadius = 12.0;

  return Container(

    width: width ?? double.infinity,
    height: height ?? defaultHeight,
    margin: margin,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(

        backgroundColor: buttonBackColor ?? AppColors.primaryColor,

        foregroundColor: textColor ?? Colors.white,

        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        textAlign: TextAlign.center,

        style: AppTextStyle.semiBold18(color: textColor ?? Colors.white).copyWith(
          fontSize: textSize,
        ),
      ),
    ),
  );
}
