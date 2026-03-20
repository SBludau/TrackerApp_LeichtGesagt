import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark system UI overlay to match app background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.appBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const LeichtGesagtApp());
}

class LeichtGesagtApp extends StatelessWidget {
  const LeichtGesagtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeichtGesagt',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
