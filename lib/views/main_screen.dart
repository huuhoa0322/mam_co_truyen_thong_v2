import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../di.dart';
import '../viewmodels/home/home_view_model.dart';
import '../viewmodels/recipe_details/recipe_details_view_model.dart';
import 'home/home.dart';
import 'recipe_details/recipe_details.dart';
import 'shopping_lists/shopping_lists.dart';
import 'family_secret/family_secret.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    if (state != null) {
      state.switchTab(index);
    }
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecipeDetailsPage(),
    ShoppingListsPage(),
    FamilySecretPage(),
  ];

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
      ],
      // Dùng builder thay vì child để context bên trong có thể đọc provider
      builder: (context, _) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                // context ở đây đã nằm BÊN TRONG MultiProvider — không còn lỗi ProviderNotFoundException
                context.read<RecipeDetailsViewModel>().clearDish();
              }
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF8B0000),
            selectedItemColor: const Color(0xFFFFD700),
            unselectedItemColor: const Color(0xFFFFFDD0).withValues(alpha: 0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_outlined),
                activeIcon: Icon(Icons.restaurant_menu),
                label: 'Chi tiết',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Đi chợ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories_outlined),
                activeIcon: Icon(Icons.auto_stories),
                label: 'Bí kíp',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
