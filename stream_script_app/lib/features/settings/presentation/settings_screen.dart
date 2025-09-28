import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';
import 'package:stream_script/features/auth/services/auth_service.dart';
import '../../auth/presentation/signin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          const SizedBox(height: 20),
          _buildUserProfileSection(),
          const SizedBox(height: 30),
          _buildSettingsGroupTitle("Preferences"),
          _buildSettingsTile(
            context: context,
            icon: Icons.color_lens_outlined,
            title: 'Appearance',
            onTap: () {
              // TODO: Navigate to Appearance settings (dark mode etc)
            },
          ),
          const Divider(height: 40, indent: 10, endIndent: 10),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    final user = AuthService.userData;
   

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: const AssetImage('assets/images/brain_mic.png'),
          backgroundColor: const Color(0xFF4A7C7E),
        ),
        const SizedBox(height: 12),
    
      ],
    );
  }

  Widget _buildSettingsGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4A7C7E)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              if (trailing != null)
                trailing
              else
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Logout',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    AuthService().signout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}