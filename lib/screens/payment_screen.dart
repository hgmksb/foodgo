import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_manager.dart';
import '../models/order.dart';
import '../database/database_helper.dart';
import 'order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentMethod;
  final double total;
  final String deliveryName;
  final String deliveryAddress;
  final String deliveryPhone;

  const PaymentScreen({
    super.key,
    required this.paymentMethod,
    required this.total,
    required this.deliveryName,
    required this.deliveryAddress,
    required this.deliveryPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CartManager _cart = CartManager();
  final DatabaseHelper _db = DatabaseHelper();
  final _cardFormKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String _selectedWallet = 'PayPal';
  bool _isProcessing = false;

  static const _loyaltyRate = 10;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (widget.paymentMethod == 'Credit/Debit Card') {
      if (!_cardFormKey.currentState!.validate()) return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    final pointsEarned = (_cart.totalPrice * _loyaltyRate).round();

    final order = Order(
      id: 0,
      total: widget.total,
      status: 'Confirmed',
      paymentMethod: widget.paymentMethod,
      deliveryAddress: '${widget.deliveryName}, ${widget.deliveryAddress}, ${widget.deliveryPhone}',
      createdAt: DateTime.now().toIso8601String(),
      items: _cart.items.map((c) => OrderItem(
        name: c.foodItem.name,
        price: c.foodItem.price,
        quantity: c.quantity,
      )).toList(),
    );

    final orderId = await _db.insertOrder(order);

    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt('loyalty_points') ?? 0;
    await prefs.setInt('loyalty_points', currentPoints + pointsEarned);

    final orderIds = prefs.getStringList('order_ids') ?? [];
    orderIds.add(orderId.toString());
    await prefs.setStringList('order_ids', orderIds);

    _cart.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            orderId: orderId,
            total: widget.total,
            paymentMethod: widget.paymentMethod,
            pointsEarned: pointsEarned,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Processing payment...',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Pay', style: TextStyle(fontSize: 16)),
                          Text(
                            '\$${widget.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.paymentMethod == 'Credit/Debit Card') ...[
                    const Text('Card Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Form(
                      key: _cardFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              if (value.replaceAll(' ', '').length < 16) {
                                return 'Enter a valid 16-digit card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cardNameController,
                            decoration: const InputDecoration(
                              labelText: 'Cardholder Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cardholder name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry (MM/YY)',
                                    hintText: '12/28',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                      return 'MM/YY';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return '3 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.paymentMethod == 'Digital Wallet') ...[
                    const Text('Select Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildWalletOption('PayPal', Icons.account_balance_wallet, Colors.blue),
                    _buildWalletOption('Apple Pay', Icons.apple, Colors.black),
                    _buildWalletOption('Google Pay', Icons.g_mobiledata, Colors.green),
                  ],
                  if (widget.paymentMethod == 'Cash on Delivery') ...[
                    Icon(Icons.money, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Cash on Delivery',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will pay \$${widget.total.toStringAsFixed(2)} in cash when your order is delivered to ${widget.deliveryAddress}.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Card(
                    color: Colors.green,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your payment information is secure and encrypted',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.paymentMethod == 'Cash on Delivery'
                            ? 'Confirm Order'
                            : 'Pay \$${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWalletOption(String name, IconData icon, Color color) {
    final isSelected = _selectedWallet == name;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedWallet = name),
        leading: Icon(icon, color: color),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? Colors.deepOrange : Colors.grey,
        ),
      ),
    );
  }
}
