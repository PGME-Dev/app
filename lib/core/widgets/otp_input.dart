import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final void Function(String)? onChanged;
  final void Function(String) onCompleted;
  final double boxSize;
  final double fontSize;
  final double spacing;
  final double borderRadius;

  const OTPInput({
    super.key,
    this.length = 4,
    this.onChanged,
    required this.onCompleted,
    this.boxSize = 56,
    this.fontSize = 24,
    this.spacing = 16,
    this.borderRadius = 24,
  });

  @override
  State<OTPInput> createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final _smartAuth = SmartAuth.instance;

  static const Color _filledBorderColor = Color(0xFF0000D1);
  static const Color _emptyBorderColor = Color(0xFF00C2FF);
  static const Color _backgroundColor = Color(0xFFF6F8FE);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    if (Platform.isAndroid) {
      _listenForSms();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _listenForSms() async {
    try {
      final signature = await _smartAuth.getAppSignature();
      debugPrint('======= APP SIGNATURE: $signature =======');

      final res = await _smartAuth.getSmsWithUserConsentApi();
      debugPrint('SMS Result - hasData: ${res.hasData}');

      if (res.hasData && mounted) {
        final data = res.requireData;
        debugPrint('SMS body: ${data.sms}');
        debugPrint('Extracted code: ${data.code}');

        String? otp = data.code;
        if (otp == null || otp.length < widget.length) {
          final match = RegExp(r'(\d{' + widget.length.toString() + r'})').firstMatch(data.sms);
          otp = match?.group(1);
          debugPrint('Manual regex extracted: $otp');
        }

        if (otp != null && otp.length >= widget.length) {
          final code = otp.substring(0, widget.length);
          _controller.text = code;
          _controller.selection = TextSelection.collapsed(offset: code.length);
          widget.onChanged?.call(code);
          widget.onCompleted(code);
        }
      }
    } catch (e) {
      debugPrint('SMS auto-read error: $e');
    }
  }

  void clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      _smartAuth.removeUserConsentApiListener();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0D0D26),
    );

    final halfSpacing = widget.spacing / 2;

    final defaultPinTheme = PinTheme(
      width: widget.boxSize,
      height: widget.boxSize,
      margin: EdgeInsets.symmetric(horizontal: halfSpacing),
      textStyle: textStyle,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _emptyBorderColor, width: 1),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _emptyBorderColor, width: 1),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _filledBorderColor, width: 1),
      ),
    );

    return AutofillGroup(
      child: Pinput(
        length: widget.length,
        controller: _controller,
        focusNode: _focusNode,
        autofillHints: const [AutofillHints.oneTimeCode],
        showCursor: true,
        closeKeyboardWhenCompleted: false,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        followingPinTheme: defaultPinTheme,
        onChanged: widget.onChanged,
        onCompleted: widget.onCompleted,
      ),
    );
  }
}
