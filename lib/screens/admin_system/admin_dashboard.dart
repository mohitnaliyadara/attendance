import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../widgets/custom_snackbar.dart';
import '../admin_system/add_class_screen.dart';
import '../admin_system/add_division_screen.dart';
import '../admin_system/add_classroom_screen.dart';
import '../admin_system/add_subjects_screen.dart';
import '../../screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Tiles List
  final List<_DashboardTile> tiles = [
    _DashboardTile(
      title: "Add Class",
      icon: Icons.class_,
      color: Colors.blueAccent,
      onTap: () => Get.to(() => AddClassScreen()),
    ),
    _DashboardTile(
      title: "Add Division",
      icon: Icons.group_work_rounded,
      color: Colors.deepPurpleAccent,
      onTap: () => Get.to(() => AddDivisionScreen()),
    ),
    _DashboardTile(
      title: "Add Classroom",
      icon: Icons.meeting_room_rounded,
      color: Colors.teal,
      onTap: () => Get.to(() => AddClassroomScreen()),
    ),
    _DashboardTile(
      title: "Add Subjects",
      icon: Icons.menu_book_rounded,
      color: Colors.orangeAccent,
      onTap: () => Get.to(() => AddSubjectsScreen()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Admin Dashboard",
          style: AppTextStyle.semiBold20(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              Get.offAll(() => LoginScreen());
              showCustomSnackbar("Logging out...", type: SnackbarType.info);
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.9),
              Colors.blue.shade700,
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
              Text(
                "Welcome, Admin 👋",
                style: AppTextStyle.bold22(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage classes, divisions, subjects & rooms",
                style: AppTextStyle.regular14(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) =>
                      _buildAnimatedTile(context, tiles[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated Tile Builder
  Widget _buildAnimatedTile(BuildContext context, _DashboardTile tile) {
    return InkWell(
      onTap: tile.onTap,
      borderRadius: BorderRadius.circular(18),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [tile.color.withOpacity(0.9), tile.color.withOpacity(0.6)],
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
            Text(
              tile.title,
              textAlign: TextAlign.center,
              style: AppTextStyle.semiBold16(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
