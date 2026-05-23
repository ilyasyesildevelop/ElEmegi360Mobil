import 'package:flutter/material.dart';

import '../theme/el_emegi_colors.dart';

/// Şifre alanı — pass_show / pass_hide ikonları.
class PasswordVisibilityField extends StatefulWidget {
  const PasswordVisibilityField({
    super.key,
    required this.controller,
    this.labelText = 'Şifre',
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordVisibilityField> createState() => _PasswordVisibilityFieldState();
}

class _PasswordVisibilityFieldState extends State<PasswordVisibilityField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_visible,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: widget.errorText,
        suffixIcon: IconButton(
          tooltip: _visible ? 'Gizle' : 'Göster',
          onPressed: () => setState(() => _visible = !_visible),
          icon: Image.asset(
            _visible
                ? 'assets/images/pass_hide.png'
                : 'assets/images/pass_show.png',
            width: 22,
            height: 22,
            color: ElEmegiColors.softBlueGray,
            errorBuilder: (_, __, ___) => Icon(
              _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: ElEmegiColors.softBlueGray,
            ),
          ),
        ),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}
