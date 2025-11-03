import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';

Widget customTextButton({
  required String buttonText,
  required void Function()? onPressed,
  Color? textColor,
  double? textSize,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    horizontal: 8.0,
    vertical: 4.0,
  ),
  EdgeInsetsGeometry margin = EdgeInsets.zero,
}) {
  return Container(
    margin: margin,
    child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryColor,

        // Define shape and padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: padding,

        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        textAlign: TextAlign.center,

        style: AppTextStyle.semiBold14(
          color: textColor ?? AppColors.primaryColor,
        ).copyWith(fontSize: textSize),
      ),
    ),
  );
}
