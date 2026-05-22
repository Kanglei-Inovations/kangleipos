import '../../../database/database.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
  double get gstAmount => (subtotal * product.gstRate) / 100;
  double get total => subtotal + gstAmount;
}
