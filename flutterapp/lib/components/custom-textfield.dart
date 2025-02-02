import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? textController;
  final IconData prefixIcon;
  final bool? isPassword;
  final bool? readOnly;
  final VoidCallback? onTap;
  
  const CustomTextField({
    super.key, 
    required this.hint, 
    this.textController,
    required this.prefixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textController,
      obscureText: widget.isPassword ?? false ? _obscureText : false,
      readOnly: widget.readOnly ?? false,
      onTap: widget.onTap,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.isPassword == true
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
