import 'package:flutter/material.dart';
import 'constans_config.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: baghroundColor,
    fontFamily: "Poppins",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    hintColor: primaryColor,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(40),
    borderSide: const BorderSide(color: Colors.transparent),
    gapPadding: 10,
  );
  return InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
    hintStyle: TextStyle(
      color: textColor.withOpacity(0.6),
      height: 1.6,
      fontSize: 16,
    ),
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(color: textColor),
    bodyMedium: TextStyle(color: textColor),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: darkBlueColor,
    elevation: 6,
    iconTheme: IconThemeData(color: textColor),
  );
}
