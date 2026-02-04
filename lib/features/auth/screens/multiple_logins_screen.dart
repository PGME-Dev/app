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
          context.go('/home');
        } else {
          context.go('/data-collection');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getDeviceIcon(String? deviceType) {
    final type = deviceType?.toLowerCase() ?? '';
    if (type.contains('ios') || type.contains('iphone')) {
      return Icons.phone_iphone;
    } else if (type.contains('android')) {
      return Icons.phone_android;
    } else if (type.contains('tablet') || type.contains('ipad')) {
      return Icons.tablet_android;
    } else if (type.contains('web')) {
      return Icons.computer;
    }
    return Icons.devices_other;
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1847A2), Color(0xFF8EC6FF)],
            stops: [0.3469, 0.7087],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/illustrations/logo2.png',
                        width: 120,
                        height: 32,
                        fit: BoxFit.contain,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(width: 120, height: 32);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Main Glass Card
                      _buildMainCard(),
                      const SizedBox(height: 24),
                      // Help text
                      Text(
                        'Need help? Contact support',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
        // Get other sessions (exclude current session)
        final otherSessions = provider.activeSessions.where(
          (s) => s['session_id'] != provider.currentSessionId,
        ).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
              // Warning Icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDCEAF7),
                ),
                child: const Center(
                  child: Icon(
                    Icons.devices_other,
                    size: 30,
                    color: Color(0xFF1847A2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Multiple Logins\nDetected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                otherSessions.isEmpty
                    ? 'You can now continue to the app'
                    : 'Log out all other devices to continue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 20),
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
                      bottom: index < otherSessions.length - 1 ? 12 : 0,
                    ),
                    child: _buildDeviceCard(session),
                  );
                }),
              const SizedBox(height: 20),
              // Continue Button - only enabled when no other sessions
              _buildContinueButton(isEnabled: otherSessions.isEmpty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> session) {
    final deviceName = session['device_name'] ?? 'Unknown Device';
    final deviceType = session['device_type'] as String?;
    final lastActive = session['last_active'] as String?;
    final sessionId = session['session_id'] as String?;
    final isActive = _formatLastActive(lastActive).contains('now');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1847A2),
            Color(0xFF3B7DD8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1847A2).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getDeviceIcon(deviceType),
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF4ADE80)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _formatLastActive(lastActive),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          GestureDetector(
            onTap: _isLoggingOut || sessionId == null
                ? null
                : () => _logoutDevice(sessionId),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.logout_rounded, size: 22, color: Colors.white),
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
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF0000D1) : const Color(0xFF9E9E9E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isEnabled ? 'Continue' : 'Log out other devices first',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
