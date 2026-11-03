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
      title: 'Verificador ERP Cafeterías',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const InicioScreen(),
    );
  }
}