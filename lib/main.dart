import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/configurator_provider.dart';
import 'screens/configurator_screen.dart';

void main() {
  runApp(const HortisortApp());
}

class HortisortApp extends StatelessWidget {
  const HortisortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfiguratorProvider(),
      child: MaterialApp(
        title: 'Hortisort Defect Configurator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ConfiguratorScreen(),
      ),
    );
  }
}
