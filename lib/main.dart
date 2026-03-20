import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
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

  final prefs = PreferencesService();
  final onboardingDone = await prefs.isOnboardingCompleted();

  runApp(LeichtGesagtApp(showOnboarding: !onboardingDone));
}

class LeichtGesagtApp extends StatelessWidget {
  final bool showOnboarding;

  const LeichtGesagtApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: MaterialApp(
        title: 'LeichtGesagt',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: showOnboarding ? '/onboarding' : '/home',
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/home': (_) => const MainShell(),
        },
      ),
    );
  }
}
