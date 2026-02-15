class ShoppingListItem {
  final int? id;
  final String name;
  final bool isBought;

  const ShoppingListItem({
    this.id,
    required this.name,
    this.isBought = false,
  });
}