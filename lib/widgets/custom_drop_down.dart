import 'package:attendance/utils/app_colors.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

Widget customDropDown({
  required String label,
  double? width,
  required RxList<String> items,
  required RxString selectedValue,
  Future<void> Function(String?)? onChanged,
}) {
  return Obx(() {
    return Container(
      width: width ?? double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle.semiBold14(
            color: AppColors.primaryColor,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // ↓ compact height
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: AppColors.primaryColor.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: items.contains(selectedValue.value)
                ? selectedValue.value
                : null,
            hint: Text(
              "Select $label",
              style: AppTextStyle.regular14(color: Colors.grey),
            ),
            items: items.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    e,
                    style: AppTextStyle.medium14(color: AppColors.blackColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) async {
              if (val != null) {
                selectedValue.value = val;
                if (onChanged != null) await onChanged(val);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey, size: 22),
          ),
        ),
      ),
    );
  });
}
