import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pgme/core/theme/app_theme.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;

  const OTPInput({
    super.key,
    this.length = 4,
    required this.onCompleted,
  });

  @override
  State<OTPInput> createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> with CodeAutoFill {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Listen for SMS auto-fill
    listenForCode();
  }

  /// Clear all OTP input fields
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length == widget.length) {
      for (int i = 0; i < widget.length; i++) {
        _controllers[i].text = code![i];
      }
      widget.onCompleted(code!);
      for (var node in _focusNodes) {
        node.unfocus();
      }
    }
  }

  @override
  void dispose() {
    cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive box size
        // Available width divided by number of boxes, minus spacing
        final totalSpacing = (widget.length - 1) * 10.0;
        final maxBoxWidth = (constraints.maxWidth - totalSpacing) / widget.length;
        final boxWidth = maxBoxWidth.clamp(50.0, 65.0);
        final boxHeight = boxWidth * 0.85;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => Container(
              margin: EdgeInsets.only(right: index < widget.length - 1 ? 10 : 0),
              child: SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: boxWidth * 0.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF828282), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF828282), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) => _onChanged(value, index),
                  onTap: () {
                    _controllers[index].clear();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
