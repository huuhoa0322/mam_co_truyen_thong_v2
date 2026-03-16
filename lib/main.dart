import 'package:flutter/material.dart';
import 'package:mam_co_truyen_thong_v2/views/started.dart';
import 'package:mam_co_truyen_thong_v2/views/home.dart';
import 'package:mam_co_truyen_thong_v2/views/recipe_details.dart';
import 'package:mam_co_truyen_thong_v2/views/shopping_lists.dart';
import 'package:mam_co_truyen_thong_v2/views/family_secret.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mâm Cỗ Truyền Thống',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartedScreen(),
        '/home': (context) => const HomeScreen(),
        '/recipe_details': (context) => const RecipeDetailsPage(),
        '/shopping_lists': (context) => const ShoppingListsPage(),
        '/family_secret': (context) => const FamilySecretPage(),
      },
    );
  }
}
