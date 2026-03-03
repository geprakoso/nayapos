import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/pos/screens/sales_screen.dart';

class NayaPosApp extends StatelessWidget {
  const NayaPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naya POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SalesScreen(),
    );
  }
}
