import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Consistent underline field used across the auth flow.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  static const TextStyle _textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          readOnly: readOnly,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: _textStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 24, color: AppColors.orangeDark),
            prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
            suffixIcon: suffixIcon,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.orangeDark, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.orangeDark),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.orangeDark, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width gradient primary action with loading state.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orange, AppColors.orangeDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20, color: AppColors.white),
                ],
              ),
      ),
    );
  }
}

/// Soft rounded note (security / hints) used inside auth forms.
class AuthNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const AuthNote({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = AppColors.orangeDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.orangeTint.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Group title with icon and a trailing hairline, used to organise fields.
class AuthSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const AuthSectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.orangeDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.orangeDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Simple fade + slide entrance for auth forms.
class AuthEntrance extends StatelessWidget {
  final Widget child;

  const AuthEntrance({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
        );
      },
      child: child,
    );
  }
}

/// Inline error message block.
class AuthErrorBox extends StatelessWidget {
  final String message;

  const AuthErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
