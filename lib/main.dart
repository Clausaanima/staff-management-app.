import 'package:flutter/material.dart';
import 'package:personal_expert/screens/departments_screen.dart';
import 'package:personal_expert/screens/employees_page.dart';
import 'package:personal_expert/screens/home_page.dart';
import 'package:personal_expert/screens/positions_screen.dart';
import 'package:personal_expert/screens/vacations_screen.dart';
import 'package:personal_expert/screens/welcome_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Supabase
  await Supabase.initialize(
    url: 'https://yhuvkqmmevszapeybzdi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlodXZrcW1tZXZzemFwZXliemRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzAxNDEzODUsImV4cCI6MjA0NTcxNzM4NX0.CcEpOdkngoWxr7GVOk67IAcV7a5SM5T9RcY4UdRKL9I',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ПерсоналЭксперт', // Изменено с 'Chat App' на русское название
      theme: ThemeData(
        // Кастомная цветовая тема в соответствии с предыдущими экранами
        primaryColor: Color(0xFF8B4513), // Коричневый как основной цвет
        scaffoldBackgroundColor: Color(0xFFF5E6D3), // Светлый бежевый фон
        cardColor: Color(0xFFD2B48C), // Темный бежевый для карточек
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A2F1A)), // Темно-коричневый для основного текста
          bodyMedium: TextStyle(color: Color(0xFF6B4423)), // Средне-коричневый для второстепенного текста
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B4513), // Коричневый для кнопок
            foregroundColor: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Добавлена поддержка русской локализации
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'), // Русский язык
      ],
      locale: const Locale('ru', 'RU'), // Установлена русская локаль по умолчанию
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/home': (context) => HomePage(),
        '/employees': (context) => const EmployeesScreen(),
        '/departments': (context) => const DepartmentsScreen(),
        '/positions': (context) => const PositionsScreen(),
        '/vacations': (context) => const VacationsScreen(),
      },
    );
  }
}
