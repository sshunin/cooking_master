import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/screens/splash_screen.dart';
import 'package:cooking_master/presentation/screens/login_screen.dart';
import 'package:cooking_master/presentation/screens/register_screen.dart';
import 'package:cooking_master/presentation/screens/home_screen.dart';

void main() {
  // Initialize service locator with storage type
  ServiceLocator.initialize(storageType: 'local');
  runApp(const CookingMasterApp());
}

class CookingMasterApp extends StatelessWidget {
  const CookingMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Cooking Master',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
