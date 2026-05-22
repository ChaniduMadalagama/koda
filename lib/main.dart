import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open theme box
  await Hive.initFlutter();
  final themeBox = await Hive.openBox<bool>('themeMode');
  final bool isDark = themeBox.get('isDark', defaultValue: false) ?? false;

  ThemeServiceProvider.setSystemUIOverlayStyle(isDark: isDark);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeServiceProvider(isDark: isDark),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeServiceProvider>(context);

    return MaterialApp.router(
      title: 'Koda',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
