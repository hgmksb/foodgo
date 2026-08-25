class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap(int orderId) {
    return {
      'order_id': orderId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final int id;
  final double total;
  final String status;
  final String paymentMethod;
  final String deliveryAddress;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'created_at': createdAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return Order(
      id: map['id'],
      total: map['total'].toDouble(),
      status: map['status'],
      paymentMethod: map['payment_method'],
      deliveryAddress: map['delivery_address'],
      createdAt: map['created_at'],
      items: items,
    );
  }
}
