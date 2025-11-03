import 'package:attendance/controller/controller.dart';
import 'package:attendance/utils/app_text_style.dart';
import 'package:attendance/widgets/custom_button.dart';
import 'package:attendance/widgets/custom_snackbar.dart';
import 'package:attendance/widgets/custom_text_button.dart';
import 'package:attendance/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import 'faculty_system/faculty_management_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool _obscurePassword = true.obs;

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = Controller.usernameController.text.trim();
      final password = Controller.passwordController.text.trim();

      try {
        final querySnapshot = await _firestore
            .collection("login")
            .where("username", isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          showCustomSnackbar("User not found. Please try again.",
              type: SnackbarType.error);
          return;
        }

        final userData = querySnapshot.docs.first.data();
        final storedPassword = userData["password"];
        final role = userData["role"];

        if (password != storedPassword) {
          showCustomSnackbar("Incorrect password. Please try again.",
              type: SnackbarType.error);
          return;
        }

        showCustomSnackbar("Login successful! Redirecting...",
            type: SnackbarType.success);

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (role == "faculty") {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FacultyManagementDashboard()));
          } else {
            showCustomSnackbar("Unknown role: $role",
                type: SnackbarType.info);
          }
        });
      } catch (e) {
        showCustomSnackbar("An error occurred. Please try again.",
            type: SnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // Background gradient added here
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A90E2), // top color (soft blue)
              Color(0xFF1976D2), // bottom color (deep blue)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: width < 500 ? double.infinity : 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(
                      Icons.person_pin_circle,
                      size: 100,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Welcome Back!",
                      style:
                      AppTextStyle.bold22(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Login to continue your attendance system",
                      style:
                      AppTextStyle.regular14(color: AppColors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Username field
                    customTextField(
                      "Email or Username",
                      prefixIcon: Icons.person,
                      controller: Controller.usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter username";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field with toggle
                    Obx(
                          () => customTextField(
                        "Password",
                        prefixIcon: Icons.lock,
                        controller: Controller.passwordController,
                        obscureText: _obscurePassword.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: customTextButton(
                        buttonText: "Forgot Password?",
                        onPressed: () {
                          showCustomSnackbar(
                            "Password recovery not implemented yet.",
                            type: SnackbarType.info,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login button
                    customButton(
                      buttonText: "Login",
                      onPressed: _attemptLogin,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Version 1.0.0",
                      style:
                      AppTextStyle.regular12(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
