import 'package:attendance/screens/faculty_system/file_upload/select_division.dart';
import 'package:attendance/screens/faculty_system/show_attendance/attendance_record.dart';
import 'package:attendance/screens/faculty_system/take_attendance/select_class_screen.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../widgets/custom_snackbar.dart';
import '../student_system/student_attendance_show.dart';
import 'get_reports/get_reposts.dart';

enum UserRole { faculty, student }

class DashboardTile {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  DashboardTile({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });
}

class FacultyManagementDashboard extends StatefulWidget {
  const FacultyManagementDashboard({super.key});

  @override
  State<FacultyManagementDashboard> createState() =>
      _FacultyManagementDashboardState();
}

class _FacultyManagementDashboardState
    extends State<FacultyManagementDashboard> {
  final UserRole currentUserRole = UserRole.faculty;

  // Navigation Handlers
  void _goToTakeAttendance(BuildContext context) {
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectClassScreen(),));
  }

  void _goToAttendanceReports(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectDivision(),));
  }

  void _goToManualCorrection(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceRecordScreen(),));
  }

  void _goToProfile(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GetReports(),));
  }

  @override
  Widget build(BuildContext context) {
    final List<DashboardTile> tiles = [
      DashboardTile(
        title: "Take Attendance",
        icon: Icons.qr_code_scanner_rounded,
        onTap: () => _goToTakeAttendance(context),
        color: AppColors.primaryColor,
      ),
      DashboardTile(
        title: "Upload File",
        icon: Icons.upload_file_sharp,
        onTap: () => _goToAttendanceReports(context),
        color: Colors.blueAccent,
      ),
      DashboardTile(
        title: "Manual Correction",
        icon: Icons.edit_note_rounded,
        onTap: () => _goToManualCorrection(context),
        color: Colors.deepPurpleAccent,
      ),
      DashboardTile(
        title: "Get Repost",
        icon: Icons.cloud_download,
        onTap: () => _goToProfile(context),
        color: Colors.teal,
      ),
    ];

    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Faculty Dashboard",
          style: AppTextStyle.semiBold20(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
              showCustomSnackbar("Faculty Logging out...",
                  type: SnackbarType.info);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.9),
              Colors.blue.shade800
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Text(
                "Welcome, Faculty 👋",
                style: AppTextStyle.bold22(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage your classes, attendance & reports",
                style: AppTextStyle.regular14(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Dashboard Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18.0,
                    mainAxisSpacing: 18.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) {
                    return _buildAnimatedTile(context, tiles[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTile(BuildContext context, DashboardTile tile) {
    return InkWell(
      onTap: tile.onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              tile.color.withOpacity(0.9),
              tile.color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: tile.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tile.icon, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                tile.title,
                textAlign: TextAlign.center,
                style: AppTextStyle.semiBold16(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
