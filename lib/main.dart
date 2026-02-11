import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/providers/locale_provider.dart';
import 'package:cooking_master/presentation/screens/add_ingredient_screen.dart';
import 'package:cooking_master/presentation/screens/home_screen.dart';
import 'package:cooking_master/presentation/screens/ingredients_screen.dart';
import 'package:cooking_master/presentation/screens/login_screen.dart';
import 'package:cooking_master/presentation/screens/preferences_screen.dart';
import 'package:cooking_master/presentation/screens/receipts_screen.dart';
import 'package:cooking_master/presentation/screens/recommendations_screen.dart';
import 'package:cooking_master/presentation/screens/register_screen.dart';
import 'package:cooking_master/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize service locator with SQLite storage
  await ServiceLocator.initialize(storageType: 'sqlite');
  runApp(const CookingMasterApp());
}

class CookingMasterApp extends StatelessWidget {
  const CookingMasterApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'Cooking Master',
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
            Locale('de'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.orange,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF001F3F),
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const HomeScreen(),
            '/receipts': (_) => const ReceiptsScreen(),
            '/ingredients': (_) => const IngredientsScreen(),
            '/add_ingredient': (_) => const AddIngredientScreen(),
            '/recommendations': (_) => const RecommendationsScreen(),
            '/preferences': (_) => const PreferencesScreen(),
          },
        ),
      ),
    );
}
