import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/app_colors.dart';

/// headline large 24 800
/// headline medium 20 800
/// headline small 18 800

/// title large 18 500
/// title medium 16 500
/// title small 14 500

/// body large 16 normal
/// body medium 14 normal
/// body small 12 normal

final lightTheme = _getTheme();

const _primary = AppColors.primaryColor;
const _primaryDark = AppColors.primaryColor;

const _secondary = Color(0xFFE95440);
const _secondaryDark = Color(0xFFE95440);

const _background = Colors.white;

const _lightest = Colors.white;
const _light = Color(0xFFB6B6B6);

const _dark1 = Colors.black;
const _dark2 = Colors.black87;

const _divider = Colors.grey;
const _disabled = Colors.grey;

ThemeData _getTheme() {
  final colorScheme = _lightColorScheme;

  final textTheme = _getTextTheme(colorScheme);
  final primaryTextTheme = textTheme.apply(
    displayColor: colorScheme.onPrimary,
    bodyColor: colorScheme.onPrimary,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      statusBarColor: Colors.white, // status bar color
    ),
  );
  final buttonTextStyle = textTheme.titleMedium;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    splashFactory: InkSplash.splashFactory,
    // set colors
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    disabledColor: _disabled,
    fontFamily: "Comfortaa",
    /// ************************************** BottomNavigationBar **************************************
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _primary,
      unselectedItemColor: AppColors.grey,
      selectedIconTheme: IconThemeData(color: _primary),
      unselectedIconTheme: IconThemeData(color: AppColors.grey),
      selectedLabelStyle: TextStyle(color: _primary, fontSize: 12),
      unselectedLabelStyle: TextStyle(color: AppColors.grey, fontSize: 12),
    ),

    /// ************************************** AppBarTheme **************************************
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      elevation: 1,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _primaryDark,
          fontFamily: "inter"),
    ),

    /// ************************************** InputDecoration **************************************
    inputDecorationTheme: InputDecorationTheme(
      fillColor: _dark1.withOpacity(.06),
      errorStyle: const TextStyle(color: Color(0xFFB71C1C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: _lightest),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _lightest),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _dark2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _light, width: 1.0),
      ),
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      hintStyle: TextStyle(
        color: _dark1.withOpacity(.5),
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      labelStyle: const TextStyle(color: _dark1, fontWeight: FontWeight.normal),
    ),

    /// ************************************** DividerTheme **************************************
    dividerTheme: const DividerThemeData(
      color: _divider,
      space: 1,
      thickness: 1,
    ),

    /// ************************************** ButtonTheme **************************************
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: _buttonShape,
        padding: _buttonPadding,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        textStyle: buttonTextStyle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: _buttonShape,
        padding: _buttonPadding,
        side: BorderSide(color: colorScheme.primary, width: 1),
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: _buttonShape,
        padding: _buttonPadding,
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
      ),
    ),

    /// ************************************** SnackBarTheme **************************************
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _dark1,

      /// contentTextStyle: primaryTextTheme.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),

    /// ************************************** PopupMenu **************************************
    popupMenuTheme: PopupMenuThemeData(
      color: _background,
      surfaceTintColor: colorScheme.surface,
    ),

    /// ************************************** BottomSheet **************************************
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: false,
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
    ),

    /// ************************************** FloatingActionButton **************************************
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: Colors.white,
      iconSize: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
    ),

    /// ************************************** Page Transition Builder **************************************
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    sliderTheme: SliderThemeData(
      valueIndicatorColor: _primaryDark,
      valueIndicatorTextStyle: textTheme.titleSmall?.copyWith(
        color: Colors.white,
      ),
    ),
  );
}

/// ************************************** Color Scheme **************************************

final _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: _primary,
  onPrimary: _primaryDark,
  primaryContainer: _dark1.withOpacity(0.5),
  onPrimaryContainer: _light,
  // Secondary
  secondary: _secondary,
  onSecondary: _secondaryDark,
  secondaryContainer: _secondary.withOpacity(0.2),
  onSecondaryContainer: _lightest,
  // Error
  error: const Color(0xFFB71C1C),
  onError: _lightest,
  // Surface
  surface: _lightest,
  onSurface: _dark1,
  // Outline
  outline: _divider,
);

/// ************************************** Text Theme **************************************

