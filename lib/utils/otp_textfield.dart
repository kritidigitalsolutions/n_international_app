import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../res/app_colors.dart';

class OtpTextField extends StatefulWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(int) onBackspace;

  const OtpTextField({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 55,
        constraints: const BoxConstraints(maxWidth: 50),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.focusNode.hasFocus
                ? AppColors.primary
                : Colors.white24,
            width: 1.5,
          ),
        ),
        child: RawKeyboardListener(
          focusNode: FocusNode(), // Temporary focus node for listener
          onKey: (event) {
            if (event is RawKeyDownEvent && 
                event.logicalKey == LogicalKeyboardKey.backspace && 
                widget.controller.text.isEmpty) {
              widget.onBackspace(widget.index);
            }
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            cursorColor: Colors.white,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: text18(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              widget.onChanged(value);
            },
          ),
        ),
      ),
    );
  }
}
