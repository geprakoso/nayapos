import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String note;

  CartItem({required this.product, this.quantity = 1, this.note = ''});

  double get totalPrice => product.price * quantity;
}
