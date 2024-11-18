import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final Function(String?) onSaved;
  final bool enabled;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    this.keyboardType,
    required this.onSaved,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffix: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          errorStyle: const TextStyle(color: Colors.red),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (keyboardType == TextInputType.number) {
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
              }
              return null;
            },
        onSaved: onSaved,
      ),
    );
  }
}
