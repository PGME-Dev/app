import 'package:flutter/material.dart';

class LiveLabel extends StatefulWidget {
  final bool isLive;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const LiveLabel({
    super.key,
    required this.isLive,
    this.fontSize = 10,
    this.padding,
    this.borderRadius = 6,
  });

  @override
  State<LiveLabel> createState() => _LiveLabelState();
}

class _LiveLabelState extends State<LiveLabel>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  static const _liveColor = Color(0xFFE53935);
  static const _scheduledColor = Color(0xFF2470E4);

  @override
  void initState() {
    super.initState();
    if (widget.isLive) _startPulse();
  }

  @override
  void didUpdateWidget(covariant LiveLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive && _pulseController == null) {
      _startPulse();
    } else if (!widget.isLive && _pulseController != null) {
      _pulseController?.dispose();
      _pulseController = null;
    }
  }

  void _startPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isLive ? _liveColor : _scheduledColor;
    final dotSize = widget.fontSize * 0.7;

    return Container(
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: widget.fontSize * 0.85,
            vertical: widget.fontSize * 0.32,
          ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLive && _pulseController != null) ...[
            FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 1.0)
                  .animate(_pulseController!),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: widget.fontSize * 0.4),
          ],
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: widget.fontSize,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
