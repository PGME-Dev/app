import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class LiveClassBanner extends StatefulWidget {
  final LiveSessionModel session;

  const LiveClassBanner({
    super.key,
    required this.session,
  });

  @override
  State<LiveClassBanner> createState() => _LiveClassBannerState();
}

class _LiveClassBannerState extends State<LiveClassBanner> {
  Timer? _countdownTimer;
  Duration _timeUntilStart = Duration.zero;
  bool _canJoin = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateTimeUntilStart();

    // Update every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeUntilStart();
      }
    });
  }

  void _updateTimeUntilStart() {
    final now = DateTime.now();
    final startTime = DateTime.parse(widget.session.scheduledStartTime).toLocal();

    setState(() {
      _timeUntilStart = startTime.difference(now);

      // Can join if: status is "live" OR 10 minutes or less until start
      _canJoin = widget.session.status == 'live' ||
          (_timeUntilStart.inMinutes <= 10 && _timeUntilStart.inSeconds > 0);
    });
  }

  String _formatScheduledTime() {
    try {
      final startTime = DateTime.parse(widget.session.scheduledStartTime).toLocal();
      final now = DateTime.now();

      // Check if today
      if (startTime.year == now.year &&
          startTime.month == now.month &&
          startTime.day == now.day) {
        final hour = startTime.hour;
        final minute = startTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return 'Starts Today - $hour12:$minute $period';
      } else {
        // Tomorrow or later
        final day = startTime.day;
        final month = _getMonthName(startTime.month);
        return 'Starts $month $day';
      }
    } catch (e) {
      return 'Upcoming';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _joinSession() {
    // Navigate to session details - it handles enrollment/payment/join flow
    context.push('/session/${widget.session.sessionId}');
  }

  void _viewDetails() {
    // Navigate to session details screen with session ID
    context.push('/session/${widget.session.sessionId}');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Container(
        width: 358,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: const Alignment(-0.85, 0),
            end: const Alignment(0.85, 0),
            colors: isDark
                ? [const Color(0xFF0D2A5C), const Color(0xFF2D5A9E)]
                : [const Color(0xFF1847A2), const Color(0xFF8EC6FF)],
            stops: const [0.3469, 0.7087],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image - use local asset
              Positioned(
                right: -5,
                bottom: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/illustrations/home.png',
                    width: 161,
                    height: 83,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(width: 161, height: 83);
                    },
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.session.status == 'live'
                          ? Colors.red.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(7.15),
                    ),
                    child: Text(
                      widget.session.status == 'live'
                          ? 'LIVE NOW'
                          : 'LIVE CLASS',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  SizedBox(
                    width: 180,
                    child: Text(
                      widget.session.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Timing
                  Text(
                    widget.session.status == 'live'
                        ? 'Live Now'
                        : _formatScheduledTime(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  Row(
                    children: [
                      // Join Button
                      GestureDetector(
                        onTap: _canJoin ? _joinSession : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _canJoin
                                ? (widget.session.status == 'live'
                                    ? Colors.green
                                    : const Color(0xFF2470E4))
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.session.status == 'live'
                                ? 'Join Now'
                                : 'Join Live',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // View Details Button
                      GestureDetector(
                        onTap: _viewDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                            ),
                          ),
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
      ),
    );
  }
}
