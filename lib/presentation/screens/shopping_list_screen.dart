import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/shopping_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingListProvider>().loadItems();
    });
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('add_item')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: loc.translate('item_name')),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ShoppingListProvider>().addItem(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(loc.translate('add_item')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('shopping_list')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(loc.translate('clear_list')),
                  content: Text(loc.translate('confirm_clear_list')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ShoppingListProvider>().clearList();
                        Navigator.pop(context);
                      },
                      child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return CheckboxListTile(
                title: Text(
                  item.name,
                  style: TextStyle(decoration: item.isBought ? TextDecoration.lineThrough : null, color: item.isBought ? Colors.grey : null),
                ),
                value: item.isBought,
                onChanged: (_) => provider.toggleItem(item),
                secondary: IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => provider.deleteItem(item.id!)),
              );
            },
          );
        },
      ),
    );
  }
}