// TextTheme _getTextTheme(ColorScheme colorScheme) {
//   const headlineColor = _dark2;
//   const headlineWeight = FontWeight.w800;
//   const headlineHeight = 1.2;
//
//   const titleColor = _dark1;
//   const titleWeight = FontWeight.w500;
//   const titleHeight = 1.2;
//
//   const bodyColor = _dark1;
//   const bodyWeight = FontWeight.normal;
//   const bodyHeight = 1.5;
//
//   const labelColor = titleColor;
//
//   const textTheme = TextTheme(
//     // Headline
//     headlineLarge: TextStyle(
//       fontSize: 24,
//       // fontFamily: AssetPaths.dmSans,
//       height: headlineHeight,
//       color: headlineColor,
//       fontWeight: headlineWeight,
//     ),
//     headlineMedium: TextStyle(
//       fontSize: 20,
//       // fontFamily: AssetPaths.dmSans,
//       height: headlineHeight,
//       color: headlineColor,
//       fontWeight: headlineWeight,
//     ),
//     headlineSmall: TextStyle(
//       fontSize: 18,
//       // fontFamily: AssetPaths.dmSans,
//       height: headlineHeight,
//       color: headlineColor,
//       fontWeight: headlineWeight,
//     ),
//
//     // Title
//     titleLarge: TextStyle(
//       fontSize: 18,
//       // fontFamily: AssetPaths.dmSans,
//       height: titleHeight,
//       color: titleColor,
//       fontWeight: titleWeight,
//     ),
//     titleMedium: TextStyle(
//       fontSize: 16,
//       // // fontFamily: AssetPaths.dmSans,
//       height: titleHeight,
//       color: titleColor,
//       fontWeight: titleWeight,
//     ),
//     titleSmall: TextStyle(
//       fontSize: 14,
//       // // fontFamily: AssetPaths.dmSans,
//       height: titleHeight,
//       color: titleColor,
//       fontWeight: titleWeight,
//     ),
//
//     // Body
//     bodyLarge: TextStyle(
//       fontSize: 16,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: bodyColor,
//       fontWeight: bodyWeight,
//     ),
//     bodyMedium: TextStyle(
//       fontSize: 14,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: bodyColor,
//       fontWeight: bodyWeight,
//     ),
//     bodySmall: TextStyle(
//       fontSize: 12,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: bodyColor,
//       fontWeight: bodyWeight,
//     ),
//
//     // Label
//     labelLarge: TextStyle(
//       fontSize: 16,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: labelColor,
//       fontWeight: bodyWeight,
//     ),
//     labelMedium: TextStyle(
//       fontSize: 12,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: labelColor,
//       fontWeight: bodyWeight,
//     ),
//     labelSmall: TextStyle(
//       fontSize: 11,
//       // fontFamily: AssetPaths.dmSans,
//       height: bodyHeight,
//       color: labelColor,
//       fontWeight: bodyWeight,
//     ),
//   );
//
//   return textTheme;
// }

TextTheme _getTextTheme(ColorScheme colorScheme) {
  const fontFamily = "inter";

  const headlineColor = _dark2;
  const headlineWeight = FontWeight.w800; // Comfortaa-Bold
  const headlineHeight = 1.2;

  const titleColor = _dark1;
  const titleWeight = FontWeight.w500; // Closest to Comfortaa-Regular or mix
  const titleHeight = 1.2;

  const bodyColor = _dark1;
  const bodyWeight = FontWeight.w400; // Comfortaa-Regular
  const bodyHeight = 1.5;

  const labelColor = titleColor;

  return TextTheme(
    // Headline (Bold)
    headlineLarge: TextStyle(
      fontSize: 24,
      fontFamily: fontFamily,
      height: headlineHeight,
      color: headlineColor,
      fontWeight: headlineWeight,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontFamily: fontFamily,
      height: headlineHeight,
      color: headlineColor,
      fontWeight: headlineWeight,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontFamily: fontFamily,
      height: headlineHeight,
      color: headlineColor,
      fontWeight: headlineWeight,
    ),

    // Title (Medium weight)
    titleLarge: TextStyle(
      fontSize: 18,
      fontFamily: fontFamily,
      height: titleHeight,
      color: titleColor,
      fontWeight: titleWeight,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontFamily: fontFamily,
      height: titleHeight,
      color: titleColor,
      fontWeight: titleWeight,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontFamily: fontFamily,
      height: titleHeight,
      color: titleColor,
      fontWeight: titleWeight,
    ),

    // Body (Regular weight)
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),

    // Label (Regular)
    labelLarge: TextStyle(
      fontSize: 16,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontFamily: fontFamily,
      height: bodyHeight,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
  );
}

/// ************************************** Common Styles **************************************

final _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
);
const _buttonPadding = EdgeInsets.symmetric(
  horizontal: 24,
  // vertical: 20,
);
