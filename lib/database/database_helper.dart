import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'foodgo.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS order_items');
    await db.execute('DROP TABLE IF EXISTS orders');
    await db.execute('DROP TABLE IF EXISTS food_items');
    await db.execute('DROP TABLE IF EXISTS categories');
    await _onCreate(db, newVersion);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category_id INTEGER NOT NULL,
        image TEXT NOT NULL,
        is_veg INTEGER NOT NULL,
        rating REAL NOT NULL,
        is_promo INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final categories = [
      {'id': 1, 'name': 'Burgers', 'icon': '🍔'},
      {'id': 2, 'name': 'Pizza', 'icon': '🍕'},
      {'id': 3, 'name': 'Sushi', 'icon': '🍣'},
      {'id': 4, 'name': 'Drinks', 'icon': '🥤'},
      {'id': 5, 'name': 'Desserts', 'icon': '🍰'},
      {'id': 6, 'name': 'Biryani', 'icon': '🍛'},
    ];

    for (final c in categories) {
      await db.insert('categories', c);
    }

    final foodItems = [
      {'id': 1, 'name': 'Classic Cheeseburger', 'description': 'Juicy beef patty with melted cheddar, lettuce, tomato, and our signature sauce in a brioche bun.', 'price': 8.50, 'category_id': 1, 'image': '🍔', 'is_veg': 0, 'rating': 4.5, 'is_promo': 1},
      {'id': 2, 'name': 'Double Bacon Burger', 'description': 'Two beef patties, crispy bacon, cheddar cheese, caramelized onions, and BBQ sauce.', 'price': 12.99, 'category_id': 1, 'image': '🍔', 'is_veg': 0, 'rating': 4.7, 'is_promo': 0},
      {'id': 3, 'name': 'Veggie Deluxe Burger', 'description': 'Plant-based patty with avocado, spinach, tomato, and vegan mayo in a whole wheat bun.', 'price': 9.50, 'category_id': 1, 'image': '🍔', 'is_veg': 1, 'rating': 4.3, 'is_promo': 0},
      {'id': 4, 'name': 'Margherita Pizza', 'description': 'Classic pizza with fresh mozzarella, basil leaves, and tomato sauce on a thin crust.', 'price': 14.00, 'category_id': 2, 'image': '🍕', 'is_veg': 1, 'rating': 4.6, 'is_promo': 1},
      {'id': 5, 'name': 'Pepperoni Pizza', 'description': 'Loaded with pepperoni slices, mozzarella cheese, and oregano on a hand-tossed crust.', 'price': 16.50, 'category_id': 2, 'image': '🍕', 'is_veg': 0, 'rating': 4.8, 'is_promo': 0},
      {'id': 6, 'name': 'BBQ Chicken Pizza', 'description': 'Grilled chicken, red onions, BBQ sauce, and double mozzarella on a crispy crust.', 'price': 17.99, 'category_id': 2, 'image': '🍕', 'is_veg': 0, 'rating': 4.5, 'is_promo': 0},
      {'id': 7, 'name': 'Salmon Nigiri Set', 'description': '6 pieces of fresh salmon nigiri with wasabi and pickled ginger.', 'price': 15.00, 'category_id': 3, 'image': '🍣', 'is_veg': 0, 'rating': 4.7, 'is_promo': 0},
      {'id': 8, 'name': 'California Roll', 'description': '8 pieces of crab, avocado, and cucumber wrapped in rice and nori.', 'price': 12.50, 'category_id': 3, 'image': '🍣', 'is_veg': 0, 'rating': 4.4, 'is_promo': 1},
      {'id': 9, 'name': 'Vegetable Sushi Platter', 'description': 'Assorted vegetable sushi rolls with soy sauce and wasabi. 10 pieces.', 'price': 13.00, 'category_id': 3, 'image': '🍣', 'is_veg': 1, 'rating': 4.2, 'is_promo': 0},
      {'id': 10, 'name': 'Fresh Orange Juice', 'description': 'Freshly squeezed orange juice, no added sugar. 500ml.', 'price': 4.50, 'category_id': 4, 'image': '🥤', 'is_veg': 1, 'rating': 4.5, 'is_promo': 0},
      {'id': 11, 'name': 'Iced Caramel Latte', 'description': 'Espresso with caramel syrup and cold milk over ice. 400ml.', 'price': 5.50, 'category_id': 4, 'image': '🥤', 'is_veg': 1, 'rating': 4.6, 'is_promo': 1},
      {'id': 12, 'name': 'Mango Smoothie', 'description': 'Blended mango with yogurt and honey. 400ml.', 'price': 6.00, 'category_id': 4, 'image': '🥤', 'is_veg': 1, 'rating': 4.7, 'is_promo': 0},
      {'id': 13, 'name': 'Chocolate Lava Cake', 'description': 'Warm chocolate cake with a molten center, served with vanilla ice cream.', 'price': 7.50, 'category_id': 5, 'image': '🍰', 'is_veg': 1, 'rating': 4.9, 'is_promo': 1},
      {'id': 14, 'name': 'New York Cheesecake', 'description': 'Classic creamy cheesecake with a graham cracker crust and berry compote.', 'price': 6.99, 'category_id': 5, 'image': '🍰', 'is_veg': 1, 'rating': 4.6, 'is_promo': 0},
      {'id': 15, 'name': 'Tiramisu', 'description': 'Italian dessert with layers of coffee-soaked ladyfingers and mascarpone cream.', 'price': 7.00, 'category_id': 5, 'image': '🍰', 'is_veg': 1, 'rating': 4.5, 'is_promo': 0},
      {'id': 16, 'name': 'Chicken Biryani', 'description': 'Aromatic basmati rice with spiced chicken, saffron, and fried onions. Served with raita.', 'price': 11.99, 'category_id': 6, 'image': '🍛', 'is_veg': 0, 'rating': 4.7, 'is_promo': 1},
      {'id': 17, 'name': 'Mutton Biryani', 'description': 'Tender mutton with fragrant rice, whole spices, and mint. Served with salna.', 'price': 14.99, 'category_id': 6, 'image': '🍛', 'is_veg': 0, 'rating': 4.8, 'is_promo': 0},
      {'id': 18, 'name': 'Veg Biryani', 'description': 'Basmati rice with mixed vegetables, paneer, and aromatic spices. Served with raita.', 'price': 10.50, 'category_id': 6, 'image': '🍛', 'is_veg': 1, 'rating': 4.4, 'is_promo': 0},
    ];

    for (final item in foodItems) {
      await db.insert('food_items', item);
    }
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getFoodItems({int? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      final maps = await db.query('food_items', where: 'category_id = ?', whereArgs: [categoryId]);
      return maps.map((m) => FoodItem.fromMap(m)).toList();
    }
    final maps = await db.query('food_items');
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getPromoItems() async {
    final db = await database;
    final maps = await db.query('food_items', where: 'is_promo = ?', whereArgs: [1]);
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final db = await database;
    final maps = await db.query('food_items', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    final id = await db.insert('orders', order.toMap());
    for (final item in order.items) {
      await db.insert('order_items', item.toMap(id));
    }
    return id;
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final orderMaps = await db.query('orders', orderBy: 'created_at DESC');
    List<Order> orders = [];
    for (final om in orderMaps) {
      final itemMaps = await db.query('order_items', where: 'order_id = ?', whereArgs: [om['id']]);
      final items = itemMaps.map((m) => OrderItem(
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        quantity: m['quantity'] as int,
      )).toList();
      orders.add(Order.fromMap(om, items));
    }
    return orders;
  }
}
