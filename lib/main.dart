import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mam_co_truyen_thong_v2/views/started.dart';
import 'package:mam_co_truyen_thong_v2/views/recipe_details/recipe_details.dart';
import 'package:mam_co_truyen_thong_v2/views/shopping_lists/shopping_lists.dart';
import 'package:mam_co_truyen_thong_v2/views/family_secret/family_secret.dart';
import 'package:mam_co_truyen_thong_v2/views/main_screen.dart';
import 'di.dart';
import 'viewmodels/family_secret/secret_view_model.dart';
import 'viewmodels/home/home_view_model.dart';
import 'viewmodels/recipe_details/recipe_details_view_model.dart';
import 'viewmodels/shopping_list/shopping_list_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupDI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => getIt<HomeViewModel>(),
        ),
        ChangeNotifierProvider<RecipeDetailsViewModel>(
          create: (_) => getIt<RecipeDetailsViewModel>(),
        ),
        ChangeNotifierProvider<ShoppingListViewModel>(
          create: (_) {
            final vm = getIt<ShoppingListViewModel>();
            vm.init();
            return vm;
          },
        ),
        ChangeNotifierProvider<SecretViewModel>(
          create: (_) {
            final vm = getIt<SecretViewModel>();
            vm.init();
            return vm;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Mâm Cỗ Truyền Thống',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const StartedScreen(),
          '/home': (context) => const MainScreen(),
          '/recipe_details': (context) => const RecipeDetailsPage(),
          '/shopping_lists': (context) => const ShoppingListsPage(),
          '/family_secret': (context) => const FamilySecretPage(),
        },
      ),
    );
  }
}
