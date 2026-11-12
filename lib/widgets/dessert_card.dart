import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../models/meal.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../screens/details_screen.dart';

/// Стековий навігатор: відкриваємо екран деталей поверх вкладок.
void openDetails(BuildContext context, Dessert d) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => DetailsScreen(dessert: d)),
  );
}

class DessertCard extends StatelessWidget {
  final Dessert dessert;
  const DessertCard({super.key, required this.dessert});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openDetails(context, dessert),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    dessert.thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: StoreConnector<AppState, bool>(
                      converter: (s) =>
                          s.state.favourites.any((f) => f.id == dessert.id),
                      builder: (context, isFav) => IconButton.filledTonal(
                        onPressed: () => StoreProvider.of<AppState>(context)
                            .dispatch(ToggleFavourite(dessert)),
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(dessert.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
