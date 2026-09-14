import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/plano_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiarioFinanceiroApp());
}

class DiarioFinanceiroApp extends StatelessWidget {
  const DiarioFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanoProvider()..carregar(),
      child: MaterialApp(
        title: 'Diário Financeiro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1B7A4D),
          scaffoldBackgroundColor: const Color(0xFFF4F6F5),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
