import 'package:attendance/utils/app_text_style.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';


Widget customTextField(
    String hint, {
      TextEditingController? controller,
      bool obscureText = false,
      IconData? prefixIcon,
      Widget? suffixIcon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      void Function(String)? onChanged,
      bool? readOnly= false,
    }) {

  const double defaultRadius = 12.0;

  final OutlineInputBorder defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(defaultRadius),
    borderSide: BorderSide(color: AppColors.blackColor.withOpacity(0.4), width: 1.0),
  );

  final OutlineInputBorder focusedBorderStyle = defaultBorder.copyWith(
    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
  );

  final OutlineInputBorder errorBorderStyle = defaultBorder.copyWith(
    borderSide: BorderSide(color: AppColors.redColor, width: 2.0),
  );

  return TextFormField(
    readOnly: readOnly!,
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    onChanged: onChanged,
    validator: validator ?? (String? value) {
      if (value == null || value.trim().isEmpty) {
        return "Please enter your $hint";
      }
      return null;
    },

    style: AppTextStyle.regular14(color: AppColors.blackColor),

    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      enabledBorder: defaultBorder,
      border: defaultBorder,
      focusedBorder: focusedBorderStyle,
      errorBorder: errorBorderStyle,
      focusedErrorBorder: errorBorderStyle,
      hintText: hint,
      hintStyle: AppTextStyle.regular14(color: Colors.grey.shade500),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primaryColor)
          : null,
      suffixIcon: suffixIcon,
    ),
  );
}
