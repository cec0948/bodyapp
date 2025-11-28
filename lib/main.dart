import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const BodyApp());
}

class BodyApp extends StatelessWidget {
  const BodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(),
      child: MaterialApp(
        title: 'BodyApp',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF3B82F6), // Blue-500
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate-900
          cardColor: const Color(0xFF1E293B), // Slate-800
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            secondary: Color(0xFF10B981), // Emerald-500
            surface: Color(0xFF1E293B),
            background: Color(0xFF0F172A),
          ),
          useMaterial3: true,
          fontFamily: 'Pretendard',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            elevation: 0,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
