import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class MultipleLoginsScreen extends StatefulWidget {
  const MultipleLoginsScreen({super.key});

  @override
  State<MultipleLoginsScreen> createState() => _MultipleLoginsScreenState();
}

class _MultipleLoginsScreenState extends State<MultipleLoginsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLoggingOut = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logoutDevice(String sessionId) async {
    setState(() => _isLoggingOut = true);
    try {
      await context.read<AuthProvider>().logoutDeviceSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<AuthProvider>();
      provider.clearMultipleSessionsFlag();

      if (mounted) {
        if (provider.onboardingCompleted) {
          // Old user - go to dashboard
          context.go('/home');
        } else {
          // New user - go to subject selection
          context.go('/subject-selection');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatLastActive(String? lastActive) {
    if (lastActive == null) return 'Unknown';
    try {
      final date = DateTime.parse(lastActive);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 5) {
        return 'Active now';
      } else if (difference.inMinutes < 60) {
        return 'Active ${difference.inMinutes} mins ago';
      } else if (difference.inHours < 24) {
        return 'Active ${difference.inHours} hours ago';
      } else {
        return 'Active ${difference.inDays} days ago';
      }
    } catch (e) {
      return lastActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0000D1),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0000D1),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: _buildMainCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        // Get other ACTIVE sessions (exclude current session)
        final otherSessions = provider.activeSessions.where(
          (s) => s['session_id'] != provider.currentSessionId &&
                 s['is_active'] == true,
        ).toList();

        return Container(
          width: 327,
          padding: const EdgeInsets.only(
            top: 28,
            right: 10,
            bottom: 28,
            left: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon - Red hexagon with exclamation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF6B6B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.priority_high_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const SizedBox(
                width: 267,
                child: Text(
                  'Multiple Logins\nDetected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 32 / 24,
                    letterSpacing: 0.12,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              SizedBox(
                width: 307,
                child: Text(
                  otherSessions.isEmpty
                      ? 'You can now continue to the app'
                      : 'Log Out from any one of the devices',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 22 / 14,
                    letterSpacing: 0.07,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Device Cards
              if (otherSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All other devices have been logged out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...otherSessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < otherSessions.length - 1 ? 8 : 0,
                    ),
                    child: _buildDeviceCard(session),
                  );
                }),
              const SizedBox(height: 24),
              // Continue Button
              _buildContinueButton(isEnabled: otherSessions.isEmpty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> session) {
    final deviceName = session['device_name'] ?? 'Unknown Device';
    final lastActive = session['last_active'] as String?;
    final sessionId = session['session_id'] as String?;

    return Container(
      width: 301.78,
      height: 72.29,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(27.45),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device info - centered
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Last active ${_formatLastActive(lastActive).replaceAll('Active ', '')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF888888),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Logout button - exit icon
          GestureDetector(
            onTap: _isLoggingOut || sessionId == null
                ? null
                : () => _logoutDevice(sessionId),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0000D1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 18.31,
                        height: 18.31,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.exit_to_app_rounded,
                        size: 18.31,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton({required bool isEnabled}) {
    final canContinue = isEnabled && !_isLoading;

    return GestureDetector(
      onTap: canContinue ? _continue : null,
      child: Container(
        width: 275,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 101.5, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0000D1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
                    letterSpacing: 0.08,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
