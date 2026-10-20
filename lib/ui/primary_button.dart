import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

import '../../constants/app_colors.dart';
import '../../utils/heights_and_widths.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.hMargin = 16,
    this.vMargin = 10,
    this.height = 45,
    this.width = double.infinity,
    this.backgroundColor = AppColors.primaryColor,
    this.titleColor = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 16,
    this.fontWidget,
    this.borderRadius = 6,
    this.buttonVerticalPadding = 0,
    this.shadowColor,
    this.borderColor,
    this.elevation,
    this.loading = false,
    this.updateColor = false,
  });

  final String title;
  final VoidCallback onPressed;
  final double hMargin;
  final double vMargin;
  final double height;
  final double width;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderRadius;
  final double buttonVerticalPadding;
  final FontWeight fontWeight;
  final double? fontSize;
  final double? elevation;
  final Widget? fontWidget;
  final bool loading;
  final bool updateColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: updateColor
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor ?? Colors.transparent),
                color: backgroundColor)
            : BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFCD57B2).withOpacity(.7), // Purple 2
                    Color(0xFF911B76).withOpacity(.9), // Purple
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
        margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: vMargin),
        child: Stack(
          fit: StackFit.expand,
          children: [
            loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  )
                : Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: titleColor ?? Colors.white,
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class PrimaryOutlineButton extends StatelessWidget {
  const PrimaryOutlineButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.hMargin = 0,
    this.height = 50,
    this.width = double.infinity,
    this.backgroundColor,
    this.titleColor = AppColors.white,
    this.borderColor = Colors.grey,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16.0,
    this.fontWidget,
    this.borderRadius = 8,
    this.borderWidth = 1.5,
    this.gradientColors, // New property for gradient border
  });

  final String title;
  final VoidCallback onPressed;
  final double hMargin;
  final double height;
  final double width;
  final Color? backgroundColor;
  final Color? titleColor;
  final double borderRadius;
  final Color borderColor;
  final FontWeight fontWeight;
  final double fontSize;
  final double? borderWidth;
  final Widget? fontWidget;
  final List<Color>? gradientColors; // Gradient color list

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradientColors ?? [borderColor, borderColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth ?? 2), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? context.colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius - 1),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius - 1),
              ),
              backgroundColor:
                  Colors.transparent, // Transparent for inner Container
              shadowColor: Colors.transparent, // Remove shadows
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge!.copyWith(
                  fontWeight: fontWeight,
                  color: titleColor,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrefixIconButton extends StatelessWidget {
  const PrefixIconButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height = 44,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.white,
    this.fontSize = 13,
    this.prefixIconPath,
    this.hPadding = 12,
    this.borderColor,
    this.prefixIconSize = 16,
    this.borderRadius = 6,
    this.foregroundColor,
    this.IconColor,
    this.width,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.titleGap = 14,
    this.shadow = true,
  });

  final String title;
  final VoidCallback onPressed;
  final double? fontSize;
  final double height;
  final double? width;
  final Color backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final String? prefixIconPath;
  final Color? IconColor;
  final double prefixIconSize;
  final double hPadding;
  final Color titleColor;
  final MainAxisAlignment mainAxisAlignment;
  final Color? borderColor;
  final double titleGap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: width != null ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (prefixIconPath != null)
              SvgPicture.asset(
                prefixIconPath!,
                height: prefixIconSize,
                color: IconColor,
              ),
            SizedBox(width: titleGap),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    color: titleColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuffixIconButton extends StatelessWidget {
  const SuffixIconButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height = 44,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.white,
    this.borderColor,
    this.foregroundColor,
    this.fontSize = 16,
    this.suffixIconSize = 18,
    this.hPadding = 12,
    this.suffixIconPath,
    this.borderRadius = 10,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.titleGap = 14,
  });

  final String title;
  final VoidCallback onPressed;
  final double? fontSize;
  final double height;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color titleColor;
  final double borderRadius;
  final double suffixIconSize;
  final double hPadding;
  final String? suffixIconPath;
  final MainAxisAlignment mainAxisAlignment;
  final double titleGap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: borderColor != null
                  ? borderColor!
                  : context.colorScheme.outline,
              width: .5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                color: titleColor,
              ),
            ),
            SizedBox(width: titleGap),
            SvgPicture.asset(height: suffixIconSize, suffixIconPath!),
          ],
        ),
      ),
    );
  }
}

class PrimaryIconOutlineButton extends StatelessWidget {
  const PrimaryIconOutlineButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.hMargin = 0,
    this.height = 50,
    this.width = double.infinity,
    this.backgroundColor,
    this.titleColor = AppColors.white,
    this.borderColor = Colors.grey,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16.0,
    this.fontWidget,
    this.borderRadius = 8,
    this.borderWidth = 1.5,
    this.titleAlignment = Alignment.centerLeft,
    required this.iconSvgPath,
  });

  final String title;
  final VoidCallback onPressed;
  final double hMargin;
  final double height;
  final double width;
  final Color? backgroundColor;
  final Alignment? titleAlignment;
  final Color? titleColor;
  final String iconSvgPath;
  final double borderRadius;
  final Color borderColor;
  final FontWeight fontWeight;
  final double fontSize;
  final double? borderWidth;
  final Widget? fontWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: borderWidth!),
          ),
          backgroundColor: backgroundColor ?? context.colorScheme.surface,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: iconSvgPath.isNotEmpty
                      ? SvgPicture.asset(
                          iconSvgPath,
                          height: 24,
                          width: 24,
                          color: titleColor,
                        )
                      : const SizedBox(),
                ),
                w2,
                Expanded(
                  flex: 12,
                  child: Align(
                    alignment: titleAlignment!,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: fontWeight,
                        color: titleColor,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final String? svgIconPath; // Optional SVG icon
  final double iconSize;
  final double iconTextSpacing;
  final Widget? suffixIcon; // ✅ New optional suffix icon

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 50,
    this.width = double.infinity,
    this.borderRadius = 100,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w900,
    this.gradientColors = const [Color(0xffCD57B2), Color(0xff911b76)],
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textAlign = TextAlign.center,
    this.svgIconPath,
    this.iconSize = 20,
    this.iconTextSpacing = 8,
    this.suffixIcon, // ✅ Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 2.0),
          gradient: LinearGradient(colors: gradientColors),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgIconPath != null) ...[
                SvgPicture.asset(
                  svgIconPath!,
                  height: iconSize,
                  width: iconSize,
                  color: textColor,
                ),
                SizedBox(width: iconTextSpacing),
              ],
              Text(
                text,
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              if (suffixIcon != null) ...[
                SizedBox(
                    width: iconTextSpacing), // spacing between text and suffix
                suffixIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
