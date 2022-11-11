// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class Pallete {
  //* Colors *\\
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  //* Themes *\\
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
    backgroundColor:
        drawerColor, //* will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _themeMode;
  ThemeNotifier({
    ThemeMode themeMode = ThemeMode.dark,
  })  : _themeMode = themeMode,
        super(Pallete.darkModeAppTheme) {
    //?whenever this constructor runs we called getTheme function.
    getTheme();
  }

  //! Public getter
  ThemeMode get mode => _themeMode;
  //* we are using async because we are use shared preferences plugin. With shared preferences we can store th theme of our app into the memory of the app so when we change the theme it gets store in the memory
  //!fetch to us theme of the app whenever app start I want theme to run
  void getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //?we are storing in the local memory with the key 'theme' and value is either light or dark.
    final theme = preferences.getString('theme');

    if (theme == 'light') {
      _themeMode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _themeMode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

//! whenever we click on switch I want toggling themes
  void toggleTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      preferences.setString('theme', 'light');
    } else {
      _themeMode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      preferences.setString('theme', 'dark');
    }
  }
}
