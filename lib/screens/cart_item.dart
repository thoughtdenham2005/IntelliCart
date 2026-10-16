class CartItem {
  final String id;
  final String barcode;
  final String name;
  final double unitPrice;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.barcode,
    required this.name,
    required this.unitPrice,
    required this.imagePath,
    this.quantity = 1,
  });

  double get totalPrice => unitPrice * quantity;
}