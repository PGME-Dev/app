import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MultipleLoginsScreen extends StatefulWidget {
  const MultipleLoginsScreen({super.key});

  @override
  State<MultipleLoginsScreen> createState() => _MultipleLoginsScreenState();
}

class _MultipleLoginsScreenState extends State<MultipleLoginsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<DeviceInfo> _devices = [
    DeviceInfo(
      name: 'Android Samsung S20',
      lastActive: 'Last active 10 mins ago',
      icon: Icons.phone_android,
    ),
    DeviceInfo(
      name: 'Samsung Tab T9',
      lastActive: 'Last active 2 days ago',
      icon: Icons.tablet_android,
    ),
  ];

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

  Future<void> _logoutDevice(int index) async {
    setState(() {
      _devices.removeAt(index);
    });
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          const Text(
            'Log out from any device to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          // Device Cards
          ..._devices.asMap().entries.map((entry) {
            final index = entry.key;
            final device = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _devices.length - 1 ? 12 : 0,
              ),
              child: _buildGlassDeviceCard(device, index),
            );
          }),
          const SizedBox(height: 20),
          // Continue Button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildGlassDeviceCard(DeviceInfo device, int index) {
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
              child: Icon(device.icon, size: 24, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
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
                        color: device.lastActive.contains('mins')
                            ? const Color(0xFF4ADE80)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        device.lastActive,
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
            onTap: () => _logoutDevice(index),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.logout_rounded, size: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _verify,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF0000D1),
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
              : const Text(
                  'Continue',
                  style: TextStyle(
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

class DeviceInfo {
  final String name;
  final String lastActive;
  final IconData icon;

  DeviceInfo({
    required this.name,
    required this.lastActive,
    required this.icon,
  });
}
