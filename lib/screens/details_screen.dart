import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../models/meal.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';

class DetailsScreen extends StatefulWidget {
  final Dessert dessert;
  const DetailsScreen({super.key, required this.dessert});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(fetchDetail(widget.dessert.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dessert.name),
        actions: [
          StoreConnector<AppState, bool>(
            converter: (s) =>
                s.state.favourites.any((f) => f.id == widget.dessert.id),
            builder: (context, isFav) => IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              onPressed: () => store.dispatch(ToggleFavourite(widget.dessert)),
            ),
          ),
        ],
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (s) => s.state,
        builder: (context, state) {
          if (state.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = state.detail;
          if (state.detailError != null || d == null || d.id != widget.dessert.id) {
            return Center(child: Text(state.detailError ?? 'Рецепт недоступний'));
          }
          return ListView(
            children: [
              Image.network(d.thumb, height: 240, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 240)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 8, children: [
                      Chip(label: Text(d.category)),
                      if (d.area.isNotEmpty) Chip(label: Text(d.area)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Інгредієнти',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    ...d.ingredients.map((i) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.circle, size: 8),
                          title: Text(i.name),
                          trailing: Text(i.measure),
                        )),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Додати до списку покупок'),
                      onPressed: () {
                        store.dispatch(
                            AddToShopping(d.ingredients.map((e) => e.name).toList()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Інгредієнти додано 🛒')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Приготування',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(d.instructions),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
