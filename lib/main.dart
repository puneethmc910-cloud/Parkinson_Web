import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_providers.dart';
import 'screens/analytics_screen.dart';
import 'screens/daily_help_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ParkinsonAssistiveApp());
}

class ParkinsonAssistiveApp extends StatelessWidget {
  const ParkinsonAssistiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: MaterialApp(
        title: 'Parkinson Smart Shoe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
          DailyHelpScreen.routeName: (_) => const DailyHelpScreen(),
          AnalyticsScreen.routeName: (_) => const AnalyticsScreen(),
          HistoryScreen.routeName: (_) => const HistoryScreen(),
          PatientProfileScreen.routeName: (_) =>
              const PatientProfileScreen(),
        },
      ),
    );
  }
}


