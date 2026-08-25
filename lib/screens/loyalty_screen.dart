import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/order.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  int _loyaltyPoints = 0;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final points = prefs.getInt('loyalty_points') ?? 0;
    final orders = await DatabaseHelper().getOrders();

    setState(() {
      _loyaltyPoints = points;
      _orders = orders;
      _isLoading = false;
    });
  }

  int _getTier(int points) {
    if (points >= 1000) return 3;
    if (points >= 500) return 2;
    if (points >= 100) return 1;
    return 0;
  }

  String _getTierName(int tier) {
    switch (tier) {
      case 3:
        return 'Gold';
      case 2:
        return 'Silver';
      case 1:
        return 'Bronze';
      default:
        return 'Starter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = _getTier(_loyaltyPoints);
    final tierName = _getTierName(tier);

    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Rewards')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: tier == 3
                                ? [Colors.amber, Colors.orange]
                                : tier == 2
                                    ? [Colors.grey, Colors.blueGrey]
                                    : tier == 1
                                        ? [Colors.brown, Colors.orange.shade300]
                                        : [Colors.deepOrange, Colors.orangeAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.stars, size: 48, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              '$tierName Member',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_loyaltyPoints',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Loyalty Points',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Membership Tiers',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildTierInfo('Starter', '0 - 99 points', tier == 0),
                    _buildTierInfo('Bronze', '100 - 499 points', tier == 1),
                    _buildTierInfo('Silver', '500 - 999 points', tier == 2),
                    _buildTierInfo('Gold', '1000+ points', tier == 3),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order History',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('${_orders.length} orders'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_orders.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'No orders yet',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._orders.map((order) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: const Icon(Icons.receipt, color: Colors.deepOrange),
                          title: Text('Order #${order.id}'),
                          subtitle: Text(
                            '\$${order.total.toStringAsFixed(2)} - ${order.paymentMethod}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item.name} x${item.quantity}'),
                                        Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  )),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Deliver to:'),
                                      Expanded(
                                        child: Text(
                                          order.deliveryAddress,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTierInfo(String name, String range, bool isCurrent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isCurrent ? Colors.deepOrange : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          isCurrent ? Icons.check_circle : Icons.circle_outlined,
          color: isCurrent ? Colors.deepOrange : Colors.grey,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(range),
        trailing: Text(
          '+${name == 'Starter' ? 0 : name == 'Bronze' ? 100 : name == 'Silver' ? 500 : 1000} pts',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
