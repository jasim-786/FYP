import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/AppSettingScreen.dart';
import 'package:flutter_application_1/treatment_details_screen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? _expandedSection;
  bool _isLoading = false;
  bool _isAdmin = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  int _totalUsers = 0;
  int _activeUsers = 0;

  @override
  void initState() {
    super.initState();
    // Check admin status on init
    if (_isAdmin) {
      _fetchDashboardData();
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch total users from metadata/user_counts
      final totalUsersSnapshot = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('user_counts')
          .get();
      final totalUsers = totalUsersSnapshot.data()?['totalUsers'] ?? 0;

      // Fetch active users (last 30 minutes)
      final thirtyMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 30));
      final activeUsersSnapshot = await FirebaseFirestore.instance
          .collection('user_activity')
          .where('lastActive',
              isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyMinutesAgo))
          .get();

      setState(() {
        _totalUsers = totalUsers;
        _activeUsers = activeUsersSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String validEmail = 'jasimsagheer786@gmail.com';
    const String validPassword = 'jasim@1234';

    await Future.delayed(const Duration(milliseconds: 500));

    if (_emailController.text.trim() == validEmail &&
        _passwordController.text.trim() == validPassword) {
      setState(() {
        _isAdmin = true;
        _isLoading = false;
      });
      // Update user activity for hardcoded admin user
      try {
        await FirebaseFunctions.instance
            .httpsCallable('updateUserActivity')
            .call({'uid': 'admin_user'});
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating activity: $e';
        });
      }
      _fetchDashboardData();
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password.';
        _isLoading = false;
      });
    }
  }

  void _logout() {
    setState(() {
      _isAdmin = false;
      _emailController.clear();
      _passwordController.clear();
      _errorMessage = null;
      _totalUsers = 0;
      _activeUsers = 0;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE0).withOpacity(0.9),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF5EDE0).withOpacity(0.9),
                const Color(0xFFE6D9A8).withOpacity(0.8),
              ],
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isAdmin
                  ? _buildAdminPanel()
                  : _buildLoginPage(),
        ),
      ),
    );
  }

  Widget _buildLoginPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 60,
              color: Colors.brown[900],
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Login',
              style: GoogleFonts.playfairDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.brown[900],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5E8C7).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber[900]!.withOpacity(0.7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.lora(
                            color: Colors.brown[900],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: Colors.brown[900],
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.amber[900]!,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.brown[900]),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.lora(
                            color: Colors.brown[900],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: Colors.brown[900],
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.amber[900]!,
                              width: 2,
                            ),
                          ),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.brown[900]),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.lora(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ZoomIn(
                        duration: const Duration(milliseconds: 1000),
                        child: GestureDetector(
                          onTapDown: (_) {},
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.brown[900]!,
                                    Colors.amber[900]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 18),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: GoogleFonts.lora(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber[900]!.withOpacity(0.9),
                    Colors.brown[900]!.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'App Management',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Dashboard Overview
            Card(
              elevation: 12,
              color: const Color(0xFFF5E8C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber[900]!, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Overview',
                      style: GoogleFonts.lora(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.brown[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDashboardCard(
                          title: 'Total Users',
                          count: _totalUsers,
                          icon: Icons.people,
                        ),
                        _buildDashboardCard(
                          title: 'Active Users',
                          count: _activeUsers,
                          icon: Icons.person_pin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AdminActionButton(
              icon: Icons.description,
              title: 'Licenses',
              subtitle: 'View open-source licenses and app agreements',
              isExpanded: _expandedSection == 'Licenses',
              onTap: () => _toggleSection('Licenses'),
              content: const _ExpandableContent(
                title: 'Licenses',
                content: 'This app uses the following open-source libraries:\n'
                    '- Flutter: BSD 3-Clause\n'
                    '- device_info_plus: MIT\n\n'
                    'Wheat App is proprietary. Contact support for more info.',
              ),
            ),
            _AdminActionButton(
              icon: Icons.gavel,
              title: 'Terms of Service',
              subtitle: 'Manage app terms and conditions',
              isExpanded: _expandedSection == 'Terms of Service',
              onTap: () => _toggleSection('Terms of Service'),
              content: const _ExpandableContent(
                title: 'Terms of Service',
                content: 'By using Wheat App, you agree to:\n'
                    '1. Lawful use only.\n'
                    '2. No guarantee of accuracy.\n'
                    '3. Data collection per our Privacy Policy.\n'
                    'Violations may result in account suspension.',
              ),
            ),
            _AdminActionButton(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Update or review app privacy policy',
              isExpanded: _expandedSection == 'Privacy Policy',
              onTap: () => _toggleSection('Privacy Policy'),
              content: const _ExpandableContent(
                title: 'Privacy Policy',
                content:
                    'Wheat App collects device and usage data for service improvement. '
                    'Data is secured and not shared without consent.',
              ),
            ),
            _AdminActionButton(
              icon: Icons.security,
              title: 'Data Compliance',
              subtitle: 'Manage GDPR, CCPA, and other regulations',
              isExpanded: _expandedSection == 'Data Compliance',
              onTap: () => _toggleSection('Data Compliance'),
              content: const _ExpandableContent(
                title: 'Data Compliance',
                content: 'Wheat App complies with:\n'
                    '- GDPR: Access, rectify, delete EU data.\n'
                    '- CCPA: Opt-out rights for Californians.',
              ),
            ),
            _AdminActionButton(
              icon: Icons.bug_report,
              title: 'Treatment & Suggestions',
              subtitle: 'View details about plant leaf health',
              isExpanded: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TreatmentDetailsScreen(),
                  ),
                );
              },
              content: const SizedBox.shrink(),
            ),
            _AdminActionButton(
              icon: Icons.settings,
              title: 'App Settings',
              subtitle: 'Update thresholds and models',
              isExpanded: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingsScreen(),
                  ),
                );
              },
              content: const SizedBox.shrink(),
            ),
            const SizedBox(height: 48),
            Center(
              child: ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.brown[900]!,
                          Colors.amber[900]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber[900]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: GoogleFonts.lora(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 8,
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.brown[900],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.brown[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isExpanded;
  final Widget content;

  const _AdminActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isExpanded,
    required this.content,
  });

  @override
  _AdminActionButtonState createState() => _AdminActionButtonState();
}

class _AdminActionButtonState extends State<_AdminActionButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: _isHovered ? 18 : 12,
                  color: const Color(0xFFF5E8C7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.amber[900]!,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.amber[900]!.withOpacity(0.3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      leading: Icon(
                        widget.icon,
                        size: 50,
                        color: Colors.brown[900],
                      ),
                      title: Text(
                        widget.title,
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.brown[900],
                        ),
                      ),
                      subtitle: Text(
                        widget.subtitle,
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.brown[700],
                        ),
                      ),
                      trailing: Icon(
                        widget.isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 30,
                        color: Colors.brown[900],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: widget.content,
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 350),
        ),
      ],
    );
  }
}

class _ExpandableContent extends StatelessWidget {
  final String title;
  final String content;

  const _ExpandableContent({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: const Color(0xFFF5E8C7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.amber[900]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lora(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.brown[900],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.lora(
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: Colors.brown[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
