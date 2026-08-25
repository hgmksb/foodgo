# FoodGo - Food Delivery App

A Flutter-based mobile application for an online food delivery business. Developed as part of the PUSL2023 Mobile Application Development referral coursework.

## Features

1. **Display of Services** - Browse food items by category (Burgers, Pizza, Sushi, Drinks, Desserts, Biryani) with search functionality
2. **Order Processing** - Add items to cart, adjust quantities, and place orders with delivery details
3. **Online Payment Integration** - Multiple payment options: Credit/Debit Card, Digital Wallet (PayPal, Apple Pay, Google Pay), and Cash on Delivery
4. **Additional Services** - Promotions/deals on selected items, loyalty points system with membership tiers (Starter, Bronze, Silver, Gold)
5. **Professional UI/UX** - Material Design 3, consistent theme, bottom navigation, splash screen

## Technology Stack

- **Framework:** Flutter 3.44.x / Dart 3.12.x
- **Database:** SQLite (sqflite package)
- **State Management:** ChangeNotifier (CartManager singleton)
- **Local Storage:** SharedPreferences (loyalty points)

## Project Structure

```
lib/
├── main.dart                      # App entry point and theme
├── models/
│   ├── category.dart              # Category data model
│   ├── food_item.dart             # Food item data model
│   ├── cart_item.dart             # Cart item data model
│   ├── cart_manager.dart          # Cart state management (ChangeNotifier)
│   └── order.dart                 # Order and order item models
├── database/
│   └── database_helper.dart       # SQLite database helper with seed data
├── screens/
│   ├── splash_screen.dart         # Splash screen
│   ├── home_screen.dart           # Home with categories and food listing
│   ├── food_detail_screen.dart    # Food detail with add to cart
│   ├── cart_screen.dart           # Cart with quantity management
│   ├── checkout_screen.dart       # Delivery details and payment selection
│   ├── payment_screen.dart        # Payment processing
│   ├── order_confirmation_screen.dart  # Order success screen
│   ├── promotions_screen.dart     # Promotions and deals
│   ├── loyalty_screen.dart        # Loyalty points and order history
│   └── profile_screen.dart        # User profile
└── widgets/
    └── food_card.dart             # Reusable food item card widget
```

## Getting Started

### Prerequisites

- Flutter SDK 3.44.x or later
- Dart SDK 3.12.x or later
- Android SDK (for Android builds)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app on a connected device or emulator

### Building APK

```bash
flutter build apk --release
```

## Database Schema

- **categories** - Food categories (id, name, icon)
- **food_items** - Food products (id, name, description, price, category_id, image, is_veg, rating, is_promo)
- **orders** - Customer orders (id, total, status, payment_method, delivery_address, created_at)
- **order_items** - Items within orders (id, order_id, name, price, quantity)
