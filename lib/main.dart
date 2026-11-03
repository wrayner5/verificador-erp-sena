import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/proyecto_provider.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ProyectoProvider(),
    child: const MiApp(),
  ));
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Cafetería SENA - Verificador ERP',
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39A900)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF39A900),
      foregroundColor: Colors.white,
    ),
  ),
  home: const InicioScreen(),
  );
  }
}