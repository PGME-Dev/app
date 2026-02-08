import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final void Function(String)? onChanged;
  final void Function(String) onCompleted;

  const OTPInput({
    super.key,
    this.length = 4,
    this.onChanged,
    required this.onCompleted,
  });

  @override
  State<OTPInput> createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> with CodeAutoFill {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  // Colors
  static const Color _filledBorderColor = Color(0xFF0000D1);
  static const Color _emptyBorderColor = Color(0xFF00C2FF);
  static const Color _backgroundColor = Color(0xFFF6F8FE);

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Listen for SMS auto-fill
    listenForCode();

    // Add listeners for focus changes to trigger rebuild
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
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
    widget.onChanged?.call(otp);

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  void _onKeyDown(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) {
          final hasValue = _controllers[index].text.isNotEmpty;
          final isFocused = _focusNodes[index].hasFocus;

          return Container(
            margin: EdgeInsets.only(right: index < widget.length - 1 ? 16 : 0),
            child: SizedBox(
              width: 56,
              height: 56,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (event) => _onKeyDown(event, index),
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D0D26),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: hasValue ? _filledBorderColor : _emptyBorderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: hasValue ? _filledBorderColor : _emptyBorderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: isFocused ? _emptyBorderColor : (hasValue ? _filledBorderColor : _emptyBorderColor),
                        width: 1,
                      ),
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
          );
        },
      ),
    );
  }
}
