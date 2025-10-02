import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'data/providers/chamado_provider.dart';
import 'data/providers/auth_provider.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChamadoProvider()),
      ],
      child: MaterialApp(
        title: 'Chamados App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}