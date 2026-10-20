import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

import '../../constants/app_colors.dart';
import '../../utils/validators/validators.dart';
import '../password_suffix_widget.dart';

class InputField extends StatefulWidget {
  const InputField({
    this.controller,
    required this.label,
    this.textInputAction,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.suffix,
    this.focusBorderColor,
    this.prefixIcon,
    this.maxLines = 1,
    this.fillColor = Colors.white,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.autoFocus = false,
    super.key,
    this.onChange,
    this.borderColor,
    this.borderRadius = 6,
    this.fontSize = 14,
    this.boxConstraints = 44,
    this.fontWeight = FontWeight.w400,
    this.horizontalPadding = 20,
    this.verticalPadding = 14,
    this.suffixIconTopPadding = 16,
    this.suffixIconRightPadding = 25,
    this.labelColor = Colors.black,
    this.hintColor = Colors.grey,
    this.lMargin = 25,
    this.rMargin = 8,
    this.textColor,
    this.fieldTitle = "",
    this.titleSize = 16.0,
    this.titleWeight,
    this.focusNode,
  });

  final String? fieldTitle;
  final TextEditingController? controller;
  final String label;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final Color? fillColor;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autoFocus;
  final Function(String)? onChange;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? textColor;
  final double borderRadius;
  final double? titleSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double boxConstraints;
  final double suffixIconTopPadding;
  final double suffixIconRightPadding;
  final FontWeight fontWeight;
  final Color labelColor;
  final Color hintColor;
  final double lMargin;
  final FontWeight? titleWeight;
  final double rMargin;
  final FocusNode? focusNode;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    final validator =
        widget.validator ?? Validators.getValidator(widget.keyboardType);

    return Column(
      children: [
        widget.fieldTitle != ""
            ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    widget.fieldTitle!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: widget.titleSize ?? 16.0,
                      fontWeight: widget.titleWeight ?? FontWeight.w500,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Stack(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(color: widget.textColor ?? Colors.black),
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction ??
                  (widget.maxLines == 1
                      ? TextInputAction.done
                      : TextInputAction.newline),
              obscureText: widget.obscureText,
              validator: validator,
              enabled: true,
              onTap: widget.onTap,
              autofocus: widget.autoFocus,
              readOnly: widget.readOnly,
              inputFormatters: widget.inputFormatters,
              onFieldSubmitted: widget.onFieldSubmitted ??
                  (widget.maxLines == 1
                      ? (_) => FocusScope.of(context).unfocus()
                      : null),
              maxLines: widget.maxLines,
              onChanged: widget.onChange,
              cursorColor: AppColors.textGrey,
              decoration: InputDecoration(
                hintText: widget.label,
                // label: Text(widget.label),
                labelStyle: TextStyle(
                  color: widget.labelColor,
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  fontFamily: "Inter",
                ),
                hintStyle: TextStyle(
                  color: widget.hintColor,
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  fontFamily: "Inter",
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.focusBorderColor ?? AppColors.blue,
                  ),
                ),
                errorStyle: const TextStyle(color: AppColors.red),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
                filled: true,
                fillColor: widget.fillColor,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                  vertical: widget.verticalPadding,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.only(
                    left: widget.lMargin,
                    right: widget.rMargin,
                  ),
                  child: widget.prefixIcon,
                ),
                prefixIconConstraints: BoxConstraints(
                  maxWidth: widget.boxConstraints,
                  maxHeight: widget.boxConstraints,
                ),
                suffix: widget.suffix,
              ),
            ),
            Positioned(
              right: widget.suffixIcon is IconButton ||
                      widget.suffixIcon is PasswordSuffixIcon
                  ? 6
                  : widget.suffixIconRightPadding,
              top: widget.suffixIcon is IconButton ||
                      widget.suffixIcon is PasswordSuffixIcon
                  ? 0
                  : widget.suffixIconTopPadding,
              child: Align(
                alignment: Alignment.center,
                child: widget.suffixIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UnderLineInputField extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextEditingController controller;
  final Color borderColor;
  final String? prefixIcon;

  const UnderLineInputField({
    super.key,
    this.title = "",
    required this.controller,
    this.borderColor = AppColors.bgGrey,
    this.hintText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: context.textTheme.titleSmall),
        ],
        TextFormField(
          maxLength: 255,
          controller: controller,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            prefixIconConstraints: prefixIcon != null && prefixIcon != ""
                ? const BoxConstraints(
                    minHeight: 16,
                    minWidth: 24,
                    maxHeight: 24,
                    maxWidth: 24,
                  )
                : const BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                    maxHeight: 0,
                    maxWidth: 0,
                  ),
            prefixIcon: SvgPicture.asset(prefixIcon ?? ""),
            contentPadding: const EdgeInsets.only(top: 15, bottom: 10),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }
}

class ReadOnlyTextField extends StatelessWidget {
  final String label;
  final String labelText;
  final TextEditingController controller;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Widget? suffixIcon;
  final bool readOnly;
  final TextInputType keyboardType;
  final Function(String)? onChange;

  const ReadOnlyTextField({
    super.key,
    required this.label,
    required this.labelText,
    required this.controller,
    this.actionText,
    this.onActionTap,
    this.suffixIcon,
    this.readOnly = true,
    this.keyboardType = TextInputType.text,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, top: 7, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InputField(
                  label: labelText,
                  controller: controller,
                  fillColor: AppColors.lightGrey,
                  borderColor: AppColors.transparent,
                  focusBorderColor: AppColors.transparent,
                  horizontalPadding: 0,
                  verticalPadding: 0,
                  boxConstraints: 0,
                  validator: null,
                  borderRadius: 11,
                  fontSize: 14,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  fontWeight: FontWeight.w600,
                  suffixIcon: suffixIcon,
                  suffixIconTopPadding: 0,
                  onChange: onChange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
