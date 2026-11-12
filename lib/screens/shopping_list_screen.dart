import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список покупок'),
        actions: [
          IconButton(
            tooltip: 'Очистити',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => store.dispatch(ClearShopping()),
          ),
        ],
      ),
      body: StoreConnector<AppState, List<ShoppingItem>>(
        converter: (s) => s.state.shopping,
        builder: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('Список порожній 🛒'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Dismissible(
                key: ValueKey(item.name),
                background: Container(color: Colors.red.shade300),
                onDismissed: (_) => store.dispatch(RemoveShoppingItem(item.name)),
                child: CheckboxListTile(
                  value: item.done,
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onChanged: (_) => store.dispatch(ToggleShoppingItem(item.name)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
