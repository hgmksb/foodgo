import 'package:flutter/material.dart';
import '../models/cart_manager.dart';
import '../models/category.dart';
import '../models/food_item.dart';
import '../database/database_helper.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';
import 'cart_screen.dart';
import 'promotions_screen.dart';
import 'loyalty_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final CartManager _cart = CartManager();
  final DatabaseHelper _db = DatabaseHelper();

  late Future<List<Category>> _categoriesFuture;
  late Future<List<FoodItem>> _foodItemsFuture;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _categoriesFuture = _db.getCategories();
    _foodItemsFuture = _db.getFoodItems();
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId != null) {
        _foodItemsFuture = _db.getFoodItems(categoryId: categoryId);
      } else {
        _foodItemsFuture = _db.getFoodItems();
      }
    });
  }

  void _search(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _foodItemsFuture = _db.searchFoodItems(query);
      } else {
        _filterByCategory(_selectedCategoryId);
      }
    });
  }

  void _openFoodDetail(FoodItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(foodItem: item)),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const PromotionsScreen(),
      const LoyaltyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promotions'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? ListenableBuilder(
              listenable: _cart,
              builder: (context, child) {
                if (_cart.itemCount == 0) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: _openCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('${_cart.itemCount} items - \$${_cart.totalPrice.toStringAsFixed(2)}'),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                );
              },
            )
          : null,
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodGo', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ListenableBuilder(
            listenable: _cart,
            builder: (context, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: _openCart,
                  ),
                  if (_cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories'));
                }
                final categories = snapshot.data!;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildCategoryChip(null, 'All', '🍽️'),
                    ...categories.map((c) => _buildCategoryChip(c.id, c.name, c.icon)),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FoodItem>>(
              future: _foodItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No food items found'));
                }
                final items = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return FoodCard(
                      foodItem: items[index],
                      onTap: () => _openFoodDetail(items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int? id, String name, String icon) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => _filterByCategory(id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
