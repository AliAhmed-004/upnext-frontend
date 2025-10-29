import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:upnext/services/database_service.dart';
import 'package:upnext/env.dart';
import 'package:upnext/components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController serverUrlController = TextEditingController();
  bool isEditingServerUrl = false;

  @override
  void initState() {
    super.initState();
    serverUrlController.text = Env.baseUrl;
  }

  @override
  void dispose() {
    serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveServerUrl() async {
    final newUrl = serverUrlController.text.trim();
    if (newUrl.isNotEmpty) {
      await Env.setBaseUrl(newUrl);
      setState(() {
        isEditingServerUrl = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server URL updated successfully')),
      );
    }
  }

  void _logoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to sign out?"),
        content: const Text("You will need to sign in again to access your account."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService().logout();
              Get.offAllNamed('/login');
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return _SignedOutView();
            }

            final user = users.first;
            return _ProfileContent(
              user: user,
              serverUrlController: serverUrlController,
              isEditingServerUrl: isEditingServerUrl,
              onEditServerUrl: () {
                setState(() {
                  isEditingServerUrl = true;
                });
              },
              onSaveServerUrl: _saveServerUrl,
              onCancelEdit: () {
                setState(() {
                  isEditingServerUrl = false;
                  serverUrlController.text = Env.baseUrl;
                });
              },
              onLogout: _logoutConfirmation,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Map<String, dynamic> user;
  final TextEditingController serverUrlController;
  final bool isEditingServerUrl;
  final VoidCallback onEditServerUrl;
  final Future<void> Function() onSaveServerUrl;
  final VoidCallback onCancelEdit;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.user,
    required this.serverUrlController,
    required this.isEditingServerUrl,
    required this.onEditServerUrl,
    required this.onSaveServerUrl,
    required this.onCancelEdit,
    required this.onLogout,
  });

  String _initials(String? nameOrEmail) {
    final source = (nameOrEmail ?? '').trim();
    if (source.isEmpty) return '?';
    if (source.contains('@')) {
      return source.substring(0, 1).toUpperCase();
    }
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _memberSince(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '—';
    try {
      final dt = DateTime.tryParse(createdAt);
      if (dt == null) return '—';
      return DateFormat.yMMMM().format(dt);
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = (user['full_name'] ?? user['username'] ?? '') as String?;
    final email = (user['email'] ?? '') as String?;
    final createdAt = (user['created_at'] ?? '') as String?;
    final initials = _initials(username?.isNotEmpty == true ? username : email);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (username?.isNotEmpty == true ? username! : 'User'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Member since ${_memberSince(createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_rounded, color: Color(0xFF6366F1)),
                title: const Text('Name'),
                subtitle: Text(username?.isNotEmpty == true ? username! : '—'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_rounded, color: Color(0xFF6366F1)),
                title: const Text('Email'),
                subtitle: Text(email ?? '—'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dns_rounded, color: Color(0xFF6366F1)),
                title: const Text('Server URL'),
                subtitle: isEditingServerUrl
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            CustomTextfield(
                              hintText: 'Server URL',
                              controller: serverUrlController,
                              obscureText: false,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: onCancelEdit,
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: onSaveServerUrl,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Text(Env.baseUrl),
                trailing: isEditingServerUrl
                    ? null
                    : IconButton(
                        onPressed: onEditServerUrl,
                        icon: const Icon(Icons.edit_rounded),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF6B7280)),
                title: const Text('Edit profile'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                title: const Text(
                  'Sign out',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: 60,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "You're not signed in",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to view your profile details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
